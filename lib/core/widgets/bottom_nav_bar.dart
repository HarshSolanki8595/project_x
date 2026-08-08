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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey.shade500,
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.home_outlined,
                    size: 24,
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.home_rounded,
                    size: 25,
                  ),
                ),
                label: "Home",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 23,
                      ),
                      if (bookingCount > 0)
                        Positioned(
                          right: -9,
                          top: -7,
                          child: _badge(bookingCount),
                        ),
                    ],
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 24,
                      ),
                      if (bookingCount > 0)
                        Positioned(
                          right: -9,
                          top: -7,
                          child: _badge(bookingCount),
                        ),
                    ],
                  ),
                ),
                label: "Bookings",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 25,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: _badge(notificationCount),
                        ),
                    ],
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_rounded,
                        size: 25,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: _badge(notificationCount),
                        ),
                    ],
                  ),
                ),
                label: "Notifications",
              ),

              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 25,
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.person_rounded,
                    size: 25,
                  ),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
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
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
