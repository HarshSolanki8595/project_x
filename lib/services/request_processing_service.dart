import '../models/professional_model.dart';
import '../models/service_request_model.dart';
import 'matching_service.dart';
import 'request_classifier.dart';
import 'request_service.dart';

class MatchingResult {
  final ServiceRequestModel request;
  final List<ProfessionalModel> eligibleProfessionals;

  const MatchingResult({
    required this.request,
    required this.eligibleProfessionals,
  });
}

class RequestProcessingService {
  // ============================================================
  // PROCESS CUSTOMER REQUEST
  // ============================================================
  //
  // Complete flow:
  //
  // Customer text
  //      ↓
  // Classify request
  //      ↓
  // Request Type ID
  //      ↓
  // Capability ID
  //      ↓
  // Create Request ID
  //      ↓
  // Match professionals
  //      ↓
  // Return eligible professionals
  //
  static MatchingResult? processRequest({
    required String customerId,
    required String customerText,
    required double latitude,
    required double longitude,
    String urgency = 'NORMAL',
  }) {
    // ----------------------------------------------------------
    // 1. CLASSIFY CUSTOMER'S WORDS
    // ----------------------------------------------------------

    final RequestClassification? classification =
        RequestClassifier.classify(customerText);

    // We could not understand the request.
    if (classification == null) {
      return null;
    }

    // ----------------------------------------------------------
    // 2. CREATE CUSTOMER REQUEST
    // ----------------------------------------------------------

    final ServiceRequestModel request =
        RequestService.createRequest(
      customerId: customerId,
      requestTypeId: classification.requestTypeId,
      capabilityId: classification.capabilityId,
      description: customerText,
      latitude: latitude,
      longitude: longitude,
      urgency: urgency,
    );

    // ----------------------------------------------------------
    // 3. MATCH ELIGIBLE PROFESSIONALS
    // ----------------------------------------------------------

    final List<ProfessionalModel> professionals =
        MatchingService.matchRequest(request);

    // ----------------------------------------------------------
    // 4. RETURN COMPLETE RESULT
    // ----------------------------------------------------------

    return MatchingResult(
      request: request,
      eligibleProfessionals: professionals,
    );
  }
}