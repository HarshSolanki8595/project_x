import 'package:flutter/material.dart';

import '../../data/day_to_day_coming_soon.dart';

// ============================================================
// DAY-TO-DAY SERVICES -- "COMING SOON" FULL LIST
// ============================================================
//
// REWRITTEN 2026-09-30, per Harsh. Previously this was the "See all"
// destination for a real, bookable Day-to-Day Services Quick Service
// category (straight into FixedPriceRequestScreen per row). That
// category was dropped -- see service_categories.dart, where
// Cleaning and Helper Services went back to being their own normal
// Quick Service categories and every one of these subcategory names
// now lives (and is actually bookable) there instead.
//
// Harsh asked not to delete this screen/concept outright: it now
// shows the same list purely as a "Coming Soon" preview so customers
// know these recurring services are on the way, with every row
// inert -- tapping does nothing. See day_to_day_coming_soon.dart for
// why this reads from a plain presentational list rather than a real
// Category.
// ============================================================

class DayToDayServicesScreen extends StatelessWidget {
  const DayToDayServicesScreen({super.key});

  static const Color _darkText = Color(0xFF0F172A);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _amber = Color(0xFFB8860B);
  static const Color _amberBg = Color(0xFFFFF4E5);
  static const Color _cardBorder = Color(0xFFEEF3FF);
  static const Color _tileIconColor = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Day-to-Day Services"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                Icon(Icons.hourglass_top_rounded, size: 13, color: _amber),
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
          const SizedBox(height: 8),
          const Text(
            "These recurring, day-to-day services aren't bookable yet -- "
            "take a look at what's coming.",
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          for (final service in kDayToDayComingSoonServices) ...[
            // Deliberately not an InkWell/GestureDetector -- per
            // Harsh, tapping a row here does nothing for now.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _tileIconColor.withValues(alpha: 0.12),
                    child: Icon(
                      service.icon,
                      color: _tileIconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _amberBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Coming Soon",
                      style: TextStyle(
                        color: _amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
