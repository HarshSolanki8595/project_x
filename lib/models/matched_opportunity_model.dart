class MatchedOpportunityModel {
  final String opportunityId;
  final String requestId;
  final String professionalId;

  final String status;
  final DateTime createdAt;

  const MatchedOpportunityModel({
    required this.opportunityId,
    required this.requestId,
    required this.professionalId,
    required this.status,
    required this.createdAt,
  });
}