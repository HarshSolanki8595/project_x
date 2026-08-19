import 'package:cloud_functions/cloud_functions.dart';

import '../models/order_model.dart';

class OrderAcceptanceService {
  // ============================================================
  // CUSTOMER ACCEPTS A BID
  // ============================================================
  //
  // Calls the real acceptBid Cloud Function, which does everything
  // atomically server-side: verifies the caller owns the request,
  // verifies the professional's bid is still BID_SUBMITTED,
  // re-checks the 2-active-orders cap, creates orders/{requestId},
  // marks the opportunity SELECTED, increments the professional's
  // activeOrderCount, and closes every other professional's
  // opportunity for this request. See functions/index.js.
  //

  static Future<OrderModel> acceptBid({
    required String requestId,
    required String professionalId,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('acceptBid');

      final result = await callable.call(<String, dynamic>{
        'requestId': requestId,
        'professionalId': professionalId,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final orderData = Map<String, dynamic>.from(data['order'] as Map);

      return OrderModel.fromCallableResponse(orderData);
    } on FirebaseFunctionsException catch (e) {
      throw StateError(
        e.message ?? 'Unable to accept this offer right now.',
      );
    }
  }
}