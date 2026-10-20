import 'package:flutter/material.dart';
import 'welcome_screen.dart';

// ============================================================
// CUSTOMER APP -- POST-SPLASH ONBOARDING CAROUSEL
// ============================================================
//
// Restyled 2026-09-06 (Harsh's point 9, redo of point 4) to match
// the professional app's post-splash intro screen
// (professional_intro_screen.dart): the illustration fills the top
// of the screen instead of sitting below a logo, then a numbered
// circle-icon + bold title on one line, then the description
// paragraph below -- and, per his explicit instruction, the logo +
// "Habio" wordmark block that used to sit above the carousel is
// removed entirely so the illustration is the first thing on the
// screen. The three-illustration image padding was tightened
// (point 11) since this app's artwork is landscape-shaped, unlike
// the professional app's portrait artwork, so it needs less side
// padding to render at a comparable size. The feature-badges row
// (three icon+label chips, one per page) was dropped in the point-9
// restyle to match the professional app exactly, then restored per
// Harsh's point 12 -- it now sits below the subtitle on all three
// pages, its own icons per page (see the PageView below). Same
// three pages, same artwork (handshake.png, describe_problem.png,
// completed_service.png) and the same underlying copy -- only the
// hard line-breaks baked into the old two-line titles/descriptions
// are let wrap naturally instead. Nothing about what the carousel
// says or where "Skip"/"Next"/"Get Started" take you has changed.
//
// 2026-09-13: briefly reworked into a randomized 11-flyer
// differentiator carousel for Harsh's "advertisement flyers"
// request, then reverted the same day -- he wants that content on
// the Home screen instead (a compact swipeable strip near the
// welcome greeting), not replacing this post-splash explainer. This
// screen is back to the original 3-step "how it works" content
// below.
// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToWelcomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 4),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    children: const [
                      _IntroPage(
                        imageAsset: "assets/images/onboarding/handshake.png",
                        icon: Icons.verified_user_rounded,
                        number: '1',
                        title: 'Trusted Partners, Right at Home',
                        subtitle:
                            'Verified experts. Fair prices. Services you '
                            'can trust.',
                        badges: [
                          _FeatureBadge(
                            icon: Icons.verified_user_outlined,
                            label: 'Verified\nExperts',
                          ),
                          _FeatureBadge(
                            icon: Icons.sell_outlined,
                            label: 'Fair\nPricing',
                          ),
                          _FeatureBadge(
                            icon: Icons.thumb_up_outlined,
                            label: 'Reliable\nService',
                          ),
                        ],
                      ),
                      _IntroPage(
                        imageAsset:
                            "assets/images/onboarding/describe_problem.png",
                        icon: Icons.camera_alt_rounded,
                        number: '2',
                        title: 'Describe Your Problem',
                        subtitle:
                            "Tell us what's wrong, upload photos, and "
                            'receive quotes.',
                        badges: [
                          _FeatureBadge(
                            icon: Icons.photo_camera_outlined,
                            label: 'Upload\nPhotos',
                          ),
                          _FeatureBadge(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Quick\nQuotes',
                          ),
                          _FeatureBadge(
                            icon: Icons.bolt_outlined,
                            label: 'Fast\nResponse',
                          ),
                        ],
                      ),
                      _IntroPage(
                        imageAsset:
                            "assets/images/onboarding/completed_service.png",
                        icon: Icons.event_available_rounded,
                        number: '3',
                        title: 'Compare. Choose. Relax.',
                        subtitle:
                            'Choose the partner you trust and book '
                            'instantly.',
                        badges: [
                          _FeatureBadge(
                            icon: Icons.compare_arrows_rounded,
                            label: 'Compare\nOptions',
                          ),
                          _FeatureBadge(
                            icon: Icons.event_available_outlined,
                            label: 'Instant\nBooking',
                          ),
                          _FeatureBadge(
                            icon: Icons.spa_outlined,
                            label: 'Sit Back\n& Relax',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// PAGE INDICATOR
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageCount,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 8,
                        width: currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? const Color(0xFF1557FF)
                              : const Color(0xFFE1E7EF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                /// NEXT / GET STARTED BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage < _pageCount - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _goToWelcomeScreen();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1557FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentPage == _pageCount - 1
                                ? "Get Started"
                                : "Next",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),

            /// SKIP BUTTON
            Positioned(
              top: 6,
              right: 24,
              child: TextButton(
                onPressed: _goToWelcomeScreen,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SINGLE PAGE LAYOUT -- mirrors the professional app's _IntroPage
// exactly: illustration fills the top, then a numbered circle icon
// + bold title on one line, then the description paragraph below.
// ============================================================

class _IntroPage extends StatelessWidget {
  final String imageAsset;
  final IconData icon;
  final String number;
  final String title;
  final String subtitle;
  final List<_FeatureBadge> badges;

  const _IntroPage({
    required this.imageAsset,
    required this.icon,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),

        Expanded(
          child: Padding(
            // Tightened from horizontal: 30 (2026-09-06, Harsh's
            // point 11) -- these 3 illustrations are landscape-shaped
            // (1536x1024), unlike the professional app's portrait
            // artwork, so with BoxFit.contain the image is always
            // width-limited here: less side padding is the only lever
            // that makes it render bigger without cropping or
            // distorting it. New artwork in a portrait aspect ratio
            // would fill the space more fully still, but that's
            // parked for later (Higgsfield generation is out of
            // credits) -- this is the code-only improvement in the
            // meantime.
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint(error.toString());
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFF1557FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '$number. $title',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // FEATURE BADGES ROW (restored 2026-09-06, Harsh's point 12)
        // -- three icon+label chips, one per page, separated by thin
        // vertical dividers. Was dropped in the point-9 restyle to
        // match the professional app's screens (which don't have
        // one); Harsh asked for it back on all three pages.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _FeatureBadgeItem(badge: badges[0])),
              Container(
                width: 1,
                height: 48,
                margin: const EdgeInsets.only(top: 2),
                color: const Color(0xFFE1E7EF),
              ),
              Expanded(child: _FeatureBadgeItem(badge: badges[1])),
              Container(
                width: 1,
                height: 48,
                margin: const EdgeInsets.only(top: 2),
                color: const Color(0xFFE1E7EF),
              ),
              Expanded(child: _FeatureBadgeItem(badge: badges[2])),
            ],
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

// ============================================================
// FEATURE BADGE -- one icon+label chip in the row below the
// subtitle on each onboarding page.
// ============================================================

class _FeatureBadge {
  final IconData icon;
  final String label;

  const _FeatureBadge({required this.icon, required this.label});
}

class _FeatureBadgeItem extends StatelessWidget {
  final _FeatureBadge badge;

  const _FeatureBadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF3FF),
            shape: BoxShape.circle,
          ),
          child: Icon(badge.icon, color: const Color(0xFF1557FF), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          badge.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
