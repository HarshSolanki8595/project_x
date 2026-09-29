import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../services/notification_router.dart';
import '../services/notification_service.dart';

// ================================================================
// NOTIFICATIONS SCREEN — REWIRED TO REAL DATA (2026-08-23)
// ================================================================
//
// Previously a static "No Notifications Yet" placeholder with zero
// Firestore connection. Now streams real notifications written by
// various Cloud Functions (new quote, job started, job completed,
// etc. -- see index.js). Tapping a notification marks it read; a
// "Mark all read" action is available whenever there are unread
// items.
//
// NAVIGATE ON TAP (rewired 2026-09-27, Harsh's punch-list item #3):
// originally (2026-09-06) only BID_ACCEPTED did anything on tap, and
// that just sent the customer to the Home tab rather than the actual
// booking. Every type now opens the real screen it refers to via
// NotificationRouter (see notification_router.dart), which also
// backs the tap handling for an actual system-tray push notification
// (see main.dart) -- both paths land on the identical screen.
//
// RESPECTS THE "BOOKING UPDATES" SETTING (added 2026-09-16, Harsh:
// "make sure every setting preference is operating and functional"):
// converted from StatelessWidget to StatefulWidget so it can load
// that toggle from SharedPreferences (same key settings_screen.dart
// writes to) and filter kBookingNotificationTypes out of the list --
// every notification type that currently exists in this app falls
// under that set (see notification_service.dart), so turning the
// toggle off empties this screen entirely, with a distinct empty
// state explaining why rather than implying there's simply nothing
// to show. "Mark all read" only marks the still-visible ones, so a
// hidden booking notification correctly stays unread if the toggle
// is turned back on later.
//

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _kBookingKey = 'settings_booking_notifications';

  bool _bookingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _bookingEnabled = prefs.getBool(_kBookingKey) ?? true;
    });
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> all) {
    if (_bookingEnabled) return all;

    return all
        .where((n) => !kBookingNotificationTypes.contains(n.type))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NotificationsScreen.background,
      appBar: AppBar(
        backgroundColor: NotificationsScreen.background,
        foregroundColor: NotificationsScreen.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: NotificationService.watchNotifications(user.uid),
            builder: (context, snapshot) {
              final visible = _applyFilter(snapshot.data ?? const []);
              final unreadIds = visible
                  .where((n) => !n.isRead)
                  .map((n) => n.notificationId)
                  .toList();

              if (unreadIds.isEmpty) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () {
                  NotificationService.markManyAsRead(user.uid, unreadIds);
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: NotificationsScreen.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService.watchNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: NotificationsScreen.primaryBlue,
              ),
            );
          }

          final allNotifications = snapshot.data ?? const [];
          final notifications = _applyFilter(allNotifications);

          if (notifications.isEmpty) {
            // Distinguish "genuinely nothing yet" from "hidden by
            // your own Settings toggle" -- otherwise turning Booking
            // updates off looks identical to having no notifications
            // at all, which is confusing rather than functional.
            final hiddenByToggle =
                !_bookingEnabled && allNotifications.isNotEmpty;
            return _buildEmptyState(hiddenByToggle);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _notificationCard(
                  context,
                  user.uid,
                  notifications[index],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool hiddenByToggle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hiddenByToggle
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              hiddenByToggle ? "Booking Updates Are Off" : "No Notifications Yet",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: NotificationsScreen.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hiddenByToggle
                  ? "Turn Booking updates back on in Settings to see them here."
                  : "You'll receive booking updates here.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: NotificationsScreen.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(
    BuildContext context,
    String userId,
    NotificationModel notification,
  ) {
    final icon = _iconForType(notification.type);

    return Material(
      color: notification.isRead
          ? Colors.white
          : NotificationsScreen.lightBlue,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!notification.isRead) {
            NotificationService.markAsRead(
              userId,
              notification.notificationId,
            );
          }

          // NAVIGATE ON TAP (rewired 2026-09-27, Harsh's punch-list
          // item #3): previously only BID_ACCEPTED did anything, and
          // that just went to Home rather than the actual booking.
          // NotificationRouter fetches the underlying request/order
          // and opens the real screen for every notification type.
          NotificationRouter.open(
            context,
            type: notification.type,
            relatedId: notification.relatedId,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? NotificationsScreen.borderColor
                  : const Color(0xFFD7E2FF),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: NotificationsScreen.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NotificationsScreen.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: NotificationsScreen.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatRelative(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: NotificationsScreen.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 6, top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: NotificationsScreen.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'BID_SUBMITTED':
        return Icons.receipt_long_outlined;
      case 'BID_ACCEPTED':
        return Icons.celebration_outlined;
      case 'JOB_STARTED':
        return Icons.play_circle_outline_rounded;
      case 'JOB_COMPLETED':
        return Icons.check_circle_outline_rounded;
      case 'ORDER_CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
