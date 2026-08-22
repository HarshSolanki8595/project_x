import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';

class RequestRepository {
  RequestRepository._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _collection =
      'service_requests';

  // ============================================================
  // CREATE REQUEST
  // ============================================================

  static Future<void> addRequest(
    ServiceRequestModel request,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(request.requestId)
        .set({
      'requestId': request.requestId,
      'customerId': request.customerId,
      'requestTypeId': request.requestTypeId,
      'capabilityId': request.capabilityId,
      'categoryId': request.categoryId,
      'description': request.description,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'urgency': request.urgency,
      'status': request.status,
      'createdAt': Timestamp.fromDate(
        request.createdAt,
      ),
    });
  }

  // ============================================================
  // GET REQUEST
  // ============================================================

  static Future<ServiceRequestModel?> getRequestById(
    String requestId,
  ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(requestId)
        .get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return null;
    }

    return _fromFirestore(
      snapshot.data()!,
    );
  }

  // ============================================================
  // WATCH ALL REQUESTS FOR CUSTOMER (NEW — 2026-08-21)
  // ============================================================
  //
  // Powers the "Upcoming" stage of the rebuilt My Bookings tab --
  // requests still OPEN with no order created yet (still searching
  // for professionals, or waiting for/reviewing quotes), plus
  // anything the customer has directly cancelled pre-order (status
  // 'CANCELLED', surfaced on the Cancelled tab). Requires the new
  // customer-scoped `allow list` rule on service_requests (see
  // firestore.rules) -- this collection previously disallowed
  // list entirely since nothing needed it before now.
  //

  static Stream<List<ServiceRequestModel>> watchRequestsForCustomer(
    String customerId,
  ) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _fromFirestore(doc.data()))
          .toList();
    });
  }

  // ============================================================
  // CANCEL REQUEST (NEW — 2026-08-21)
  // ============================================================
  //
  // Used by the "Cancel" action on the Upcoming tab -- cancelling
  // BEFORE any bid has been accepted, i.e. before an orders/{id}
  // document exists. A plain client-side update, already covered
  // by the existing customer-update rule on service_requests
  // (that rule only guards customerId/requestId staying unchanged,
  // it doesn't restrict which status values are allowed).
  //
  // Cancelling an ALREADY-ACCEPTED order (one that has a real
  // orders/{id} document) is a different, server-side operation --
  // see OrderService.cancelOrder in order_service.dart, which calls
  // the cancelOrder Cloud Function instead.
  //

  static Future<void> cancelRequest(
    String requestId,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(requestId)
        .update({
      'status': 'CANCELLED',
    });
  }

  // ============================================================
  // FIRESTORE → MODEL
  // ============================================================

  static ServiceRequestModel _fromFirestore(
    Map<String, dynamic> data,
  ) {
    return ServiceRequestModel(
      requestId:
          data['requestId'] as String? ?? '',

      customerId:
          data['customerId'] as String? ?? '',

      requestTypeId:
          data['requestTypeId'] as String? ?? '',

      capabilityId:
          data['capabilityId'] as String? ?? '',

      categoryId:
          data['categoryId'] as String? ?? '',

      description:
          data['description'] as String? ?? '',

      latitude:
          (data['latitude'] as num?)
                  ?.toDouble() ??
              0.0,

      longitude:
          (data['longitude'] as num?)
                  ?.toDouble() ??
              0.0,

      urgency:
          data['urgency'] as String? ?? 'NORMAL',

      status:
          data['status'] as String? ?? 'OPEN',

      createdAt:
          _readDate(data['createdAt']),
    );
  }

  // ============================================================
  // SAFE DATE READER
  // ============================================================

  static DateTime _readDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}