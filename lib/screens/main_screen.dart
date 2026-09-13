import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/widgets/bottom_nav_bar.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

// ================================================================
// MAIN SCREEN — REAL NOTIFICATION BADGE (2026-08-23)
// ================================================================
//
// ENHANCEMENT: previously used Flutter's built-in NavigationBar
// with no badge support at all. Now uses the existing BottomNavBar
// widget (core/widgets/bottom_nav_bar.dart) -- it already had full
// badge support built in but was never actually wired into any
// screen. The Notifications tab now shows a live unread count.
//

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // NOTE (2026-09-13): HomeScreen now requires a `flyers` list (the
  // Home-screen promo banner added that day) -- this screen is
  // confirmed orphaned/unused elsewhere in this file's own 2026-09-06
  // comment history (see professionals_screen.dart), but it still has
  // to compile, so it gets its own one-off random pick here rather
  // than reshuffling on tab switches like MainNavigationScreen does.
  final List<FlyerContent> _flyerSelection =
      (List<FlyerContent>.from(kHomeFlyers)..shuffle(Random()))
          .take(3)
          .toList();

  late final List<Widget> _pages = [
    HomeScreen(flyers: _flyerSelection),
    const BookingsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: user == null
          ? BottomNavBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : StreamBuilder<int>(
              stream: NotificationService.watchUnreadCount(user.uid),
              builder: (context, snapshot) {
                return BottomNavBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  notificationCount: snapshot.data ?? 0,
                );
              },
            ),
    );
  }
}