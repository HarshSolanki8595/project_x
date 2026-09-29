import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ================================================================
// ACCOUNT / PRIVACY & SECURITY SCREEN -- NEW (2026-09-16)
// ================================================================
//
// Settings > Privacy & Security used to be a snackbar placeholder.
// Per Harsh's answer ("Account info only"), this is a real,
// read-only screen showing what Habio actually has on file for the
// signed-in customer -- the same users/{uid} document ProfileScreen
// already reads (fullName, phoneNumber, createdAt). No edit/delete
// actions here; changing these details routes through Help &
// Support, same as the professional app's equivalent scope.
// ================================================================

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE5E8EE);

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: Text("Please login first.")),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: background,
        elevation: 0,
        foregroundColor: textPrimary,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            final fullName = data?["fullName"] as String? ?? "User";
            final phoneNumber = data?["phoneNumber"] as String? ?? "";
            final createdAtRaw = data?["createdAt"];
            final createdAt =
                createdAtRaw is Timestamp ? createdAtRaw.toDate() : null;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              children: [
                Text(
                  'Your account information',
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _infoCard([
                  _infoRow(
                    Icons.person_outline_rounded,
                    'Full name',
                    fullName,
                  ),
                  _divider(),
                  _infoRow(
                    Icons.phone_outlined,
                    'Phone number',
                    phoneNumber.isNotEmpty ? '+91 $phoneNumber' : 'Not set',
                  ),
                  _divider(),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Member since',
                    createdAt != null ? _formatDate(createdAt) : '—',
                  ),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: primaryBlue,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your phone number is verified via OTP and used to '
                          'sign in securely. To change your name or number, '
                          'reach out through Help & Support.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFECEEF2));
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
