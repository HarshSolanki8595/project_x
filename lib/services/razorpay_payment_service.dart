import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// ================================================================
// RAZORPAY PAYMENT SERVICE (NEW — 2026-09-09)
// ================================================================
//
// Wraps the real Razorpay Checkout flow. Replaces the old mocked
// OrderService.payForOrder/payCancellationFee, which just called a
// Cloud Function that trusted the client outright (no real payment
// ever happened -- it just wrote paymentStatus: 'PAID'). The real
// flow is three steps:
//
//   1. createRazorpayOrder (Cloud Function) computes the amount owed
//      server-side and opens a Razorpay order for it.
//   2. Razorpay's own Checkout UI collects the payment (UPI, card,
//      netbanking, wallet -- whatever the customer picks inside it).
//   3. verifyRazorpayPayment (Cloud Function) checks the payment
//      signature server-side and only then marks the order paid.
//
// One instance should be created per payment attempt (per bottom
// sheet) and MUST have dispose() called when the sheet closes -- same
// lifecycle rule as any other Razorpay-SDK-backed widget. See
// _PaymentSheet / _CancellationFeeSheet in order_status_screen.dart
// for the call sites.
//
// `purpose` mirrors the Cloud Function's own purpose argument:
// 'JOB_PAYMENT' (default) for the main service payment, or
// 'CANCELLATION_FEE' for the flat ₹150 withdrawal fee -- both route
// through the exact same create/verify pair server-side.
// ================================================================

class RazorpayPaymentService {
  final Razorpay _razorpay = Razorpay();
  Completer<void>? _completer;
  String? _orderId;

  RazorpayPaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  // ============================================================
  // FETCH PREVIEW (NEW — 2026-09-09, first-orders fee waiver)
  // ============================================================
  //
  // createRazorpayOrder is what actually opens a Razorpay order --
  // there's no separate "quote" endpoint -- so this just calls it
  // early (when a payment sheet first opens) purely to read the
  // server-computed breakdown for display: agreedPrice/platformCharge/
  // gst/fullTotal, and whether platformFeeWaived is true for this
  // customer's next JOB_PAYMENT. The returned map is later handed
  // straight to pay() below via preFetchedOrder so the SAME Razorpay
  // order that was already created gets paid, instead of a second one
  // being created when the customer actually taps Pay.
  //

  // promoCode (NEW -- 2026-10-05): an optional promo code the customer
  // typed into the payment sheet. The server validates it and, if it is
  // good, creates the Razorpay order for the DISCOUNTED amount and
  // returns promoCode/promoDiscount in the map. An invalid code throws a
  // FirebaseFunctionsException whose message is safe to show as-is.
  Future<Map<String, dynamic>> fetchPreview({
    required String orderId,
    String purpose = 'JOB_PAYMENT',
    String? promoCode,
  }) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('createRazorpayOrder');

    final response = await callable.call(<String, dynamic>{
      'orderId': orderId,
      'purpose': purpose,
      if (promoCode != null && promoCode.trim().isNotEmpty)
        'promoCode': promoCode.trim(),
    });

    return Map<String, dynamic>.from(response.data as Map);
  }

  // ============================================================
  // PAY
  // ============================================================
  //
  // Resolves once the payment is verified server-side, or throws a
  // StateError with a message safe to show the customer directly
  // (call sites already catch StateError this way -- see
  // order_status_screen.dart's _confirmPayment methods).
  //

  Future<void> pay({
    required String orderId,
    String purpose = 'JOB_PAYMENT',
    // Pass the map returned by fetchPreview() to reuse that already-
    // created Razorpay order instead of calling createRazorpayOrder a
    // second time here. Omit it (as _CancellationFeeSheet still does --
    // it has no breakdown preview to show) to fetch fresh, same as
    // before.
    Map<String, dynamic>? preFetchedOrder,
  }) async {
    _orderId = orderId;
    final completer = Completer<void>();
    _completer = completer;

    try {
      final data =
          preFetchedOrder ?? await fetchPreview(orderId: orderId, purpose: purpose);

      final options = <String, dynamic>{
        'key': data['keyId'],
        'order_id': data['razorpayOrderId'],
        'amount': data['amount'],
        'currency': data['currency'] ?? 'INR',
        'name': data['name'] ?? 'Habio',
        'description': data['description'] ?? 'Habio payment',
        'prefill': {
          'contact': data['prefillContact'] ?? '',
          'name': data['prefillName'] ?? '',
        },
        'theme': {
          // Matches AppTheme.primaryBlue. Razorpay Checkout is a
          // separate hosted UI (its own screen, not built with this
          // app's own widgets), so this is the one hook available to
          // keep it from looking like an unrelated third-party page.
          'color': '#1557FF',
        },
      };

      _razorpay.open(options);
    } on FirebaseFunctionsException catch (e) {
      completer.completeError(
        StateError(e.message ?? 'Unable to start payment right now.'),
      );
    } catch (_) {
      completer.completeError(
        StateError('Unable to start payment right now.'),
      );
    }

    return completer.future;
  }

  // ============================================================
  // RAZORPAY CALLBACKS
  // ============================================================

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = _orderId;
    final completer = _completer;

    if (orderId == null || completer == null || completer.isCompleted) {
      return;
    }

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('verifyRazorpayPayment');

      await callable.call(<String, dynamic>{
        'orderId': orderId,
        'razorpayOrderId': response.orderId,
        'razorpayPaymentId': response.paymentId,
        'razorpaySignature': response.signature,
      });

      if (!completer.isCompleted) {
        completer.complete();
      }
    } on FirebaseFunctionsException catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError(
            e.message ??
                'Payment could not be confirmed. Please contact support if money was deducted.',
          ),
        );
      }
    } catch (_) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError(
            'Payment could not be confirmed. Please contact support if money was deducted.',
          ),
        );
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    final completer = _completer;
    if (completer == null || completer.isCompleted) return;

    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      completer.completeError(StateError('Payment cancelled.'));
    } else {
      completer.completeError(
        StateError(response.message ?? 'Payment failed. Please try again.'),
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // The customer picked a wallet Razorpay hands off to externally
    // (e.g. Paytm) rather than completing inside Checkout itself -- no
    // success/error event follows this in-app, so there's nothing
    // reliable to resolve the Future with. Treated as a soft failure
    // so the sheet doesn't hang forever; the customer can reopen
    // "Pay Now" to check/retry if the external wallet flow didn't
    // actually go through.
    final completer = _completer;
    if (completer == null || completer.isCompleted) return;

    completer.completeError(
      StateError(
        'Complete the payment in ${response.walletName ?? 'your wallet app'}, then check back here.',
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================
  //
  // Clears Razorpay's native event listeners. Must be called from the
  // owning State's dispose() -- forgetting this leaks the listeners
  // for the lifetime of the app, same as any other native SDK handle.
  //

  void dispose() {
    _razorpay.clear();
  }
}
