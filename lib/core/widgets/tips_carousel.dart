import 'dart:async';

import 'package:flutter/material.dart';

// ================================================================
// TIPS CAROUSEL (NEW — 2026-09-27)
// ================================================================
//
// Shared auto-rotating card carousel -- extracted from the original
// SafetyAwarenessCarousel (punch-list #4) so the same swipeable/
// auto-advancing card + header + dot-indicator pattern can be reused
// for other rotating-message slots (e.g. WhyChooseUsCarousel) without
// duplicating the PageView/timer logic. Auto-advances every 5s, a
// manual swipe reschedules the same timer from wherever the customer
// left it.
//
// `reverse` (added 2026-09-27, per Harsh -- both carousels now visible
// on the same screen should visibly cycle in different directions,
// not just show different content) flips only the auto-advance
// direction (forward = incrementing page index, reverse = decrementing
// it) -- a manual swipe always works either direction regardless.
// ================================================================

class CarouselTip {
  final IconData icon;
  final String text;

  const CarouselTip({required this.icon, required this.text});
}

class TipsCarousel extends StatefulWidget {
  final IconData headerIcon;
  final String headerText;
  final List<CarouselTip> tips;
  final bool reverse;

  const TipsCarousel({
    super.key,
    required this.headerIcon,
    required this.headerText,
    required this.tips,
    this.reverse = false,
  });

  @override
  State<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<TipsCarousel> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);

  late final PageController _pageController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;

      final int tipCount = widget.tips.length;
      final int nextPage = widget.reverse
          ? (_currentPage - 1 + tipCount) % tipCount
          : (_currentPage + 1) % tipCount;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tips = widget.tips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(widget.headerIcon, color: primaryBlue, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                widget.headerText,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 74,
          child: PageView.builder(
            controller: _pageController,
            itemCount: tips.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _scheduleAutoAdvance();
            },
            itemBuilder: (context, index) {
              final tip = tips[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: const BoxDecoration(
                        color: lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tip.icon,
                        color: primaryBlue,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(tips.length, (index) {
            final bool active = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: active ? 18 : 6,
              decoration: BoxDecoration(
                color: active ? primaryBlue : borderColor,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
