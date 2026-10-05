import 'package:flutter/material.dart';

import '../../data/service_categories.dart';
import '../../models/category.dart';

// ============================================================
// QUICK SERVICES SECTION -- added 2026-09-01
// ============================================================
//
// Shows the app's fixed-price ("Quick Service") categories --
// Helper Services and Cleaning -- as their own horizontal row above
// the main category grid, so customers can immediately spot the
// services that skip professional-quoted bidding and go straight to
// a fixed price (see fixed_price_service_config.dart /
// FixedPriceRequestScreen, reached via SubcategoryScreen's
// `category.isQuickService` branch). CategoryGrid excludes these two
// categories from its own grid to avoid duplication (see
// CategoryGrid's Category.isQuickService filter).
//
// Visually this reuses the same tokens as every other section on
// this screen (white cards, #EEF3FF borders, 18px rounding, the
// #0F172A/#64748B/#1557FF text/accent colors already used by
// CategoryGrid and TrendingServices) so it reads as part of the same
// screen, not a new visual language.

class QuickServicesSection extends StatelessWidget {
  const QuickServicesSection({
    super.key,
    this.onCategoryTap,
  });

  /// Fired when a category card is tapped -- caller is expected to open
  /// that category's SubcategoryScreen (see home_screen.dart).
  final Function(String)? onCategoryTap;

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _primaryBlue = Color(0xFF1557FF);
  static const Color _cardBorder = Color(0xFFEEF3FF);

  @override
  Widget build(BuildContext context) {
    final quickCategories =
        ServiceCategories.all.where((c) => c.isQuickService).toList();

    if (quickCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                "Quick Services",
                style: TextStyle(
                  color: _darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: _primaryBlue,
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Fixed price",
                      style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Answer a few questions, get an instant price — no bidding.",
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 148,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: quickCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final category = quickCategories[index];

              return SizedBox(
                width: 118,
                child: _QuickServiceCard(
                  category: category,
                  onTap: () => onCategoryTap?.call(category.name),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickServiceCard extends StatelessWidget {
  const _QuickServiceCard({
    required this.category,
    required this.onTap,
  });

  final Category category;
  final VoidCallback onTap;

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _cardBorder = Color(0xFFEEF3FF);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: category.color.withValues(alpha: 0.12),
              child: Icon(category.icon, color: category.color, size: 27),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _darkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
