import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/widgets/bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
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

  void _onItemTapped(int index) {
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
            final unreadNotificationCount =
                notificationSnapshot.data?.docs.length ?? 0;

            final List<Widget> screens = [
              HomeScreen(flyers: _flyerSelection),
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
