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
          categoryName: "Ask Project X",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
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

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome $userName 👋",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },
                onVoiceTap: () {},
              ),

              const SizedBox(height: 24),

              AskProjectXCard(
                onTap: _openAskProjectX,
                onVoiceTap: _openAskProjectX,
                onCameraTap: _openAskProjectX,
              ),

              const SizedBox(height: 24),

              ContinueBookingCard(
                isVisible: hasActiveBooking,
                onContinue: () {},
              ),

              if (hasActiveBooking) const SizedBox(height: 24),

              FrequentlyUsedSection(
                onServiceTap: (service) {},
              ),

              const SizedBox(height: 30),

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

              const SizedBox(height: 30),

              TrendingServices(
                onServiceTap: (service) {},
              ),

              const SizedBox(height: 30),

              EmergencyCard(
                onTap: () {},
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}