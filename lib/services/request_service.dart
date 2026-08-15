import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';
import 'request_repository.dart';

class RequestService {
  // ============================================================
  // NOTE ON REQUEST ID GENERATION
  // ============================================================
  //
  // The previous implementation used a local, in-memory counter
  // (`_requestCounter`) to build IDs like REQ_000001. That counter
  // resets to 1 every time the app restarts and is not shared
  // across devices or users, so two different customers (or the
  // same customer across two sessions) could generate the SAME
  // requestId. Since Firestore writes to a specific document ID
  // silently overwrite whatever was there before, this could
  // cause one customer's request to overwrite another's.
  //
  // This version uses Firestore's own collision-proof auto-ID
  // instead, which is guaranteed unique.
  //

  static Future<ServiceRequestModel> createRequest({
    required String customerId,
    required String requestTypeId,
    required String capabilityId,
    required String description,
    required double latitude,
    required double longitude,
    String urgency = 'NORMAL',
  }) async {
    // ----------------------------------------------------------
    // GENERATE A UNIQUE REQUEST ID
    // ----------------------------------------------------------

    final String requestId = FirebaseFirestore.instance
        .collection('service_requests')
        .doc()
        .id;

    final ServiceRequestModel request = ServiceRequestModel(
      requestId: requestId,
      customerId: customerId,
      requestTypeId: requestTypeId,
      capabilityId: capabilityId,
      description: description,
      latitude: latitude,
      longitude: longitude,
      urgency: urgency,
      status: 'OPEN',
      createdAt: DateTime.now(),
    );

    await RequestRepository.addRequest(
      request,
    );

    return request;
  }
}
