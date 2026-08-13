import '../models/service_request_model.dart';

class RequestService {
  static int _requestCounter = 1;

  static ServiceRequestModel createRequest({
    required String customerId,
    required String requestTypeId,
    required String capabilityId,
    required String description,
    required double latitude,
    required double longitude,
    String urgency = 'NORMAL',
  }) {
    final String requestId =
        'REQ_${_requestCounter.toString().padLeft(6, '0')}';

    _requestCounter++;

    return ServiceRequestModel(
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
  }
}