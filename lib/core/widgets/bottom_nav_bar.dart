import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.bookingCount = 0,
    this.notificationCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  final int bookingCount;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.calendar_today_rounded),

              if (bookingCount > 0)
                Positioned(
                  right: -8,
                  top: -5,
                  child: _badge(bookingCount),
                ),
            ],
          ),
          label: "Bookings",
        ),

        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded),

              if (notificationCount > 0)
                Positioned(
                  right: -8,
                  top: -5,
                  child: _badge(notificationCount),
                ),
            ],
          ),
          label: "Notifications",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: "Profile",
        ),
      ],
    );
  }

  static Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? "99+" : "$count",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}