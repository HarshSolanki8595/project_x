import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String requestId;
  final String professionalId;
  final String customerId;
  final String customerName;
  final String customerPhone;

  final String bidId;
  final double agreedPrice;
  final String warranty;

  final String status;

  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.orderId,
    required this.requestId,
    required this.professionalId,
    required this.customerId,
    this.customerName = '',
    this.customerPhone = '',
    required this.bidId,
    required this.agreedPrice,
    this.warranty = '',
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  // ============================================================
  // FROM FIRESTORE
  // ============================================================
  //
  // Used by watchOrderForRequest -- the order document as it
  // actually sits in Firestore (createdAt/startedAt/completedAt as
  // Timestamps).
  //

  factory OrderModel.fromFirestore(Map<String, dynamic> data) {
    return OrderModel(
      orderId: data['orderId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      professionalId: data['professionalId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      bidId: data['bidId'] as String? ?? '',
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble() ?? 0,
      warranty: data['warranty'] as String? ?? '',
      status: data['status'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
      startedAt:
          data['startedAt'] == null ? null : _readDate(data['startedAt']),
      completedAt: data['completedAt'] == null
          ? null
          : _readDate(data['completedAt']),
    );
  }

  // ============================================================
  // FROM CALLABLE RESPONSE
  // ============================================================
  //
  // The acceptBid Cloud Function returns the freshly created order
  // as a plain map in its response -- createdAt there is an ISO
  // date STRING, not a Timestamp, since serverTimestamp() is a
  // write-only sentinel and can't be serialized back to the caller.
  //

  factory OrderModel.fromCallableResponse(Map<String, dynamic> data) {
    return OrderModel(
      orderId: data['orderId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      professionalId: data['professionalId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      bidId: data['bidId'] as String? ?? '',
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble() ?? 0,
      warranty: data['warranty'] as String? ?? '',
      status: data['status'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
      startedAt: null,
      completedAt: null,
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}