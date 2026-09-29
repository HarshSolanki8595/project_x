import 'package:flutter/material.dart';

// ================================================================
// LEGAL CONTENT SCREEN -- NEW (2026-09-16)
// ================================================================
//
// Settings > Terms & Conditions / Privacy Policy used to be
// snackbar placeholders ("will be connected later"). This is one
// reusable, real, scrollable content screen parameterized by title
// + sections, so both tiles now open something the customer can
// actually read instead of a toast that goes nowhere.
//
// The copy below is a standard placeholder policy appropriate for a
// home-services marketplace app -- it should be reviewed/replaced
// with Habio's actual legal copy before this ships to real users.
// ================================================================

class LegalSection {
  final String heading;
  final String body;

  const LegalSection(this.heading, this.body);
}

class LegalContentScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE5E8EE);

  factory LegalContentScreen.terms() {
    return const LegalContentScreen(
      title: 'Terms & Conditions',
      lastUpdated: 'Last updated: September 2026',
      sections: [
        LegalSection(
          '1. Using Habio',
          'Habio connects customers with independent service professionals '
              'for home services such as electrical, plumbing, cleaning and '
              'appliance repair. By booking a service through the app, you '
              'agree to provide accurate information about the job and your '
              'address so a professional can be matched and dispatched.',
        ),
        LegalSection(
          '2. Bookings & Pricing',
          'Some services show a fixed price up front; others are quoted by '
              'professionals based on the details you provide. A booking is '
              'confirmed once a professional accepts it. Prices may vary if '
              'the actual job differs materially from what was described.',
        ),
        LegalSection(
          '3. Cancellations',
          'You may cancel a booking before a professional starts the job. '
              'Cancelling after a professional has been dispatched or has '
              'begun work may be subject to a cancellation fee, shown to you '
              'before you confirm the cancellation.',
        ),
        LegalSection(
          '4. Payments',
          'Payments for completed services are processed securely through '
              'our payment partner. Habio does not store your card details.',
        ),
        LegalSection(
          '5. Professional Conduct',
          'Professionals on Habio are independent service providers, not '
              'Habio employees. If a professional\'s conduct or work quality '
              'falls short, please report it through Help & Support so we '
              'can look into it.',
        ),
        LegalSection(
          '6. Changes to These Terms',
          'We may update these terms from time to time. Continued use of '
              'the app after an update means you accept the revised terms.',
        ),
      ],
    );
  }

  factory LegalContentScreen.privacyPolicy() {
    return const LegalContentScreen(
      title: 'Privacy Policy',
      lastUpdated: 'Last updated: September 2026',
      sections: [
        LegalSection(
          'What We Collect',
          'To provide the service, Habio collects your name, phone number, '
              'saved addresses, and details about the bookings you make '
              '(service type, schedule, and any notes you add for the '
              'professional).',
        ),
        LegalSection(
          'How We Use It',
          'Your information is used to match you with professionals, keep '
              'you updated on your bookings via notifications, process '
              'payments, and provide support when you reach out.',
        ),
        LegalSection(
          'Who We Share It With',
          'The professional assigned to your booking sees what\'s needed to '
              'complete the job -- your address, contact number, and job '
              'details. We do not sell your personal information to third '
              'parties.',
        ),
        LegalSection(
          'Notifications',
          'You can control which notifications you receive -- booking '
              'updates, messages, promotions, and notification sound -- from '
              'Settings at any time.',
        ),
        LegalSection(
          'Your Choices',
          'You can review or update your account details, or ask us to '
              'delete your data, by contacting Help & Support from the '
              'Profile tab.',
        ),
        LegalSection(
          'Contact',
          'Questions about this policy can be sent through Help & Support '
              'in the app.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: background,
        elevation: 0,
        foregroundColor: textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Text(
              lastUpdated,
              style: const TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            for (final section in sections) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.heading,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.body,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
