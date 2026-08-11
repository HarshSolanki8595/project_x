import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bookings_screen.dart';
import 'saved_addresses_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text("Please login first."),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: background,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            ),
          );
        }

        final data =
            snapshot.data?.data()
                as Map<String, dynamic>?;

        final fullName =
            data?["fullName"] ?? "User";

        final phoneNumber =
            data?["phoneNumber"] ?? "";

        return Scaffold(
          backgroundColor: background,

          appBar: AppBar(
            backgroundColor: background,
            elevation: 0,
            centerTitle: true,

            title: const Text(
              "My Profile",
              style: TextStyle(
                color: textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              32,
              18,
              32,
              30,
            ),
            children: [
              const SizedBox(height: 10),

              // PROFILE IMAGE
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    color: lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 78,
                    color: primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Center(
                child: Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "+91 $phoneNumber",
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 42),

              _profileOption(
                context,
                icon: Icons.receipt_long_rounded,
                title: "My Bookings",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BookingsScreen(),
                    ),
                  );
                },
              ),

              _profileOption(
                context,
                icon: Icons.location_on_rounded,
                title: "Saved Addresses",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SavedAddressesScreen(),
                    ),
                  );
                },
              ),

              _profileOption(
                context,
                icon: Icons.settings_rounded,
                title: "Settings",
                onTap: () {},
              ),

              _profileOption(
                context,
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                onTap: () {},
              ),

              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.logout_rounded,
                  size: 30,
                  color: Color(0xFFD92D20),
                ),

                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFFD92D20),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                trailing: const SizedBox(
                  width: 30,
                ),

                onTap: () async {
                  await FirebaseAuth.instance
                      .signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Icon(
        icon,
        size: 30,
        color: textPrimary,
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 23,
        color: textPrimary,
      ),

      onTap: onTap,
    );
  }
}