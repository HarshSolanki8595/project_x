import '../models/service_request_model.dart';

class RequestData {
  static final List<ServiceRequestModel> requests = [
    ServiceRequestModel(
      requestId: 'REQ_000001',
      customerId: 'CUST_000001',

      // Specific customer problem.
      requestTypeId: 'AC_REPAIR_NOT_COOLING',

      // Broad professional capability required.
      capabilityId: 'AC_REPAIR',

      description: 'My AC is running but it is not cooling properly.',

      latitude: 19.0760,
      longitude: 72.8777,

      urgency: 'NORMAL',
      status: 'OPEN',

      createdAt: DateTime.now(),
    ),
  ];
}