import 'package:flutter/material.dart';

import '../../data/service_categories.dart';
import '../../models/category.dart';
import '../../services/service_stats_service.dart';

// ============================================================
// TRENDING SERVICES -- home screen section
// ============================================================
//
// Rebuilt 2026-09-06 (Harsh's point 5): "Trending services to be
// done on the basis [of] what services customers are ordering on
// our app." This used to be four services hand-picked in code
// (AC Service, Waterproofing, Pest Control, Deep Cleaning) that
// never changed no matter what anyone actually booked. It now
// streams ServiceStatsService.watchTopCategories(), which reads
// serviceStats/{categoryId} -- a count the acceptBid /
// acceptFixedPriceOpportunity Cloud Functions increment every time
// a bid is accepted (i.e. an order is actually placed) -- and shows
// the real most-booked categories, ordered by how many times each
// has been booked. Tapping a card still calls onServiceTap exactly
// as before (unused by home_screen.dart today, unchanged here).
//
// While there's no order history yet (a brand-new install, or
// before this feature shipped) a small curated fallback fills the
// same slot so the section never looks empty -- the same four
// categories the old hardcoded list pointed at, just now sourced
// from the real ServiceCategories taxonomy (name/icon/color) instead
// of one-off values, so "Book Now" still lines up with a real
// category either way.
// ============================================================

class TrendingServices extends StatelessWidget {
  const TrendingServices({
    super.key,
    this.onServiceTap,
  });

  final Function(String)? onServiceTap;

  // Only used when there's no real order data yet -- see the file
  // note above. Each categoryId must exist in ServiceCategories.all.
  static const List<_FallbackEntry> _fallback = [
    _FallbackEntry('appliances', 'Beat the summer heat'),
    _FallbackEntry('painting', 'Monsoon ready homes'),
    _FallbackEntry('pest_control', 'Protect your family'),
    _FallbackEntry('cleaning', 'Festival special'),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, int>>>(
      stream: ServiceStatsService.watchTopCategories(limit: 6),
      builder: (context, snapshot) {
        final List<MapEntry<String, int>> live = snapshot.data ?? [];

        final List<_TrendingCardData> cards = live.isNotEmpty
            ? live
                .map((entry) {
                  final category = ServiceCategories.getCategoryById(entry.key);
                  if (category == null) return null;
                  final int count = entry.value;
                  return _TrendingCardData(
                    category: category,
                    subtitle:
                        '$count ${count == 1 ? 'booking' : 'bookings'} so far',
                  );
                })
                .whereType<_TrendingCardData>()
                .toList()
            : _fallback
                .map((fallback) {
                  final category =
                      ServiceCategories.getCategoryById(fallback.categoryId);
                  if (category == null) return null;
                  return _TrendingCardData(
                    category: category,
                    subtitle: fallback.subtitle,
                  );
                })
                .whereType<_TrendingCardData>()
                .toList();

        if (cards.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Trending Services",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 170,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 13),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final Category category = card.category;

                  return InkWell(
                    borderRadius: BorderRadius.circular(21),
                    onTap: () => onServiceTap?.call(category.name),
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: const Color(0xFFEEF3FF),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                category.color.withValues(alpha: 0.12),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 28,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 13),
                          const Row(
                            children: [
                              Text(
                                "Book Now",
                                style: TextStyle(
                                  color: Color(0xFF1557FF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF1557FF),
                                size: 17,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FallbackEntry {
  final String categoryId;
  final String subtitle;

  const _FallbackEntry(this.categoryId, this.subtitle);
}

class _TrendingCardData {
  final Category category;
  final String subtitle;

  const _TrendingCardData({
    required this.category,
    required this.subtitle,
  });
}
