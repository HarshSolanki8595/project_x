import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// MODERATION FIELDS (NEW -- 2026-10-03)
// ================================================================
//
// `isHidden`/`hiddenReason`/`hiddenByName`/`hiddenAt` and
// `platformReply`/`platformReplyByName`/`platformRepliedAt` are
// admin-panel-only writes (see firestore.rules' "ADMIN REVIEW
// MODERATION" block) -- a review itself is still only ever created
// by the customer, never edited by them. This app reads these
// fields to hide a moderated review from the public profile list
// and to show a platform reply underneath a review that has one.
// ================================================================

class ReviewModel {
  final String reviewId;
  final String orderId;
  final String requestId;
  final String customerId;
  final String professionalId;

  final int rating;
  final String comment;

  final DateTime createdAt;

  final bool isHidden;
  final String? hiddenReason;
  final String? hiddenByName;
  final DateTime? hiddenAt;

  final String? platformReply;
  final String? platformReplyByName;
  final DateTime? platformRepliedAt;

  const ReviewModel({
    required this.reviewId,
    required this.orderId,
    required this.requestId,
    required this.customerId,
    required this.professionalId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isHidden = false,
    this.hiddenReason,
    this.hiddenByName,
    this.hiddenAt,
    this.platformReply,
    this.platformReplyByName,
    this.platformRepliedAt,
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
      isHidden: data['isHidden'] as bool? ?? false,
      hiddenReason: data['hiddenReason'] as String?,
      hiddenByName: data['hiddenByName'] as String?,
      hiddenAt: data['hiddenAt'] == null ? null : _readDate(data['hiddenAt']),
      platformReply: data['platformReply'] as String?,
      platformReplyByName: data['platformReplyByName'] as String?,
      platformRepliedAt: data['platformRepliedAt'] == null
          ? null
          : _readDate(data['platformRepliedAt']),
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