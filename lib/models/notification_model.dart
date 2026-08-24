import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// NOTIFICATION MODEL (NEW — 2026-08-23)
// ================================================================
//
// Mirrors users/{userId}/notifications/{notificationId} -- written
// exclusively by various Cloud Functions (Admin SDK). See index.js
// for the full list of events that create one of these: a new
// quote received, job started, job completed, etc.
//

class NotificationModel {
  final String notificationId;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return NotificationModel(
      notificationId: id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? '',
      relatedId: data['relatedId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: _readDate(data['createdAt']),
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}