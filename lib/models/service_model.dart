class ServiceModel {
  final String id;
  final String capabilityId;
  final String name;
  final String description;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.capabilityId,
    required this.name,
    required this.description,
    this.isActive = true,
  });
}