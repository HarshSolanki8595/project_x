import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_security_screen.dart';
import 'faq_screen.dart';
import 'legal_content_screen.dart';

// ================================================================
// SETTINGS SCREEN -- NEW (2026-09-16)
// ================================================================
//
// Profile > Settings previously had no screen behind it at all
// (onTap: () {} in profile_screen.dart's _ProfileTile). Mirrors the
// professional app's own settings_screen.dart -- same card/tile
// shapes, same three sections (Notifications, Account, About) -- with
// customer-facing labels instead of the partner-facing ones, and
// using ProfileScreen's own local color constants (this app has no
// shared AppTheme class the way habio_professional does; every
// customer-app screen just defines its own matching statics).
//
// The toggles and the Privacy/Terms/Policy tiles are local-only for
// now (no backend field to persist them to yet) -- same "will be
// connected later" honesty the professional app's settings screen
// already uses for its own not-yet-wired items, rather than silently
// pretending they're saved somewhere.
// ================================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  // Same palette ProfileScreen already defines on its own public
  // class (rather than a shared AppTheme, which this app doesn't
  // have) -- kept here too so _NotificationSwitch/_SettingsTile/
  // _LanguageOption below can reference SettingsScreen.xxx, matching
  // how profile_screen.dart's own _ProfileTile references
  // ProfileScreen.xxx.
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE5E8EE);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // PERSISTENCE (added 2026-09-16) -- these four toggles and the
  // language choice used to be plain widget state, reset every time
  // this screen was reopened. Now backed by SharedPreferences
  // (device-local, not synced to Firestore -- Harsh's choice when
  // asked) so they survive leaving this screen and restarting the
  // app. The Privacy/Terms/Policy tiles below stay local-only
  // snackbars -- there's nothing to persist there, they're just
  // "not built yet" placeholders.
  // ============================================================

  static const String _kBookingKey = 'settings_booking_notifications';
  static const String _kMessageKey = 'settings_message_notifications';
  static const String _kPromoKey = 'settings_promo_notifications';
  static const String _kSoundKey = 'settings_sound_notifications';
  static const String _kLanguageKey = 'settings_language';

  bool _bookingNotifications = true;
  bool _messageNotifications = true;
  bool _promoNotifications = true;
  bool _soundNotifications = true;
  String _language = 'English';

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _prefs = prefs;
      _bookingNotifications = prefs.getBool(_kBookingKey) ?? true;
      _messageNotifications = prefs.getBool(_kMessageKey) ?? true;
      _promoNotifications = prefs.getBool(_kPromoKey) ?? true;
      _soundNotifications = prefs.getBool(_kSoundKey) ?? true;
      _language = prefs.getString(_kLanguageKey) ?? 'English';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsScreen.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: SettingsScreen.background,
        elevation: 0,
        foregroundColor: SettingsScreen.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _sectionTitle('Notifications'),
            const SizedBox(height: 10),
            _notificationCard(),
            const SizedBox(height: 25),
            _sectionTitle('Account'),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy & Security',
              subtitle: 'Manage your account security',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountSecurityScreen(),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: _language,
              onTap: _showLanguageDialog,
            ),
            const SizedBox(height: 25),
            _sectionTitle('About'),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              subtitle: 'Read the terms of using Habio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LegalContentScreen.terms(),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.policy_outlined,
              title: 'Privacy Policy',
              subtitle: 'How Habio handles your information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LegalContentScreen.privacyPolicy(),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'FAQs',
              subtitle: 'Answers to common questions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FaqScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Habio',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: SettingsScreen.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: SettingsScreen.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: SettingsScreen.textPrimary,
      ),
    );
  }

  Widget _notificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SettingsScreen.cardBorder),
      ),
      child: Column(
        children: [
          _NotificationSwitch(
            icon: Icons.receipt_long_rounded,
            title: 'Booking updates',
            subtitle: 'Status changes on your bookings and orders',
            value: _bookingNotifications,
            onChanged: (value) {
              setState(() => _bookingNotifications = value);
              _prefs?.setBool(_kBookingKey, value);
            },
          ),
          const Divider(height: 1, color: Color(0xFFECEEF2)),
          _NotificationSwitch(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Messages',
            subtitle: 'Updates from support and your professional',
            value: _messageNotifications,
            onChanged: (value) {
              setState(() => _messageNotifications = value);
              _prefs?.setBool(_kMessageKey, value);
            },
          ),
          const Divider(height: 1, color: Color(0xFFECEEF2)),
          _NotificationSwitch(
            icon: Icons.local_offer_outlined,
            title: 'Promotions & offers',
            subtitle: 'Deals, discounts and new features',
            value: _promoNotifications,
            onChanged: (value) {
              setState(() => _promoNotifications = value);
              _prefs?.setBool(_kPromoKey, value);
            },
          ),
          const Divider(height: 1, color: Color(0xFFECEEF2)),
          _NotificationSwitch(
            icon: Icons.volume_up_outlined,
            title: 'Notification sound',
            subtitle: 'Play sound for important alerts',
            value: _soundNotifications,
            onChanged: (value) {
              setState(() => _soundNotifications = value);
              _prefs?.setBool(_kSoundKey, value);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(
                language: 'English',
                selected: _language == 'English',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _selectLanguage('English');
                },
              ),
              _LanguageOption(
                language: 'Hindi',
                selected: _language == 'Hindi',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _selectLanguage('Hindi');
                  _showMessage('Hindi language support will be added later.');
                },
              ),
              _LanguageOption(
                language: 'Marathi',
                selected: _language == 'Marathi',
                onTap: () {
                  Navigator.pop(dialogContext);
                  _selectLanguage('Marathi');
                  _showMessage(
                    'Marathi language support will be added later.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectLanguage(String language) {
    setState(() => _language = language);
    _prefs?.setString(_kLanguageKey, language);
  }
}

class _NotificationSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: SettingsScreen.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: SettingsScreen.primaryBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: SettingsScreen.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: SettingsScreen.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: SettingsScreen.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
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
        border: Border.all(color: SettingsScreen.cardBorder),
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
            color: SettingsScreen.lightBlue,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: SettingsScreen.primaryBlue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SettingsScreen.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: SettingsScreen.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: SettingsScreen.textSecondary,
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(language),
      trailing: selected
          ? const Icon(
              Icons.check_circle_rounded,
              color: SettingsScreen.primaryBlue,
            )
          : null,
    );
  }
}
