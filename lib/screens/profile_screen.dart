import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/support_ticket_service.dart';
import 'bookings_screen.dart';
import 'saved_addresses_screen.dart';
import 'settings_screen.dart';
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
//
// UPDATED — 2026-09-17: "Help & Support" now opens a short triage
// bottom sheet first (per Harsh's request to layer a ticket queue
// in front of the existing chat), instead of navigating straight to
// SupportChatScreen. Picking a category tags a support_tickets
// doc (best-effort -- see SupportTicketService) and then opens the
// exact same chat screen as before; nothing about the chat itself
// changed. The tile's own look is untouched.
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  _ProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help & Support",
                    subtitle: "Get help or contact support",
                    onTap: () => _openSupportTriage(context),
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

// ================================================================
// SUPPORT TRIAGE (NEW — 2026-09-17)
// ================================================================
//
// A short "what's this about?" bottom sheet shown before the chat
// opens. Picking a category tags the customer's support_tickets doc
// (best-effort -- a failed write here never blocks the chat from
// opening) and is the customer-app half of the ticket layer Harsh
// asked for; the professional app's equivalent uses its existing
// Help & Support category tiles instead of a sheet, since those
// were already built and just sitting unused.
//

Future<void> _openSupportTriage(BuildContext context) async {
  final selection = await showModalBottomSheet<_SupportCategory>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _SupportTriageSheet(),
  );

  if (selection == null) {
    return;
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    try {
      await SupportTicketService.openTicket(
        uid: uid,
        category: selection.key,
        categoryLabel: selection.label,
      );
    } catch (_) {
      // Ticket tagging is best-effort -- the chat itself must still
      // open even if this write fails (e.g. no network).
    }
  }

  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SupportChatScreen()),
  );
}

class _SupportCategory {
  final String key;
  final String label;
  final IconData icon;

  const _SupportCategory(this.key, this.label, this.icon);
}

const List<_SupportCategory> _supportCategories = [
  _SupportCategory(
    'booking',
    'Problem with a booking',
    Icons.receipt_long_outlined,
  ),
  _SupportCategory(
    'payment',
    'Payment & billing',
    Icons.account_balance_wallet_outlined,
  ),
  _SupportCategory(
    'account',
    'Account & profile',
    Icons.person_outline_rounded,
  ),
  _SupportCategory(
    'general',
    'Something else',
    Icons.help_outline_rounded,
  ),
];

class _SupportTriageSheet extends StatelessWidget {
  const _SupportTriageSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E7EF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "What's this about?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ProfileScreen.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pick the closest match so our team can help faster.',
              style: TextStyle(
                fontSize: 13,
                color: ProfileScreen.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ..._supportCategories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pop(context, category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ProfileScreen.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: ProfileScreen.lightBlue,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              category.icon,
                              color: ProfileScreen.primaryBlue,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ProfileScreen.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: ProfileScreen.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
