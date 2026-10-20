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

  // ============================================================
  // FIRST-ORDERS PLATFORM FEE WAIVER (2026-09-27, Harsh's point 11)
  // ============================================================
  //
  // Mirrors FIRST_ORDERS_FEE_WAIVER_COUNT in functions/index.js: a
  // customer's first this-many paid (IN_APP) orders have Platform
  // Charges + GST waived entirely. The actual charge is always
  // decided authoritatively server-side at payment time -- this
  // constant exists purely so screens shown BEFORE that point (the
  // "Accept This Offer" and "Order Confirmed" previews on
  // professionals_screen.dart) can preview the same offer the real
  // payment screen already honors. If this number ever changes
  // server-side, update it here too -- there is no shared source
  // between the two codebases, same caveat as the rates above.
  //
  //
  // RETIRED 2026-10-07 (Harsh: "clear the offer program"): the automatic
  // first-orders offer no longer exists, so this is 0 and nobody is
  // previewed as waived. An admin can still grant an individual customer
  // extra fee-free orders (users/{uid}.extraFeeWaivers).
  static const int firstOrdersFeeWaiverCount = 0;

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
