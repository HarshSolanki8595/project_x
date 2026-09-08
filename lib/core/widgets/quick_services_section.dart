import 'package:flutter/material.dart';

import '../../data/service_categories.dart';

// ============================================================
// QUICK SERVICES SECTION -- added 2026-09-01
// ============================================================
//
// Segregates the categories flagged Category.isQuickService (Helper
// Services + Cleaning, per the finalized taxonomy/pricing-model
// decision) into their own section, instead of piling every category
// together in one grid. These two get a fixed, system-computed price
// with no bidding (see the "Helper Services & Cleaning pricing model"
// item on the Build Queue) -- that's what "Quick" refers to, and why
// they're called out here rather than left in Browse Categories.
//
// Tapping a card still opens the normal SubcategoryScreen flow, same
// as every other category, via onCategoryTap -- the dedicated
// fixed-price booking flow is separate, not-yet-built work; this
// section only changes where these two categories live on the home
// screen and how they're presented, not the booking flow itself.
//
// Visually this reuses the same tokens as every other section on this
// screen (white cards, #EEF3FF borders, 18-21px rounding, the
// #0F172A/#64748B/#1557FF text/accent colors already used by
// CategoryGrid, FrequentlyUsedSection and TrendingServices) so it
// reads as part of the same screen, not a new visual language.

class QuickServicesSection extends StatelessWidget {
  const QuickServicesSection({
    super.key,
    this.onCategoryTap,
  });

  final Function(String)? onCategoryTap;

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEEF3FF);
  static const Color _primaryBlue = Color(0xFF1557FF);

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (var i = 0; i < quickCategories.length; i++) ...[
                if (i > 0) const SizedBox(width: 13),
                Expanded(
                  child: _QuickServiceCard(
                    name: quickCategories[i].name,
                    icon: quickCategories[i].icon,
                    color: quickCategories[i].color,
                    subCount: quickCategories[i].subCategories.length,
                    onTap: () => onCategoryTap?.call(quickCategories[i].name),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickServiceCard extends StatelessWidget {
  const _QuickServiceCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.subCount,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final Color color;
  final int subCount;
  final VoidCallback onTap;

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEEF3FF);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                color: _darkText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "$subCount services",
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
