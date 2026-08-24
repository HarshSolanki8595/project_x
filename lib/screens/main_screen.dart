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

  late final List<Widget> _pages = [
    const HomeScreen(),
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