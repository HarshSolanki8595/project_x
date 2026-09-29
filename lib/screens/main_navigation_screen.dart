import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/widgets/bottom_nav_bar.dart';
import '../services/notification_service.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'policy_acceptance_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // ============================================================
  // HOME FLYER BANNER SELECTION -- added 2026-09-13
  // ============================================================
  //
  // HomeScreen sits inside the IndexedStack below and is only ever
  // built once per app launch, so its own initState wouldn't re-run
  // each time the customer switches back to the Home tab. This
  // screen owns the bottom nav tap handler, so it's what re-picks 3
  // of the 11 flyers (kHomeFlyers, in home_screen.dart) every time
  // the customer actually lands on Home, then hands the fresh list
  // down to HomeScreen as a constructor param.
  //

  late List<FlyerContent> _flyerSelection = _pickFlyers();

  List<FlyerContent> _pickFlyers() {
    final shuffled = List<FlyerContent>.from(kHomeFlyers)..shuffle(Random());
    return shuffled.take(3).toList();
  }

  // ============================================================
  // SETTINGS-DRIVEN NOTIFICATION BEHAVIOR -- added 2026-09-16
  // ============================================================
  //
  // Same two SharedPreferences keys the Settings screen writes to
  // (settings_booking_notifications, settings_sound_notifications).
  // This screen is the single long-lived host for the bottom-nav
  // badge / home-screen bell dot AND for playing a sound when a new
  // notification arrives, so both live here rather than being
  // duplicated per-tab. Reloaded on every tab switch so a change
  // made on the Settings tab takes effect the moment the customer
  // leaves it, without needing to restart the app.
  //

  static const String _kBookingKey = 'settings_booking_notifications';
  static const String _kSoundKey = 'settings_sound_notifications';

  bool _bookingNotificationsEnabled = true;
  bool _soundNotificationsEnabled = true;

  StreamSubscription<QuerySnapshot>? _unreadWatchSub;
  int? _lastKnownUnreadCount;
  String? _soundListenerUid;

  // ============================================================
  // POLICY ACCEPTANCE GATE -- added 2026-09-27 (Harsh's point 13)
  // ============================================================
  //
  // "...this should appear as soon as they land the homepage after
  // OTP is verified and before ... any other pop on even if
  // established later on customer app."
  //
  // Checked here, at this root shell level, so it resolves BEFORE any
  // of the four tabs (Home/Bookings/Notifications/Profile) below are
  // ever built -- see the gate in build() below. That structurally
  // guarantees this appears before any popup a screen inside the
  // IndexedStack shows now or shows in the future, without needing to
  // coordinate with each screen individually.
  //
  // null = still checking Firestore, true = already accepted the
  // current PolicyAcceptanceScreen.currentVersion, false = needs to
  // accept (or hasn't accepted this version yet).
  //

  bool? _policyAccepted;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
    _checkPolicyAcceptance();
  }

  Future<void> _checkPolicyAcceptance() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // build() already shows its own spinner while user == null and
      // re-runs once it's set -- nothing to do here yet.
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final acceptedVersion = doc.data()?['policyAcceptedVersion'] as String?;

      if (!mounted) return;

      setState(() {
        _policyAccepted =
            acceptedVersion == PolicyAcceptanceScreen.currentVersion;
      });
    } catch (_) {
      // Couldn't reach Firestore -- default to showing the gate rather
      // than silently skipping it, since letting someone past an
      // un-accepted policy is the worse failure mode.
      if (mounted) {
        setState(() {
          _policyAccepted = false;
        });
      }
    }
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _bookingNotificationsEnabled = prefs.getBool(_kBookingKey) ?? true;
      _soundNotificationsEnabled = prefs.getBool(_kSoundKey) ?? true;
    });
  }

  // Separate from the StreamBuilder below on purpose -- that one
  // drives what's drawn on screen every rebuild, while this is a
  // one-shot-per-arrival side effect (playing a sound) that should
  // NOT re-fire just because the widget tree rebuilds for an
  // unrelated reason.
  void _ensureSoundListener(String uid) {
    if (_soundListenerUid == uid) return;

    _unreadWatchSub?.cancel();
    _soundListenerUid = uid;
    _lastKnownUnreadCount = null;

    _unreadWatchSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      final count = snapshot.docs.length;

      // Skip the very first reading (app just opened / user just
      // logged in) -- otherwise every launch with existing unread
      // notifications would play a sound immediately, which isn't
      // a "new" arrival.
      if (_lastKnownUnreadCount != null &&
          count > _lastKnownUnreadCount! &&
          _soundNotificationsEnabled) {
        SystemSound.play(SystemSoundType.alert);
      }

      _lastKnownUnreadCount = count;
    });
  }

  @override
  void dispose() {
    _unreadWatchSub?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Pick up any Settings changes the moment the customer switches
    // tabs, so toggling a preference and coming back reflects it
    // right away instead of needing an app restart.
    _loadNotificationPreferences();

    setState(() {
      // Landing on Home from another tab -- re-pick 3 of the 11
      // flyer-banner promos. Not on every rebuild, just an actual
      // tab switch onto Home.
      if (index == 0 && _selectedIndex != 0) {
        _flyerSelection = _pickFlyers();
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_policyAccepted == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_policyAccepted == false) {
      return PolicyAcceptanceScreen(
        onAccepted: () {
          if (mounted) {
            setState(() {
              _policyAccepted = true;
            });
          }
        },
      );
    }

    _ensureSoundListener(user.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("bookings")
          .snapshots(),
      builder: (context, bookingSnapshot) {
        final bookingDocs =
            bookingSnapshot.data?.docs ?? [];

        int activeBookingCount = 0;

        for (final doc in bookingDocs) {
          final status = doc["status"];

          if (status == "awaitingAcceptance" ||
              status == "accepted" ||
              status == "onTheWay" ||
              status == "inProgress") {
            activeBookingCount++;
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("notifications")
              .where("isRead", isEqualTo: false)
              .snapshots(),
          builder: (context, notificationSnapshot) {
            final unreadDocs = notificationSnapshot.data?.docs ?? [];

            // Match notifications_screen.dart: when "Booking
            // updates" is off, every currently-existing notification
            // type falls under kBookingNotificationTypes, so the
            // badge/bell-dot should agree that there's nothing to
            // show, not silently keep counting hidden ones.
            final unreadNotificationCount = _bookingNotificationsEnabled
                ? unreadDocs.length
                : unreadDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    final type = data?['type'] as String? ?? '';
                    return !kBookingNotificationTypes.contains(type);
                  }).length;

            final List<Widget> screens = [
              HomeScreen(
                flyers: _flyerSelection,
                notificationCount: unreadNotificationCount,
                // ADDED (2026-09-16): top-right bell in HomeAppBar now
                // switches the bottom nav to the Notifications tab,
                // exactly like tapping it there -- same _onItemTapped
                // this screen already wires to BottomNavBar's onTap.
                onNotificationTap: () => _onItemTapped(2),
              ),
              const BookingsScreen(),
              const NotificationsScreen(),
              const ProfileScreen(),
            ];

            return Scaffold(
              backgroundColor: const Color(0xFFF7F8FC),
              body: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
              bottomNavigationBar: BottomNavBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                bookingCount: activeBookingCount,
                notificationCount:
                    unreadNotificationCount,
              ),
            );
          },
        );
      },
    );
  }
}
