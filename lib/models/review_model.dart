import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String orderId;
  final String requestId;
  final String customerId;
  final String professionalId;

  final int rating;
  final String comment;

  final DateTime createdAt;

  const ReviewModel({
    required this.reviewId,
    required this.orderId,
    required this.requestId,
    required this.customerId,
    required this.professionalId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'orderId': orderId,
      'requestId': requestId,
      'customerId': customerId,
      'professionalId': professionalId,
      'rating': rating,
      'comment': comment,
    };
  }

  factory ReviewModel.fromFirestore(Map<String, dynamic> data) {
    return ReviewModel(
      reviewId: data['reviewId'] as String? ?? '',
      orderId: data['orderId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      professionalId: data['professionalId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}