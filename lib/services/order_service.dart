import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/order_model.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'orders';

  // ============================================================
  // WATCH ORDER FOR REQUEST
  // ============================================================
  //
  // The acceptBid Cloud Function creates orders/{requestId} -- same
  // document ID as the originating request -- so "the order for
  // this request" and "the order with this ID" are the same
  // lookup. Used by order_status_screen.dart.
  //

  static Stream<OrderModel?> watchOrderForRequest(String requestId) {
    return _firestore
        .collection(_collection)
        .doc(requestId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return OrderModel.fromFirestore(data);
    });
  }

  // ============================================================
  // WATCH ORDER BY ID
  // ============================================================
  //
  // Alias of watchOrderForRequest -- orderId and requestId are
  // always the same value in this schema, kept as a separate
  // method name only for call-site clarity.
  //

  static Stream<OrderModel?> watchOrder(String orderId) {
    return watchOrderForRequest(orderId);
  }

  // ============================================================
  // GET ORDER (ONE-TIME READ)
  // ============================================================

  static Future<OrderModel?> getOrder(String orderId) async {
    final snapshot =
        await _firestore.collection(_collection).doc(orderId).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return OrderModel.fromFirestore(data);
  }

  // ============================================================
  // WATCH ALL ORDERS FOR CUSTOMER (NEW — 2026-08-21)
  // ============================================================
  //
  // Powers the Ongoing / Completed / Cancelled stages of the
  // rebuilt My Bookings tab. Already safely allowed by the existing
  // orders `allow list` rule (customerId == auth.uid) -- no rules
  // change needed for this one, unlike the new service_requests
  // list method in request_repository.dart.
  //

  static Stream<List<OrderModel>> watchOrdersForCustomer(
    String customerId,
  ) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data()))
          .toList();
    });
  }

  // ============================================================
  // CANCEL ORDER (NEW — 2026-08-21)
  // ============================================================
  //
  // Used by the "Cancel" action on the Ongoing tab -- cancelling an
  // order that already exists (CONFIRMED or ACTIVE). Orders are
  // server-write-only (firestore.rules: allow update: if false;),
  // so this calls the cancelOrder Cloud Function rather than
  // writing directly, the same pattern OrderAcceptanceService
  // already uses for acceptBid. See functions/index.js.
  //

  static Future<void> cancelOrder(String orderId) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('cancelOrder');

      await callable.call(<String, dynamic>{
        'orderId': orderId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw StateError(
        e.message ?? 'Unable to cancel this booking right now.',
      );
    }
  }
}