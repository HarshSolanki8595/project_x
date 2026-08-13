import '../models/service_model.dart';

class ServiceData {
  static const List<ServiceModel> services = [
    // =========================
    // AC REPAIR
    // =========================

    ServiceModel(
      id: 'AC_REPAIR_NOT_COOLING',
      capabilityId: 'AC_REPAIR',
      name: 'AC Not Cooling',
      description: 'AC is running but not providing sufficient cooling.',
    ),

    ServiceModel(
      id: 'AC_REPAIR_WATER_LEAKAGE',
      capabilityId: 'AC_REPAIR',
      name: 'AC Water Leakage',
      description: 'AC is leaking or dripping water.',
    ),

    ServiceModel(
      id: 'AC_REPAIR_STRANGE_NOISE',
      capabilityId: 'AC_REPAIR',
      name: 'AC Strange Noise',
      description: 'AC is making unusual or abnormal sounds.',
    ),

    ServiceModel(
      id: 'AC_REPAIR_NOT_STARTING',
      capabilityId: 'AC_REPAIR',
      name: 'AC Not Starting',
      description: 'AC is not switching on or starting.',
    ),

    // =========================
    // AC SERVICE
    // =========================

    ServiceModel(
      id: 'AC_SERVICE',
      capabilityId: 'AC_SERVICE',
      name: 'AC Service',
      description: 'Routine AC cleaning and servicing.',
    ),

    // =========================
    // AC INSTALLATION
    // =========================

    ServiceModel(
      id: 'AC_INSTALLATION',
      capabilityId: 'AC_INSTALLATION',
      name: 'AC Installation',
      description: 'Installation of a new AC unit.',
    ),
  ];

  static ServiceModel? getServiceById(String serviceId) {
    try {
      return services.firstWhere(
        (service) => service.id == serviceId,
      );
    } catch (_) {
      return null;
    }
  }
}