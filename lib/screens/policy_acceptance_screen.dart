import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'legal_content_screen.dart';

// ================================================================
// POLICY ACCEPTANCE SCREEN -- NEW (2026-09-27, Harsh's point 13)
// ================================================================
//
// "Policy Documentation to be set up to agreed on both apps for one
// time acceptance after the login is successful and this should
// appear as soon as they land the homepage after OTP is verified and
// before ... any other pop on even if established later on customer
// app."
//
// A one-time, non-dismissible acceptance gate (no back button, no
// swipe-to-dismiss -- see the PopScope below) shown the first time a
// customer's session reaches the home shell after OTP verification.
// MainNavigationScreen checks users/{uid}.policyAcceptedVersion
// BEFORE it builds anything else in its IndexedStack (Home/Bookings/
// Notifications/Profile) -- see the gate added there -- so nothing
// those screens show, now or in the future, can appear before this.
//
// Re-uses the same LegalContentScreen content screen that Settings >
// Terms & Conditions / Privacy Policy already link to, so the
// customer reads the exact same document either way.
// ================================================================

class PolicyAcceptanceScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const PolicyAcceptanceScreen({
    super.key,
    required this.onAccepted,
  });

  // Bump this (e.g. '1.1') if the Terms/Privacy copy is ever revised
  // materially enough that even customers who already accepted an
  // earlier version must explicitly re-accept. MainNavigationScreen
  // compares the stored value against this constant.
  static const String currentVersion = '1.0';

  @override
  State<PolicyAcceptanceScreen> createState() =>
      _PolicyAcceptanceScreenState();
}

class _PolicyAcceptanceScreenState extends State<PolicyAcceptanceScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE5E8EE);

  bool _agreed = false;
  bool _isSaving = false;

  Future<void> _openDoc(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _handleAgree() async {
    if (!_agreed || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Shouldn't happen -- MainNavigationScreen only shows this
      // gate once a user is signed in -- but fail safe rather than
      // crash if it somehow does.
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'policyAcceptedVersion': PolicyAcceptanceScreen.currentVersion,
          'policyAcceptedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      widget.onAccepted();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your acceptance. Please check your connection and try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo/habio_logo_blue.png',
                    height: 72,
                    width: 72,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Before you continue',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please review and accept our Terms & Conditions and '
                  'Privacy Policy to continue using Habio.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                _buildDocRow(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () => _openDoc(LegalContentScreen.terms()),
                ),
                const SizedBox(height: 12),
                _buildDocRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _openDoc(LegalContentScreen.privacyPolicy()),
                ),
                const Spacer(),
                InkWell(
                  onTap: _isSaving
                      ? null
                      : () => setState(() => _agreed = !_agreed),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: primaryBlue,
                          onChanged: _isSaving
                              ? null
                              : (value) =>
                                  setState(() => _agreed = value ?? false),
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'I have read and agree to the Terms & '
                              'Conditions and Privacy Policy.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_agreed && !_isSaving) ? _handleAgree : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor: const Color(0xFFB8C7F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Agree & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
