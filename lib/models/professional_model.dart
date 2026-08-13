class ProfessionalModel {
  // ============================================================
  // PROFESSIONAL ID
  // ============================================================

  final String professionalId;

  // ============================================================
  // COMPATIBILITY ID
  // ============================================================
  //
  // Existing Project X code may still use:
  //
  // professional.id
  //
  // The canonical ID remains professionalId.
  //

  String get id => professionalId;

  // ============================================================
  // PROFESSIONAL NAME
  // ============================================================

  final String name;

  // ============================================================
  // CAPABILITIES
  // ============================================================
  //
  // These IDs define what the professional is capable of doing.
  //
  // Example:
  //
  // AC_REPAIR
  // AC_INSTALLATION
  // AC_SERVICE
  //

  final List<String> capabilityIds;

  // ============================================================
  // ACCOUNT STATUS
  // ============================================================

  final bool isVerified;

  final bool isActive;

  final bool isAvailable;

  // ============================================================
  // LOCATION
  // ============================================================

  final double latitude;

  final double longitude;

  // ============================================================
  // SERVICE RADIUS
  // ============================================================

  final double serviceRadiusKm;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const ProfessionalModel({
    required this.professionalId,
    required this.name,
    required this.capabilityIds,
    required this.isVerified,
    required this.isActive,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.serviceRadiusKm,
  });
}