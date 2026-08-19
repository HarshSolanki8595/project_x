class ProfessionalBidModel {
  final String bidId;
  final String requestId;
  final String professionalId;

  final double servicePrice;
  final double materialsCost;
  final double visitInspectionCost;
  final double urgencyCost;

  final String warranty;
  final String additionalWork;
  final String message;

  final String status;
  final DateTime createdAt;

  const ProfessionalBidModel({
    required this.bidId,
    required this.requestId,
    required this.professionalId,
    required this.servicePrice,
    required this.materialsCost,
    required this.visitInspectionCost,
    required this.urgencyCost,
    required this.warranty,
    required this.additionalWork,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  // ============================================================
  // TOTAL PRICE
  // ============================================================
  //
  // Same sum ProfessionalQuoteScreen already shows the professional
  // before they submit -- kept here too so any screen displaying a
  // bid (professionals_screen.dart) doesn't need to recompute it.
  //

  double get totalPrice =>
      servicePrice + materialsCost + visitInspectionCost + urgencyCost;
}