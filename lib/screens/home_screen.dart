import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/widgets/ask_projectx_card.dart';
import '../core/widgets/category_grid.dart';
import '../core/widgets/continue_booking_card.dart';
import '../core/widgets/emergency_card.dart';
import '../core/widgets/frequently_used_section.dart';
import '../core/widgets/home_app_bar.dart';
import '../core/widgets/home_search_bar.dart';
import '../core/widgets/trending_services.dart';

import 'categories/subcategory_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'service_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasActiveBooking = false;
  String userName = "User";

  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      setState(() {
        userName = doc["fullName"] ?? "User";
      });
    }
  }

  void _openAskProjectX() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ServiceRequestScreen(
          categoryName: "Ask Habio",
          subCategoryName: "AI Diagnosis",
        ),
      ),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapScreen(),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAppBar(
                location: "Mumbai",
                onLocationTap: _openMap,
                onNotificationTap: () {},
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome $userName 👋",
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      "How can we help you today?",
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              HomeSearchBar(
                onTap: _openSearch,
                onVoiceTap: () {},
              ),

              const SizedBox(height: 22),

              AskProjectXCard(
                onTap: _openAskProjectX,
                onVoiceTap: _openAskProjectX,
                onCameraTap: _openAskProjectX,
              ),

              if (hasActiveBooking) ...[
                const SizedBox(height: 22),
                ContinueBookingCard(
                  isVisible: hasActiveBooking,
                  onContinue: () {},
                ),
              ],

              const SizedBox(height: 30),

              FrequentlyUsedSection(
                onServiceTap: (service) {},
              ),

              const SizedBox(height: 32),

              CategoryGrid(
                onCategoryTap: (category) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubcategoryScreen(
                        categoryName: category,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              TrendingServices(
                onServiceTap: (service) {},
              ),

              const SizedBox(height: 32),

              EmergencyCard(
                onTap: () {},
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
