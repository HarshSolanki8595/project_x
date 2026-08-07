import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "image": "assets/images/onboarding/handshake.png",
      "title": "Trusted Professionals,\nRight at Home",
      "description": "Verified experts. Fair prices.\nServices you can trust.",
      "features": [
        {"icon": Icons.verified_user_outlined, "label": "Verified\nExperts"},
        {"icon": Icons.sell_outlined, "label": "Fair\nPricing"},
        {"icon": Icons.thumb_up_outlined, "label": "Reliable\nService"},
      ],
    },
    {
      "image": "assets/images/onboarding/describe_problem.png",
      "title": "Describe Your\nProblem",
      "description":
          "Tell us what's wrong, upload photos,\nand receive quotes.",
      "features": [
        {"icon": Icons.camera_alt_outlined, "label": "Upload\nPhotos"},
        {"icon": Icons.chat_bubble_outline, "label": "Quick\nQuotes"},
        {"icon": Icons.bolt_outlined, "label": "Fast\nResponse"},
      ],
    },
    {
      "image": "assets/images/onboarding/completed_service.png",
      "title": "Compare.\nChoose. Relax.",
      "description":
          "Choose the professional you trust\nand book instantly.",
      "features": [
        {"icon": Icons.compare_arrows_outlined, "label": "Compare\nOptions"},
        {"icon": Icons.event_available_outlined, "label": "Instant\nBooking"},
        {"icon": Icons.spa_outlined, "label": "Sit Back\n& Relax"},
      ],
    },
  ];

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
        child: Column(
          children: [
            /// SKIP BUTTON
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 24),
              child: Align(
                alignment: Alignment.topRight,
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
            ),

            /// LOGO — the hero element, no wordmark, same on every page
            Image.asset(
              "assets/logo/habio_logo_blue.png",
              height: 92,
            ),

            const SizedBox(height: 10),

            /// PAGE VIEW — title, subtitle, illustration, badges all change per page
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final features =
                      page["features"] as List<Map<String, dynamic>>;

                  return Column(
                    children: [
                      /// TITLE (smaller than before)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          page["title"] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            height: 1.15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// SUBTITLE (smaller still)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          page["description"] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// ILLUSTRATION — enlarged to fill remaining space
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: Image.asset(
                            page["image"] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(error.toString());
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(20),
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

                      const SizedBox(height: 10),

                      /// FEATURE BADGES ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(features.length, (i) {
                          final feature = features[i];
                          return Row(
                            children: [
                              _FeatureBadge(
                                icon: feature["icon"] as IconData,
                                label: feature["label"] as String,
                              ),
                              if (i != features.length - 1)
                                Container(
                                  height: 34,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  color: const Color(0xFFE2E8F0),
                                ),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),

            /// PAGE INDICATOR
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: 8,
                    width: currentPage == index ? 28 : 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? const Color(0xFF0D47FF)
                          : const Color(0xFFD1D5DB),
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
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToWelcomeScreen();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47FF),
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
                        currentPage == pages.length - 1
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

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/// Small reusable widget for the "Verified Experts / Fair Pricing / ..."
/// badges shown under the illustration.
class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EDFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0D47FF),
            size: 18,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
