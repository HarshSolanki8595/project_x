import '../models/professional_model.dart';

class ProfessionalData {
  static final List<ProfessionalModel> professionals = [
    // ==========================================================
    // PROFESSIONAL 1
    // ==========================================================

    ProfessionalModel(
      professionalId: 'PRO_000001',
      name: 'Rajesh Kumar',
      capabilityIds: [
        'AC_REPAIR',
      ],
      isVerified: true,
      isActive: true,
      isAvailable: true,
      latitude: 19.0760,
      longitude: 72.8777,
      serviceRadiusKm: 15,
    ),

    // ==========================================================
    // PROFESSIONAL 2
    // ==========================================================

    ProfessionalModel(
      professionalId: 'PRO_000002',
      name: 'Amit Services',
      capabilityIds: [
        'AC_INSTALLATION',
        'AC_REPAIR',
      ],
      isVerified: true,
      isActive: true,
      isAvailable: true,
      latitude: 19.0820,
      longitude: 72.8850,
      serviceRadiusKm: 15,
    ),

    // ==========================================================
    // PROFESSIONAL 3
    // ==========================================================

    ProfessionalModel(
      professionalId: 'PRO_000003',
      name: 'Suresh Cooling Solutions',
      capabilityIds: [
        'AC_REPAIR',
      ],
      isVerified: true,
      isActive: true,
      isAvailable: true,
      latitude: 19.0650,
      longitude: 72.8700,
      serviceRadiusKm: 15,
    ),
  ];
}