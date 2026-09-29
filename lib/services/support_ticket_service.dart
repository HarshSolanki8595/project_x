import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/support_ticket_model.dart';

// ================================================================
// SUPPORT TICKET SERVICE (NEW — 2026-09-17)
// ================================================================
//
// Backs support_tickets/{uid} -- a thin category/status wrapper
// around the existing support_chats/{uid}/messages thread. Built
// per Harsh's request to "layer a ticketing system before the chat
// begins," without touching the chat itself:
//
//   * openTicket() runs the moment a customer picks a category on
//     the Help & Support triage sheet (see profile_screen.dart),
//     right before the chat screen opens. It creates the ticket on
//     first use, or retags an existing one, always leaving it in
//     status 'OPEN' -- picking a category always means "I have
//     something new/still open."
//
//   * reopenIfResolved() runs every time a message is actually sent
//     (see support_chat_service.dart's sendMessage()), so a
//     Resolved ticket a customer messages into again automatically
//     re-enters the admin's queue, without the customer having to
//     do anything else.
//
// firestore.rules only ever lets the owner write themselves back
// into status 'OPEN' -- moving a ticket to 'IN_PROGRESS' or
// 'RESOLVED' is admin-only, from the admin panel's Support Tickets
// screen.
//

class SupportTicketService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'support_tickets';

  static DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.collection(_collection).doc(uid);
  }

  // ============================================================
  // WATCH THE SIGNED-IN CUSTOMER'S OWN TICKET
  // ============================================================

  static Stream<SupportTicketModel?> watchTicket(String uid) {
    return _doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return SupportTicketModel.fromFirestore(snapshot.data()!);
    });
  }

  // ============================================================
  // OPEN / RETAG A TICKET (triage step, before the chat opens)
  // ============================================================

  static Future<void> openTicket({
    required String uid,
    required String category,
    required String categoryLabel,
  }) async {
    final ref = _doc(uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        'ticketId': uid,
        'accountType': 'CUSTOMER',
        'category': category,
        'categoryLabel': categoryLabel,
        'status': 'OPEN',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await ref.update({
      'category': category,
      'categoryLabel': categoryLabel,
      'status': 'OPEN',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REOPEN A RESOLVED TICKET (called from sendMessage())
  // ============================================================

  static Future<void> reopenIfResolved(String uid) async {
    final ref = _doc(uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      // No ticket at all yet -- e.g. the customer sent their first
      // message straight from an old bookmark/deep link rather than
      // through the triage sheet. Create a General one so the admin
      // panel's queue still sees it.
      await ref.set({
        'ticketId': uid,
        'accountType': 'CUSTOMER',
        'category': 'general',
        'categoryLabel': 'General enquiry',
        'status': 'OPEN',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final status = snapshot.data()?['status'] as String?;
    if (status == 'RESOLVED') {
      await ref.update({
        'status': 'OPEN',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
