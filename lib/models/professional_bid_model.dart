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

  // Name of the employee the professional is sending to fulfill this
  // job -- Business (GST) registrations only, added 2026-09-04.
  // Collected on the professional app's quote screen and required
  // there when the submitting professional is Business-registered;
  // null for Individual professionals and for any bid submitted
  // before this existed.
  final String? employeeName;

  // Firebase Storage download URL for the optional voice note a
  // professional records explaining their diagnosis, attached
  // alongside the now-mandatory `message` field above -- added
  // 2026-10-02. Null when no voice note was recorded, and for any
  // bid submitted before this existed. Shown on the bid card in
  // professionals_screen.dart alongside `message`.
  final String? diagnosisVoiceNoteUrl;

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
    this.employeeName,
    this.diagnosisVoiceNoteUrl,
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