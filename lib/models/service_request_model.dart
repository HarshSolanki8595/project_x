class ServiceRequestModel {
  final String requestId;
  final String customerId;

  // Specific problem/request identified by Project X.
  final String requestTypeId;

  // Broad capability required to handle the request.
  final String capabilityId;

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
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.urgency,
    required this.status,
    required this.createdAt,
  });
}