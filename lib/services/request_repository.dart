import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';

class RequestRepository {
  RequestRepository._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _collection =
      'service_requests';

  // ============================================================
  // CREATE REQUEST
  // ============================================================

  static Future<void> addRequest(
    ServiceRequestModel request,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(request.requestId)
        .set({
      'requestId': request.requestId,
      'customerId': request.customerId,
      'requestTypeId': request.requestTypeId,
      'capabilityId': request.capabilityId,
      'categoryId': request.categoryId,
      'description': request.description,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'urgency': request.urgency,
      'status': request.status,
      'createdAt': Timestamp.fromDate(
        request.createdAt,
      ),
    });
  }

  // ============================================================
  // GET REQUEST
  // ============================================================

  static Future<ServiceRequestModel?> getRequestById(
    String requestId,
  ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(requestId)
        .get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return null;
    }

    return _fromFirestore(
      snapshot.data()!,
    );
  }

  // ============================================================
  // FIRESTORE → MODEL
  // ============================================================

  static ServiceRequestModel _fromFirestore(
    Map<String, dynamic> data,
  ) {
    return ServiceRequestModel(
      requestId:
          data['requestId'] as String? ?? '',

      customerId:
          data['customerId'] as String? ?? '',

      requestTypeId:
          data['requestTypeId'] as String? ?? '',

      capabilityId:
          data['capabilityId'] as String? ?? '',

      categoryId:
          data['categoryId'] as String? ?? '',

      description:
          data['description'] as String? ?? '',

      latitude:
          (data['latitude'] as num?)
                  ?.toDouble() ??
              0.0,

      longitude:
          (data['longitude'] as num?)
                  ?.toDouble() ??
              0.0,

      urgency:
          data['urgency'] as String? ?? 'NORMAL',

      status:
          data['status'] as String? ?? 'OPEN',

      createdAt:
          _readDate(data['createdAt']),
    );
  }

  // ============================================================
  // SAFE DATE READER
  // ============================================================

  static DateTime _readDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}