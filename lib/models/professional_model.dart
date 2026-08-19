import 'package:cloud_firestore/cloud_firestore.dart';

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
  // PHONE NUMBER
  // ============================================================
  //
  // Used by OrderStatusScreen's call button. Optional/defaults to
  // '' so existing call sites that construct ProfessionalModel
  // without it keep compiling unchanged.
  //

  final String phoneNumber;

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
    this.phoneNumber = '',
    required this.capabilityIds,
    required this.isVerified,
    required this.isActive,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.serviceRadiusKm,
  });

  // ============================================================
  // FROM FIRESTORE
  // ============================================================
  //
  // Used by ProfessionalFirestoreService (customer side, read-only)
  // to build a ProfessionalModel from a `professionals/{id}` doc.
  //

  factory ProfessionalModel.fromFirestore(Map<String, dynamic> data) {
    return ProfessionalModel(
      professionalId: data['professionalId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      capabilityIds: (data['capabilityIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isVerified: data['isVerified'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? false,
      isAvailable: data['isAvailable'] as bool? ?? false,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      serviceRadiusKm: (data['serviceRadiusKm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}