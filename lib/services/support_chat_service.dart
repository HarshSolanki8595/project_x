import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/support_message_model.dart';
import 'support_ticket_service.dart';

// ================================================================
// SUPPORT CHAT SERVICE (NEW — 2026-08-29)
// ================================================================
//
// Backs the "Help & Support" chat screen. Each customer has their
// own thread at support_chats/{customerId}/messages -- a simple
// intake queue a customer can message into, visible to whoever
// handles support (via the Firebase console) until a real admin
// panel exists. firestore.rules restricts a customer to only ever
// reading/writing their OWN thread, and only ever as senderType
// 'CUSTOMER' -- see the `support_chats` match block.
//
// UPDATED — 2026-09-17: sendMessage() now also calls
// SupportTicketService.reopenIfResolved() -- see that file's header
// comment. This is the thin ticket/status layer Harsh asked to be
// put in front of this same chat; the chat's own schema/behavior
// above is otherwise unchanged.
//

class SupportChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'support_chats';

  static CollectionReference<Map<String, dynamic>> _messages(
    String customerId,
  ) {
    return _firestore
        .collection(_collection)
        .doc(customerId)
        .collection('messages');
  }

  // ============================================================
  // WATCH MESSAGES FOR THE SIGNED-IN CUSTOMER
  // ============================================================

  static Stream<List<SupportMessageModel>> watchMessages(String customerId) {
    return _messages(customerId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SupportMessageModel.fromFirestore(doc.data()))
          .toList();
    });
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  static Future<void> sendMessage(String text) async {
    final customerId = FirebaseAuth.instance.currentUser?.uid;

    if (customerId == null) {
      throw StateError('You must be signed in to message support.');
    }

    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      return;
    }

    final docRef = _messages(customerId).doc();

    try {
      await docRef.set({
        'messageId': docRef.id,
        'senderId': customerId,
        'senderType': 'CUSTOMER',
        'text': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw StateError(
        e.message ?? 'Unable to send your message right now.',
      );
    }

    // Best-effort: if this thread's ticket was previously marked
    // Resolved, sending a new message reopens it so it re-enters the
    // admin's queue. Never allowed to fail the send itself, which
    // has already succeeded above.
    try {
      await SupportTicketService.reopenIfResolved(customerId);
    } catch (_) {
      // Ticket bookkeeping only -- the message itself already sent.
    }
  }
}
