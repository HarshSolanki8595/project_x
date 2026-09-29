import 'package:flutter/material.dart';

import 'tips_carousel.dart';

// ================================================================
// SAFETY AWARENESS CAROUSEL (NEW — 2026-09-27, punch-list #4)
// ================================================================
//
// Harsh: "While the order is placed and the app is looking for
// partners we need to add certain awareness slides for the customers
// to take precaution with the partners." Content (all 8 tips) is
// Harsh's own wording, unchanged.
//
// Dropped into the two screens where a customer can genuinely be
// waiting a while for a professional to be found -- FixedPriceWaitingScreen
// (Quick Services, posted price) and ProfessionalsScreen's
// waiting-for-quotes state (bid-based categories) -- since that's the
// idle stretch with nothing else on screen.
//
// Thin wrapper over the shared TipsCarousel (extracted the same day
// so WhyChooseUsCarousel could reuse the same auto-rotating card/
// header/dot-indicator pattern without duplicating it) -- the public
// SafetyAwarenessCarousel widget/constructor is unchanged, so both
// existing call sites need no changes.
// ================================================================

class SafetyAwarenessCarousel extends StatelessWidget {
  const SafetyAwarenessCarousel({super.key});

  static const List<CarouselTip> _tips = [
    CarouselTip(
      icon: Icons.badge_rounded,
      text: "Confirm the partner's photo, name, and ID in the app "
          'before allowing entry.',
    ),
    CarouselTip(
      icon: Icons.lock_rounded,
      text: 'Never share your OTP, payment PIN, or banking details '
          'with anyone.',
    ),
    CarouselTip(
      icon: Icons.chat_bubble_rounded,
      text: 'Keep all payments and communication inside the Habio app.',
    ),
    CarouselTip(
      icon: Icons.fact_check_rounded,
      text: 'Review the quote and service details before confirming work.',
    ),
    CarouselTip(
      icon: Icons.groups_rounded,
      text: 'For extra safety, have someone nearby during the service '
          'visit.',
    ),
    CarouselTip(
      icon: Icons.no_accounts_rounded,
      text: 'Do not allow unlisted companions to enter your home.',
    ),
    CarouselTip(
      icon: Icons.report_rounded,
      text: 'Report suspicious behavior or mismatched details '
          'immediately.',
    ),
    CarouselTip(
      icon: Icons.task_alt_rounded,
      text: 'After completion, check the work before marking the '
          'service complete.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const TipsCarousel(
      headerIcon: Icons.shield_rounded,
      headerText: 'While you wait, a quick safety reminder',
      tips: _tips,
    );
  }
}
