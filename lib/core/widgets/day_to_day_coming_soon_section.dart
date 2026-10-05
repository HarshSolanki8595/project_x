import 'package:flutter/material.dart';

import '../../data/day_to_day_coming_soon.dart';
import '../../screens/categories/day_to_day_services_screen.dart';

// ============================================================
// DAY-TO-DAY SERVICES -- "COMING SOON" HOME SECTION
// ============================================================
//
// Added 2026-09-30, per Harsh: shows a preview of the recurring
// day-to-day services (maids, cooks, drivers, daily cleaning, etc.)
// that are on the way, without them being real bookable services yet
// -- see the long comment in day_to_day_coming_soon.dart for why this
// is a plain presentational list, not a real Category. Tiles here are
// deliberately NOT wrapped in a tap handler -- per Harsh's explicit
// instruction, nothing happens when one is tapped.
//
// Visually this matches QuickServicesSection immediately above it
// (same card shell, same header+badge+subtitle row layout, same
// horizontal preview + "See all" pattern) so it reads as part of the
// same screen, just with an amber "Coming Soon" badge instead of the
// blue "Fixed price" one, and no price line on each tile.
// ============================================================

class DayToDayComingSoonSection extends StatelessWidget {
  const DayToDayComingSoonSection({super.key});

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _amber = Color(0xFFB8860B);
  static const Color _amberBg = Color(0xFFFFF4E5);
  static const Color _cardBorder = Color(0xFFEEF3FF);
  static const Color _tileIconColor = Colors.lightGreen;

  static const int _previewCount = 6;

  @override
  Widget build(BuildContext context) {
    final preview = kDayToDayComingSoonServices.take(_previewCount).toList();

    if (preview.isEmpty) {
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
                "Day-to-Day Services",
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
                  color: _amberBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      size: 12,
                      color: _amber,
                    ),
                    SizedBox(width: 3),
                    Text(
                      "Coming Soon",
                      style: TextStyle(
                        color: _amber,
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
            "Recurring maids, cooks, drivers and daily cleaning -- "
            "take a look at what's on the way.",
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
            itemCount: preview.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 108,
                child: _ComingSoonTile(service: preview[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DayToDayServicesScreen(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "See all ${kDayToDayComingSoonServices.length} ›",
                  style: const TextStyle(
                    color: _darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Note: "See all" itself still navigates (to the full Coming Soon
// list) -- only the individual service tiles are inert. That list
// screen is exactly as non-functional per-tile as this preview row.

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({required this.service});

  final ComingSoonService service;

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEEF3FF);
  static const Color _amber = Color(0xFFB8860B);
  static const Color _tileIconColor = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    // Deliberately not an InkWell/GestureDetector -- per Harsh,
    // tapping a Coming Soon tile does nothing for now.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
            backgroundColor: _tileIconColor.withValues(alpha: 0.12),
            child: Icon(service.icon, color: _tileIconColor, size: 27),
          ),
          const SizedBox(height: 8),
          Text(
            service.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Coming Soon",
              style: TextStyle(
                color: _amber,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
