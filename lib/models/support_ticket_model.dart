import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// SUPPORT TICKET MODEL (NEW — 2026-09-17)
// ================================================================
//
// A thin category/status wrapper around the customer's own
// support_chats/{uid}/messages thread -- NOT a second chat system.
// One ticket per customer, same document id as their chat thread
// (their own uid), created/updated by SupportTicketService the
// moment they pick a category on the Help & Support triage sheet.
// See support_ticket_service.dart's header comment for the full
// lifecycle, and firestore.rules' "SUPPORT TICKETS" section for
// exactly what a customer is and isn't allowed to write to their
// own ticket.
//

class SupportTicketModel {
  final String ticketId;
  final String accountType;
  final String category;
  final String categoryLabel;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportTicketModel({
    required this.ticketId,
    required this.accountType,
    required this.category,
    required this.categoryLabel,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOpen => status == 'OPEN';

  bool get isInProgress => status == 'IN_PROGRESS';

  bool get isResolved => status == 'RESOLVED';

  factory SupportTicketModel.fromFirestore(Map<String, dynamic> data) {
    return SupportTicketModel(
      ticketId: data['ticketId'] as String? ?? '',
      accountType: data['accountType'] as String? ?? 'CUSTOMER',
      category: data['category'] as String? ?? 'general',
      categoryLabel: data['categoryLabel'] as String? ?? 'General enquiry',
      status: data['status'] as String? ?? 'OPEN',
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
