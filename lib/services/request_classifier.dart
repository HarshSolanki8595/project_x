import '../data/service_data.dart';
import '../models/service_model.dart';

class RequestClassification {
  final String requestTypeId;
  final String capabilityId;
  final String categoryId;

  const RequestClassification({
    required this.requestTypeId,
    required this.capabilityId,
    this.categoryId = '',
  });
}

class RequestClassifier {
  // ============================================================
  // CLASSIFY CUSTOMER DESCRIPTION
  // ============================================================
  //
  // Converts the customer's words into:
  //
  // Request Type ID (specific problem, for display only)
  // +
  // Capability ID (what matching actually queries on)
  //
  // IMPORTANT: capabilityId must use the SAME ids professionals
  // register under in onboarding (ProfessionalServiceCategories /
  // subcategoryIds — e.g. "air_conditioner"), not a separate
  // classifier-only vocabulary. It used to return values like
  // "AC_REPAIR"/"AC_INSTALLATION" that no professional's
  // subcategoryIds could ever contain, so matching silently found
  // zero professionals for every free-text request.
  //
  // Example:
  //
  // "My AC is not cooling"
  //
  //        ↓
  //
  // AC_REPAIR_NOT_COOLING (requestTypeId, descriptive)
  //        +
  // air_conditioner (capabilityId, matched against professionals)
  //
  static RequestClassification? classify(
    String customerText,
  ) {
    final String text = customerText.toLowerCase().trim();

    if (text.isEmpty) {
      return null;
    }

    // ==========================================================
    // AC DETECTION
    // ==========================================================
    //
    // We first determine whether the request is related to AC.
    //
    final bool isACRequest =
        text.contains('ac') ||
        text.contains('air conditioner') ||
        text.contains('air conditioning') ||
        text.contains('airconditioner');

    if (!isACRequest) {
      return null;
    }

    // ==========================================================
    // AC INSTALLATION
    // ==========================================================

    if (_containsAny(text, [
      'install',
      'installation',
      'new ac',
      'fit ac',
      'fitting ac',
      'setup ac',
      'set up ac',
    ])) {
      return const RequestClassification(
        requestTypeId: 'AC_INSTALLATION',
        capabilityId: 'air_conditioner',
        categoryId: 'appliances',
      );
    }

    // ==========================================================
    // AC SERVICE
    // ==========================================================

    if (_containsAny(text, [
      'service',
      'servicing',
      'clean ac',
      'cleaning ac',
      'maintenance',
      'maintain ac',
    ])) {
      return const RequestClassification(
        requestTypeId: 'AC_SERVICE',
        capabilityId: 'air_conditioner',
        categoryId: 'appliances',
      );
    }

    // ==========================================================
    // AC NOT COOLING
    // ==========================================================

    if (_containsAny(text, [
      'not cooling',
      'no cooling',
      'not cold',
      'not getting cold',
      'not getting cool',
      'room is not cooling',
      'room not cooling',
      'cooling is not working',
      'cooling stopped',
      'cooling problem',
    ])) {
      return const RequestClassification(
        requestTypeId: 'AC_REPAIR_NOT_COOLING',
        capabilityId: 'air_conditioner',
        categoryId: 'appliances',
      );
    }

    // ==========================================================
    // AC WATER LEAKAGE
    // ==========================================================

    if (_containsAny(text, [
      'water leaking',
      'water leakage',
      'leaking water',
      'ac leaking',
      'ac is leaking',
      'water dripping',
      'water drop',
      'dripping water',
    ])) {
      return const RequestClassification(
        requestTypeId: 'AC_REPAIR_WATER_LEAKAGE',
        capabilityId: 'air_conditioner',
        categoryId: 'appliances',
      );
    }

    // ==========================================================
    // AC STRANGE NOISE
    // ==========================================================

    if (_containsAny(text, [
      'strange noise',
      'weird noise',
      'making noise',
      'making a noise',
      'loud noise',
      'sound from ac',
      'noise from ac',
      'ac is noisy',
      'ac making sound',
    ])) {
      return const RequestClassification(
        requestTypeId: 'AC_REPAIR_STRANGE_NOISE',
        capabilityId: 'air_conditioner',
        categoryId: 'appliances',
      );
    }

    // ==========================================================
    // AC NOT STARTING
    // ==========================================================

    if (_containsAny(text, [
      'not starting',
      'not turning on',
      'does not turn on',
      'wont turn on',
      "won't turn on",
      'not switching on',
      'does not switch on',
      'ac is dead',
      'ac stopped working',
      'ac not working',
    ])) {
      return const RequestClassification(
        requestTypeId: 'AC_REPAIR_NOT_STARTING',
        capabilityId: 'air_conditioner',
        categoryId: 'appliances',
      );
    }

    // ==========================================================
    // GENERIC AC PROBLEM
    // ==========================================================
    //
    // This is important.
    //
    // If the customer clearly has an AC problem but we don't
    // understand the exact problem, we should NOT reject the
    // request simply because the wording is unfamiliar.
    //
    // We send it to the broad AC_REPAIR capability.
    //

    return const RequestClassification(
      requestTypeId: 'AC_REPAIR_OTHER',
      capabilityId: 'air_conditioner',
      categoryId: 'appliances',
    );
  }

  // ============================================================
  // KEYWORD HELPER
  // ============================================================

  static bool _containsAny(
    String text,
    List<String> keywords,
  ) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // GET SERVICE INFORMATION
  // ============================================================

  static ServiceModel? getServiceForClassification(
    RequestClassification classification,
  ) {
    return ServiceData.getServiceById(
      classification.requestTypeId,
    );
  }
}