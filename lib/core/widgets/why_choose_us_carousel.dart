import 'package:flutter/material.dart';

import 'tips_carousel.dart';

// ================================================================
// WHY CHOOSE US CAROUSEL (NEW — 2026-09-27, punch-list #4 follow-up)
// ================================================================
//
// Harsh: turn the static "Professionals decide their price..." line
// on the Professionals & Quotes screen into a rotating carousel of
// selling points, headed like the safety carousel's "While you wait,
// a quick safety reminder" -- same pattern, repeating "Why choose
// Habio" instead. The original message is kept as the first slide;
// the rest are additional USPs reflecting what's actually built
// (verification, in-app payments only, ratings/reviews, support
// chat) rather than new claims.
//
// Thin wrapper over the shared TipsCarousel -- see
// safety_awareness_carousel.dart for why that was extracted. Runs
// with reverse: true so this carousel visibly cycles the opposite
// direction from the safety carousel below it on the same screen.
// ================================================================

class WhyChooseUsCarousel extends StatelessWidget {
  const WhyChooseUsCarousel({super.key});

  static const List<CarouselTip> _tips = [
    CarouselTip(
      icon: Icons.compare_arrows_rounded,
      text: 'Professionals decide their price -- you choose the offer '
          "that's right for you.",
    ),
    CarouselTip(
      icon: Icons.verified_rounded,
      text: 'Every professional is verified before they can bid on '
          'your request.',
    ),
    CarouselTip(
      icon: Icons.security_rounded,
      text: 'All payments and chats stay secured inside the Habio app.',
    ),
    CarouselTip(
      icon: Icons.price_check_rounded,
      text: 'No hidden charges -- the price you accept is exactly '
          'what you pay.',
    ),
    CarouselTip(
      icon: Icons.list_alt_rounded,
      text: 'Compare multiple offers side by side -- no pressure to '
          'accept the first one.',
    ),
    CarouselTip(
      icon: Icons.star_rounded,
      text: 'Real ratings and reviews from real customers help you '
          'choose with confidence.',
    ),
    CarouselTip(
      icon: Icons.support_agent_rounded,
      text: 'Support is just a message away, right inside the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const TipsCarousel(
      headerIcon: Icons.workspace_premium_rounded,
      headerText: 'Why choose Habio',
      tips: _tips,
      reverse: true,
    );
  }
}
