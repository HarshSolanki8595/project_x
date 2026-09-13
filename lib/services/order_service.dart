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
  // WATCH ALL ORDERS FOR CUSTOMER
  // ============================================================
  //
  // Powers the Ongoing / Completed / Cancelled stages of the
  // rebuilt My Bookings tab. Already safely allowed by the existing
  // orders `allow list` rule (customerId == auth.uid).
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
  // CANCEL ORDER
  // ============================================================
  //
  // Used by the "Cancel" action on the Bookings tab's Ongoing
  // stage. Orders are server-write-only, so this calls the
  // cancelOrder Cloud Function rather than writing directly.
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

  // ============================================================
  // PAYMENT (job payment + cancellation fee)
  // ============================================================
  //
  // Moved to RazorpayPaymentService (2026-09-09) -- paying for an
  // order or a cancellation fee now goes through a real Razorpay
  // Checkout flow (createRazorpayOrder + verifyRazorpayPayment Cloud
  // Functions), not a direct call from here. See
  // lib/services/razorpay_payment_service.dart and its call sites in
  // order_status_screen.dart's _PaymentSheet / _CancellationFeeSheet.
  // The old payForOrder/payCancellationFee methods that used to live
  // here called the now-removed MOCKED recordPayment/
  // payCancellationFee Cloud Functions and have been deleted.
  //
}