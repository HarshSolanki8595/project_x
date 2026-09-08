import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bookings_screen.dart';
import 'saved_addresses_screen.dart';
import 'support_chat_screen.dart';
import 'login_screen.dart';

// ============================================================
// PROFILE -- restyled to match the professional app 2026-09-05
// ============================================================
//
// Harsh's to-do #2: same options as before (My Bookings, Saved
// Addresses, Settings, Help & Support, Logout), navigating to the
// exact same places with the exact same data source (users/{uid}
// in Firestore) -- only the visual treatment changes, to match
// habio_professional's profile_screen.dart: a left-aligned inline
// title instead of a centered AppBar, a smaller avatar with the
// name/phone underneath in the professional app's type scale,
// white bordered cards with a colored icon tile + subtitle for
// each option (instead of plain ListTiles with no subtitle), and
// logout moved out of the list into its own full-width outlined
// button below -- still signs out immediately on tap, exactly as
// before, just restyled.
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE5E8EE);

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

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              );
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            final fullName = data?["fullName"] ?? "User";
            final phoneNumber = data?["phoneNumber"] ?? "";

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // AVATAR / NAME / PHONE BLOCK
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: primaryBlue,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),

                  if (phoneNumber.toString().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      "+91 $phoneNumber",
                      style: const TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  _ProfileTile(
                    icon: Icons.receipt_long_outlined,
                    title: "My Bookings",
                    subtitle: "View your past and upcoming bookings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingsScreen(),
                        ),
                      );
                    },
                  ),

                  _ProfileTile(
                    icon: Icons.location_on_outlined,
                    title: "Saved Addresses",
                    subtitle: "Manage your saved addresses",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedAddressesScreen(),
                        ),
                      );
                    },
                  ),

                  _ProfileTile(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    subtitle: "Notifications and preferences",
                    onTap: () {},
                  ),

                  _ProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help & Support",
                    subtitle: "Get help or contact support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupportChatScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(
                          color: Color(0xFFE5B7B7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: ProfileScreen.cardBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ProfileScreen.lightBlue,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: ProfileScreen.primaryBlue,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ProfileScreen.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: ProfileScreen.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: ProfileScreen.textSecondary,
        ),
      ),
    );
  }
}
