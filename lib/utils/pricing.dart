// ============================================================
// CUSTOMER PRICING -- platform charges + GST math
// ============================================================
//
// Added 2026-09-06 for Harsh's point 7: "when the customer sees
// the quote and accepts the quote it should show what it would
// have to pay at the end." Mirrors calculatePlatformCharges() in
// functions/index.js EXACTLY (PLATFORM_CHARGE_RATE = 0.095,
// GST_RATE = 0.18, customerTotal = agreedPrice +
// customerPlatformCharge + customerGst) so the estimate shown here
// -- before an order even exists, at the moment the customer is
// deciding whether to accept a bid -- matches to the rupee what
// recordPayment will actually charge later. If those rates ever
// change server-side, update them here too -- there is no shared
// source between the two codebases.
// ============================================================

class CustomerPricing {
  static const double platformChargeRate = 0.095;
  static const double gstRate = 0.18;

  final double agreedPrice;
  final double platformCharge;
  final double gst;
  final double total;

  const CustomerPricing._({
    required this.agreedPrice,
    required this.platformCharge,
    required this.gst,
    required this.total,
  });

  factory CustomerPricing.fromAgreedPrice(double agreedPrice) {
    final double platformCharge = agreedPrice * platformChargeRate;
    final double gst = platformCharge * gstRate;

    return CustomerPricing._(
      agreedPrice: agreedPrice,
      platformCharge: platformCharge,
      gst: gst,
      total: agreedPrice + platformCharge + gst,
    );
  }
}
