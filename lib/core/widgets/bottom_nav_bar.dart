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

  static const Color primaryBlue = Color(0xFF1557FF);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: primaryBlue,
      unselectedItemColor: const Color(0xFF98A2B3),

      backgroundColor: Colors.white,

      selectedFontSize: 14,
      unselectedFontSize: 14,

      showUnselectedLabels: true,

      elevation: 12,

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
                  top: -6,
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
              const Icon(
                Icons.notifications_none_rounded,
              ),

              if (notificationCount > 0)
                Positioned(
                  right: -8,
                  top: -6,
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
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? "99+" : "$count",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}