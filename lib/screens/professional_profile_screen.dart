import 'package:flutter/material.dart';

import '../models/professional_model.dart';
import '../models/review_model.dart';
import '../services/portfolio_service.dart';
import '../services/professional_firestore_service.dart';
import '../services/review_service.dart';

// ================================================================
// PROFESSIONAL PROFILE SCREEN (NEW — 2026-08-23)
// ================================================================
//
// Opened by tapping a professional's name/avatar on the bid card
// in professionals_screen.dart ("Choose the right professional").
// Shows the professional's full public profile: verification,
// rating, member-since date, a photo grid of past completed jobs
// (from the new portfolio subcollection), and their full review
// history.
//
// Every piece of data here comes through PUBLIC read rules added
// alongside this screen -- professionals, portfolio, and reviews
// were all previously readable only by their own owner. See
// firestore.rules for exactly what was opened up and why each is
// safe to expose (no customer PII, no pricing, anywhere here).
//

class ProfessionalProfileScreen extends StatelessWidget {
  final String professionalId;

  const ProfessionalProfileScreen({
    super.key,
    required this.professionalId,
  });

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);
  static const Color starGold = Color(0xFFF5A524);
  static const Color green = Color(0xFF35A853);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Partner Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<ProfessionalModel?>(
        future: ProfessionalFirestoreService.getProfessional(
          professionalId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          final professional = snapshot.data;

          if (professional == null) {
            return _buildNotFound();
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              _buildHeaderCard(professional),
              const SizedBox(height: 14),
              _buildStatsRow(professional),
              const SizedBox(height: 24),
              _buildSectionTitle('Past Work'),
              const SizedBox(height: 10),
              _buildPortfolioGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('Reviews'),
              const SizedBox(height: 10),
              _buildReviewsList(),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // NOT FOUND
  // ============================================================

  Widget _buildNotFound() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'This partner\'s profile could not be loaded.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard(ProfessionalModel professional) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: const BoxDecoration(
              color: lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: primaryBlue,
              size: 40,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            professional.name.isNotEmpty
                ? professional.name
                : 'Partner',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (professional.isVerified) _verifiedBadge(),
              _memberSinceBadge(professional.createdAt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: green, size: 14),
          SizedBox(width: 4),
          Text(
            'Verified Partner',
            style: TextStyle(
              color: green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberSinceBadge(DateTime createdAt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Member since ${_formatMonthYear(createdAt)}',
        style: const TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // STATS ROW
  // ============================================================

  Widget _buildStatsRow(ProfessionalModel professional) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.star_rounded,
            iconColor: starGold,
            value: professional.completedJobsCount <= 0
                ? 'New'
                : professional.averageRating.toStringAsFixed(1),
            label: 'Rating',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: primaryBlue,
            value: professional.completedJobsCount.toString(),
            label: 'Jobs Completed',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
    );
  }

  // ============================================================
  // PORTFOLIO GRID
  // ============================================================

  Widget _buildPortfolioGrid() {
    return StreamBuilder<List<PortfolioEntryModel>>(
      stream: PortfolioService.watchPortfolio(professionalId),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <PortfolioEntryModel>[];

        final allPhotos = entries
            .expand((entry) => entry.photoUrls)
            .toList();

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryBlue,
                ),
              ),
            ),
          );
        }

        if (allPhotos.isEmpty) {
          return _emptyCard(
            icon: Icons.photo_library_outlined,
            message: 'No past work photos yet.',
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: allPhotos.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                allPhotos[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: lightBlue,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // REVIEWS LIST
  // ============================================================

  Widget _buildReviewsList() {
    return StreamBuilder<List<ReviewModel>>(
      stream: ReviewService.watchReviewsForProfessional(professionalId),
      builder: (context, snapshot) {
        // Moderated-hidden reviews (admin panel's Reviews screen,
        // 2026-10-03) are filtered out client-side here, same
        // no-new-composite-index discipline as every other
        // audience/active filter added this project -- the query
        // itself stays a single where+orderBy.
        final reviews = (snapshot.data ?? const <ReviewModel>[])
            .where((r) => !r.isHidden)
            .toList();

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryBlue,
                ),
              ),
            ),
          );
        }

        // ------------------------------------------------------------
        // FIX (2026-09-06): Harsh's point 6 -- "the written reviews
        // are nowhere visible on the app." Root cause: this is a
        // composite query (where professionalId + orderBy createdAt)
        // and firestore.indexes.json never had the matching index, so
        // Firestore rejected it with FAILED_PRECONDITION every single
        // time. Before this fix, that error was swallowed by
        // `snapshot.data ?? const <ReviewModel>[]` above and this
        // screen just showed "No reviews yet" -- indistinguishable
        // from there genuinely being no reviews, even though real
        // written reviews existed in Firestore the whole time. Now
        // surfaced as its own state so a real failure is never
        // mistaken for an empty list again.
        // ------------------------------------------------------------
        if (snapshot.hasError) {
          return _emptyCard(
            icon: Icons.error_outline_rounded,
            message: "Couldn't load reviews right now. Please try again.",
          );
        }

        if (reviews.isEmpty) {
          return _emptyCard(
            icon: Icons.rate_review_outlined,
            message: 'No reviews yet.',
          );
        }

        return Column(
          children: reviews
              .map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _reviewCard(review),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _reviewCard(ReviewModel review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  final filled = index < review.rating;
                  return Icon(
                    filled
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: filled
                        ? starGold
                        : const Color(0xFFCBD5E1),
                    size: 17,
                  );
                }),
              ),
              const Spacer(),
              Text(
                _formatMonthYear(review.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ],
          if ((review.platformReply ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Response from Habio',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.platformReply!.trim(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CARD
  // ============================================================

  Widget _emptyCard({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: textSecondary, size: 26),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static String _formatMonthYear(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}