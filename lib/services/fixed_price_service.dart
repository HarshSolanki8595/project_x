import 'package:cloud_functions/cloud_functions.dart';

// ================================================================
// FIXED-PRICE SERVICE (customer app) -- Added 2026-09-02
// ================================================================
// Thin wrapper around the raiseFixedPriceOrder Cloud Function, same
// try/catch-and-rethrow pattern as OrderService.cancelOrder /
// OrderService.payForOrder in order_service.dart.
// ================================================================

class FixedPriceService {
  static Future<double> raisePrice({
    required String requestId,
    required double raiseAmount,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('raiseFixedPriceOrder');

      final result = await callable.call(<String, dynamic>{
        'requestId': requestId,
        'raiseAmount': raiseAmount,
      });

      final data = Map<String, dynamic>.from(result.data as Map);

      return (data['postedPrice'] as num).toDouble();
    } on FirebaseFunctionsException catch (e) {
      throw StateError(
        e.message ?? 'Unable to raise the price right now.',
      );
    }
  }
}
