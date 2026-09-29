import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

// ================================================================
// BOOKING NOTIFICATION TYPES (added 2026-09-16)
// ================================================================
//
// Every `type` a notification document currently comes as -- see
// index.js for where each is written (matchServiceRequest,
// acceptBid, startJob, completeJob, cancelOrder, etc.) and
// notifications_screen.dart's own _iconForType, which already
// switches on this exact same set. All of them are booking/order
// events; there is no "message" or "promotional" notification type
// anywhere in this app yet (support chat is a separate live thread,
// not a notification-feed entry -- see support_chat_service.dart).
//
// This is the single shared definition of "what counts as a booking
// update" so the Settings screen's "Booking updates" toggle,
// notifications_screen.dart's list, and main_navigation_screen.dart's
// unread badge/bell-dot all agree on exactly the same set instead of
// three separately-maintained copies drifting apart.
//

const Set<String> kBookingNotificationTypes = {
  'BID_SUBMITTED',
  'BID_ACCEPTED',
  'JOB_STARTED',
  'JOB_COMPLETED',
  'ORDER_CANCELLED',
};

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

  // ============================================================
  // MARK MANY AS READ (added 2026-09-16)
  // ============================================================
  //
  // Same batch pattern as markAllAsRead, but restricted to a given
  // set of ids -- used when "Booking updates" is turned off in
  // Settings, so "Mark all read" on the (now filtered) Notifications
  // screen only marks the notifications actually still visible, and
  // doesn't quietly mark hidden booking notifications read behind
  // the customer's back (they'd stay correctly unread if the toggle
  // is turned back on later).
  //

  static Future<void> markManyAsRead(
    String userId,
    List<String> notificationIds,
  ) async {
    if (notificationIds.isEmpty) return;

    final batch = _firestore.batch();

    for (final id in notificationIds) {
      batch.update(_collection(userId).doc(id), {'isRead': true});
    }

    await batch.commit();
  }

  // ============================================================
  // REGISTER DEVICE TOKEN FOR PUSH (NEW — 2026-09-27)
  // ============================================================
  //
  // Stores this device's FCM token on the signed-in customer's own
  // users/{uid} document (arrayUnion, so a customer signed in on
  // multiple devices gets a push on all of them). Called right
  // after every successful sign-in (login_screen.dart's
  // _routeAfterVerification, otp_screen.dart's verifyOtp) and once
  // more on a warm relaunch with an existing session
  // (splash_screen.dart), plus whenever the token itself rotates
  // (main.dart's onTokenRefresh listener). Best-effort: a customer
  // who denies the notification permission, or on a device with no
  // Google Play Services, simply never gets a token stored here —
  // the rest of the app is unaffected either way. See
  // functions/index.js's createNotification(), which reads this
  // same field to actually send the push.
  //

  static Future<void> registerDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _firestore.collection('users').doc(user.uid).set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Best-effort — never blocks sign-in or app launch.
    }
  }
}