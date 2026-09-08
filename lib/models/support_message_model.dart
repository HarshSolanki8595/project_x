import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// SUPPORT MESSAGE MODEL (NEW — 2026-08-29)
// ================================================================
//
// One message in a customer's support thread with the Habio team.
// senderType is always 'CUSTOMER' today -- there is no admin panel
// yet (deliberately deferred until both apps are "finalised", per
// standing product decision), so nothing writes a 'SUPPORT' message
// back into Firestore. This model still carries senderType so the
// UI and firestore.rules are ready for that the day a real support
// reply channel exists, without another schema change.
//

class SupportMessageModel {
  final String messageId;
  final String senderId;
  final String senderType;
  final String text;
  final DateTime createdAt;

  const SupportMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderType,
    required this.text,
    required this.createdAt,
  });

  bool get isFromCustomer => senderType == 'CUSTOMER';

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderType': senderType,
      'text': text,
    };
  }

  factory SupportMessageModel.fromFirestore(Map<String, dynamic> data) {
    return SupportMessageModel(
      messageId: data['messageId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderType: data['senderType'] as String? ?? 'CUSTOMER',
      text: data['text'] as String? ?? '',
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
