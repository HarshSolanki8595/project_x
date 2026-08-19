import 'package:cloud_firestore/cloud_firestore.dart';

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
}