import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ================================================================
// FAQ SCREEN -- NEW (2026-10-03)
// ================================================================
//
// Settings > FAQs. Reads the `faqs` collection the admin panel's new
// FAQ management screen writes to -- a single orderBy('order') query
// (no where filter, so no new composite index needed), filtered down
// to isActive + this app's audience ('CUSTOMERS' or 'BOTH') entirely
// client-side, same pattern as AnnouncementBanner. Genuinely empty
// (no FAQs published yet) is a normal, expected state, not an error.
// ================================================================

class _Faq {
  final String question;
  final String answer;

  const _Faq({required this.question, required this.answer});
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE5E8EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: background,
        elevation: 0,
        foregroundColor: textPrimary,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('faqs')
              .orderBy('order')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final faqs = (snapshot.data?.docs ?? const [])
                .map((d) => d.data())
                .where((d) {
                  final isActive = d['isActive'] as bool? ?? false;
                  final audience = d['audience'] as String? ?? 'BOTH';
                  return isActive &&
                      (audience == 'BOTH' || audience == 'CUSTOMERS');
                })
                .map(
                  (d) => _Faq(
                    question: d['question'] as String? ?? '',
                    answer: d['answer'] as String? ?? '',
                  ),
                )
                .toList();

            if (faqs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No FAQs yet -- check back soon.',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                for (final faq in faqs)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        iconColor: primaryBlue,
                        collapsedIconColor: textSecondary,
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faq.answer,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
