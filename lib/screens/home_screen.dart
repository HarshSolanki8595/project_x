import 'package:flutter/material.dart';

import '../core/widgets/ask_projectx_card.dart';
import '../core/widgets/category_grid.dart';
import '../core/widgets/continue_booking_card.dart';
import '../core/widgets/emergency_card.dart';
import '../core/widgets/frequently_used_section.dart';
import '../core/widgets/home_app_bar.dart';
import '../core/widgets/home_search_bar.dart';
import '../core/widgets/trending_services.dart';
import '../core/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  /// Temporary variable.
  /// Later this will come from Firebase/API.
  bool hasActiveBooking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeAppBar(
                      location: "Mumbai",
                      onLocationTap: () {},
                      onNotificationTap: () {},
                    ),

                    const SizedBox(height: 24),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello Harsh 👋",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "How can we help you today?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    HomeSearchBar(
                      onTap: () {},
                      onVoiceTap: () {},
                    ),

                    const SizedBox(height: 24),

                    AskProjectXCard(
                      onTap: () {},
                      onVoiceTap: () {},
                      onCameraTap: () {},
                    ),

                    const SizedBox(height: 24),

                    ContinueBookingCard(
                      isVisible: hasActiveBooking,
                      onContinue: () {},
                    ),

                    if (hasActiveBooking)
                      const SizedBox(height: 24),

                    FrequentlyUsedSection(
                      onServiceTap: (service) {},
                    ),

                    const SizedBox(height: 30),

                    CategoryGrid(
                      onCategoryTap: (category) {},
                    ),

                    const SizedBox(height: 30),

                    TrendingServices(
                      onServiceTap: (service) {},
                    ),

                    const SizedBox(height: 30),

                    EmergencyCard(
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            BottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}