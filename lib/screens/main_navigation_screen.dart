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

  final List<Widget> _screens = const [
    HomeScreen(),
    BookingsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
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

            return Scaffold(
              backgroundColor: const Color(0xFFF7F8FC),
              body: IndexedStack(
                index: _selectedIndex,
                children: _screens,
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
