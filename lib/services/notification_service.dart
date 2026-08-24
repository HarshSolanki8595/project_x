import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

// ================================================================
// NOTIFICATION SERVICE (NEW — 2026-08-23)
// ================================================================
//
// Reads/updates users/{userId}/notifications -- the collection
// itself was already provisioned in firestore.rules from a much
// earlier session, but nothing ever actually wrote to or read from
// it until this build (see index.js for the Cloud Function writes).
//

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _collection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  // ============================================================
  // WATCH ALL NOTIFICATIONS
  // ============================================================

  static Stream<List<NotificationModel>> watchNotifications(
    String userId,
  ) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => NotificationModel.fromFirestore(doc.id, doc.data()),
          )
          .toList();
    });
  }

  // ============================================================
  // WATCH UNREAD COUNT
  // ============================================================
  //
  // Powers the badge on the bottom nav's Notifications tab.
  //

  static Stream<int> watchUnreadCount(String userId) {
    return _collection(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  static Future<void> markAsRead(
    String userId,
    String notificationId,
  ) async {
    await _collection(userId).doc(notificationId).update({
      'isRead': true,
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  static Future<void> markAllAsRead(String userId) async {
    final snapshot =
        await _collection(userId).where('isRead', isEqualTo: false).get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}