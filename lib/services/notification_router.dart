import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../models/service_request_model.dart';
import '../screens/fixed_price_waiting_screen.dart';
import '../screens/order_status_screen.dart';
import '../screens/professionals_screen.dart';
import 'order_service.dart';
import 'request_repository.dart';

// ================================================================
// NOTIFICATION ROUTER (NEW — 2026-09-27)
// ================================================================
//
// Every notification (the in-app bell list AND a tapped system-tray
// push) carries a `type` and a `relatedId` — see
// functions/index.js's createNotification() for the full list of
// types this app can receive, and notification_model.dart for how
// they're read. This is the single place that turns those two
// strings into an actual screen, so tapping a notification always
// lands somewhere real instead of doing nothing (previously only
// BID_ACCEPTED did anything at all, and that just went to Home).
//
// relatedId is always a service_requests/{id} document id — including
// for JOB_STARTED/JOB_COMPLETED/ORDER_CANCELLED/PICKUP_STAGE_CHANGED,
// where index.js's own comments call it "orderId": the orders
// collection deliberately reuses the same document id as its
// originating request (`db.collection("orders").doc(requestId)` in
// index.js), so a single service_requests fetch is all any of these
// types need — OrderStatusScreen takes the ServiceRequest and streams
// the live order itself internally.
//

class NotificationRouter {
  NotificationRouter._();

  static Future<void> open(
    BuildContext context, {
    required String type,
    required String? relatedId,
  }) async {
    // BROADCAST (NEW — 2026-10-02, admin panel's push-notification
    // composer) carries no relatedId by design -- it's a platform-
    // wide message, not tied to any one booking. Without this guard
    // it would fall straight into the "no relatedId" branch below
    // and show a confusing "This booking is no longer available"
    // snackbar for a notification that was never about a booking.
    // Tapping it just leaves the customer wherever the tap already
    // brought them (Home, most commonly), same as every other
    // unrecognized type falls through to the no-op default below.
    //
    // ORDER_REASSIGNED (NEW -- 2026-10-05): the admin moved the booking
    // to another professional and the old order document is gone, so
    // there is nothing to open. Same no-op as BROADCAST.
    if (type == 'BROADCAST' || type == 'ORDER_REASSIGNED') return;

    if (relatedId == null || relatedId.trim().isEmpty) {
      // No id to look anything up by. Previously this silently did
      // nothing at all, which is indistinguishable from a bug on a
      // tap that just isn't working -- some notifications written
      // before every bid notification reliably carried a relatedId
      // will hit this (added 2026-09-27, per Harsh: a tap should
      // never look like nothing happened). Same message as the
      // "request no longer exists" case below, since from the
      // customer's side it's the same outcome either way -- there's
      // nowhere real to send them.
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('This booking is no longer available.'),
          ),
        );
      }
      return;
    }

    final requestModel = await RequestRepository.getRequestById(relatedId);

    if (requestModel == null) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('This booking is no longer available.'),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    final legacyRequest = _toLegacyRequest(requestModel);

    switch (type) {
      case 'BID_SUBMITTED':
        // A new quote arrived on a still-open request -- but this
        // notification can sit unread and be tapped long after it
        // arrived, by which point the request may have moved on
        // (this or another bid already accepted, the job since
        // started/completed/cancelled). acceptBid's own server-side
        // guard already makes it impossible to actually create a
        // second order from a stale "Accept" tap, but without this
        // check the customer would still land back on the bid-review
        // screen for a job that's already resolved, which looks like
        // there's still an offer to act on when there isn't (added
        // 2026-09-27, per Harsh). So: check for a live order first --
        // if one already exists for this request, show its real
        // current state instead, exactly like every other
        // order-lifecycle notification does.
        final existingOrder = await OrderService.getOrder(relatedId);

        if (existingOrder != null) {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderStatusScreen(request: legacyRequest),
            ),
          );
          break;
        }

        // No order yet -- this request is still genuinely open for
        // bids/offers. Mirrors bookings_screen.dart's own
        // _openUpcomingRequest routing -- FIXED_PRICE requests don't
        // collect bids, so this branch shouldn't normally fire for
        // one, but the check is kept for safety rather than assumed.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => requestModel.pricingType == 'FIXED_PRICE'
                ? FixedPriceWaitingScreen(request: legacyRequest)
                : ProfessionalsScreen(request: legacyRequest),
          ),
        );
        break;

      case 'BID_ACCEPTED':
      case 'JOB_STARTED':
      case 'JOB_COMPLETED':
      case 'ORDER_CANCELLED':
      case 'PICKUP_STAGE_CHANGED':
      case 'INVOICE_READY':
      case 'NO_SHOW_FEE_OWED':
      case 'FEE_WAIVED':
        // An order now exists for this request — OrderStatusScreen
        // streams it live and shows whatever's current (pay now,
        // rate & review, pickup progress, etc).
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderStatusScreen(request: legacyRequest),
          ),
        );
        break;

      default:
        // Unknown/future type — do nothing rather than guess wrong.
        break;
    }
  }

  // ============================================================
  // CONVERT REAL MODEL -> LEGACY ServiceRequest
  // ============================================================
  //
  // Same field mapping as bookings_screen.dart's own
  // _toLegacyRequest — ProfessionalsScreen/OrderStatusScreen/
  // FixedPriceWaitingScreen all take the older `ServiceRequest`
  // model (service_request.dart), not the real Firestore-backed
  // `ServiceRequestModel` this router reads. Only the fields those
  // screens actually use are populated.
  //

  static ServiceRequest _toLegacyRequest(ServiceRequestModel model) {
    return ServiceRequest(
      categoryName: model.categoryId,
      subCategoryName: model.requestTypeId,
      issueDescription: model.description,
      // Reads the real flag directly (2026-09-27 urgency wiring fix)
      // instead of guessing from `urgency`, which is a separate,
      // never-updated legacy field.
      isEmergency: model.isEmergency,
      latitude: model.latitude,
      longitude: model.longitude,
      requestId: model.requestId,
      requestTypeId: model.requestTypeId,
      capabilityId: model.capabilityId,
      categoryId: model.categoryId,
      customerId: model.customerId,
      urgency: model.urgency,
      pricingType: model.pricingType,
      postedPrice: model.postedPrice,
      computedFairPrice: model.computedFairPrice,
    );
  }
}
