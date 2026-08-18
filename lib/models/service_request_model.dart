class ServiceRequestModel {
  final String requestId;
  final String customerId;

  // Specific problem/request identified by Project X.
  final String requestTypeId;

  // Broad capability required to handle the request.
  final String capabilityId;

  // Main category the capability belongs to (e.g. "appliances").
  // Used as a fallback match when no professional's subcategoryIds
  // exactly contains capabilityId, so a customer request isn't
  // dropped just because the professional described their trade
  // slightly differently.
  final String categoryId;

  final String description;

  final double latitude;
  final double longitude;

  final String urgency;
  final String status;

  final DateTime createdAt;

  const ServiceRequestModel({
    required this.requestId,
    required this.customerId,
    required this.requestTypeId,
    required this.capabilityId,
    this.categoryId = '',
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.urgency,
    required this.status,
    required this.createdAt,
  });
}