class ProfessionalBidModel {
  final String bidId;
  final String requestId;
  final String professionalId;

  final double quotedPrice;
  final String estimatedTime;
  final String message;

  final String status;
  final DateTime createdAt;

  const ProfessionalBidModel({
    required this.bidId,
    required this.requestId,
    required this.professionalId,
    required this.quotedPrice,
    required this.estimatedTime,
    required this.message,
    required this.status,
    required this.createdAt,
  });
}