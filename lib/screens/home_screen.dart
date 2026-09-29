import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/widgets/ask_projectx_card.dart';
import '../core/widgets/category_grid.dart';
import '../core/widgets/continue_booking_card.dart';
import '../core/widgets/emergency_card.dart';
import '../core/widgets/frequently_used_section.dart';
import '../core/widgets/home_app_bar.dart';
import '../core/widgets/home_search_bar.dart';
import '../core/widgets/quick_services_section.dart';
import '../core/widgets/trending_services.dart';

import 'categories/subcategory_screen.dart';
import 'emergency_assistance_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'service_request_screen.dart';

class HomeScreen extends StatefulWidget {
  // ============================================================
  // HOME FLYER BANNER SELECTION -- added 2026-09-13
  // ============================================================
  //
  // Passed in from MainNavigationScreen rather than picked here,
  // because this screen sits inside an IndexedStack there and is
  // only ever built once per app launch -- its own initState
  // wouldn't re-run each time the customer switches back to the
  // Home tab. MainNavigationScreen owns the bottom nav tap handler,
  // so it's what re-picks 3 of the 11 flyers (see kHomeFlyers below)
  // every time the customer actually lands on Home, and hands the
  // fresh list down here.
  final List<FlyerContent> flyers;

  // ADDED (2026-09-16): same "owned by the parent, not this screen"
  // reasoning as `flyers` above -- MainNavigationScreen already
  // computes the live unread-notification count for the bottom nav
  // badge, so it hands the same count here rather than this screen
  // re-querying Firestore itself. onNotificationTap lets the top-right
  // bell act exactly like tapping the bottom bar's Notifications tab
  // (same _onItemTapped(2) call), instead of pushing a separate
  // screen on top. Both optional/nullable so the orphaned
  // main_screen.dart nav host (see its own comments) keeps compiling
  // without needing to wire either one up.
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const HomeScreen({
    super.key,
    required this.flyers,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasActiveBooking = false;
  String userName = "User";

  static const Color backgroundColor = Color(0xFFF7F8FC);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);

  // ============================================================
  // FIRST-ORDERS FEE WAIVER POPUP -- added 2026-09-11
  // ============================================================
  //
  // Customer-side counterpart to the professional app's "Refer &
  // Earn" popup (professional_home_screen.dart) -- same dialog
  // shape/style and the same once-per-app-launch guard via a static
  // bool, but shown here to surface the first-orders platform-fee
  // waiver (built 2026-09-09) instead. Only shown while the customer
  // still has at least one of their first 3 fee-free orders left --
  // platformFeeWaiversUsed on this same users/{uid} doc is the live
  // counter (see FIRST_ORDERS_FEE_WAIVER_COUNT and
  // createRazorpayOrder/verifyRazorpayPayment in functions/index.js),
  // incremented only on an actually-verified waived payment. Once a
  // customer has used all 3, this stays silent for good on every
  // future launch -- no separate "dismissed permanently" flag needed,
  // the real counter already does that job.
  //

  static bool _waiverPopupShown = false;

  static const int _totalFreeOrders = 3;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      setState(() {
        userName = doc["fullName"] ?? "User";
      });

      final int waiversUsed =
          (doc.data()?['platformFeeWaiversUsed'] as num?)?.toInt() ?? 0;

      final int remaining =
          (_totalFreeOrders - waiversUsed).clamp(0, _totalFreeOrders);

      if (remaining > 0 && !_waiverPopupShown) {
        _waiverPopupShown = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showWaiverPopup(remaining);
          }
        });
      }
    }
  }

  void _showWaiverPopup(int remaining) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF6EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration_rounded,
                        color: Color(0xFF15803D),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your First 3 Orders Are\nPlatform-Fee-Free!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      remaining == _totalFreeOrders
                          ? "We've waived the platform fee and GST on "
                              'your first $_totalFreeOrders orders -- pay '
                              'only the service price. It applies '
                              'automatically at checkout, no code needed.'
                          : 'You have $remaining of $_totalFreeOrders '
                              'fee-free orders left -- pay only the '
                              'service price, no platform fee or GST '
                              'added.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: secondaryText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1557FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------------
              // CLOSE (X) -- top right, matches the referral popup
              // ------------------------------------------------------

              Positioned(
                top: -12,
                right: -12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: darkText,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAskProjectX() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ServiceRequestScreen(
          categoryName: "Ask Habio",
          subCategoryName: "AI Diagnosis",
          // No fixed subcategory here — the customer is describing
          // the problem in free text, so capabilityId is left empty
          // and finding_professionals_screen falls back to
          // RequestClassifier to work it out from the description.
          subCategoryId: "",
        ),
      ),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapScreen(),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAppBar(
                location: "Mumbai",
                onLocationTap: _openMap,
                onNotificationTap: widget.onNotificationTap,
                showUnreadDot: widget.notificationCount > 0,
              ),

              const SizedBox(height: 12),

              // ============================================================
              // MOVED (2026-09-16): the flyer banner now sits right below
              // the location bar and above the "Welcome" greeting, instead
              // of below it -- was: HomeAppBar -> Welcome text -> flyers ->
              // search bar; now: HomeAppBar -> flyers -> Welcome text ->
              // search bar. Nothing about the banner itself (the
              // 3-of-11-random-flyers selection, the reshuffle-on-Home-tab
              // logic in MainNavigationScreen) changed, only where it's
              // drawn in this Column.
              // ============================================================

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FlyerBanner(
                  key: ValueKey(widget.flyers),
                  flyers: widget.flyers,
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome $userName 👋",
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      "How can we help you today?",
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              HomeSearchBar(
                onTap: _openSearch,
                onVoiceTap: () {},
              ),

              const SizedBox(height: 22),

              AskProjectXCard(
                onTap: _openAskProjectX,
                onVoiceTap: _openAskProjectX,
                onCameraTap: _openAskProjectX,
              ),

              if (hasActiveBooking) ...[
                const SizedBox(height: 22),
                ContinueBookingCard(
                  isVisible: hasActiveBooking,
                  onContinue: () {},
                ),
              ],

              const SizedBox(height: 30),

              QuickServicesSection(
                onCategoryTap: (category) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubcategoryScreen(
                        categoryName: category,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              FrequentlyUsedSection(
                onServiceTap: (category) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubcategoryScreen(
                        categoryName: category,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              CategoryGrid(
                onCategoryTap: (category) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubcategoryScreen(
                        categoryName: category,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              TrendingServices(
                onServiceTap: (service) {},
              ),

              const SizedBox(height: 32),

              EmergencyCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyAssistanceScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// HOME FLYER BANNER -- added 2026-09-13
// ================================================================
//
// Compact promotional strip shown right under "Welcome $userName",
// above the search bar. Shows 3 of the 11 differentiator flyers in
// kHomeFlyers below -- which 3, and in what order, is decided by
// MainNavigationScreen every time the customer lands on the Home
// tab (see _pickFlyers there), not by this widget. Swipe left/right
// between them; the dots below track position.
//
// Keyed on the flyers list itself where it's built above: a genuine
// reshuffle passes a brand-new List instance, which changes the key
// and remounts this widget fresh (back to page 0, new
// PageController) -- an unrelated rebuild of this screen passes the
// *same* List back, so the key is unchanged and whatever card the
// customer is looking at stays put.
// ================================================================

class _FlyerBanner extends StatefulWidget {
  final List<FlyerContent> flyers;

  const _FlyerBanner({super.key, required this.flyers});

  @override
  State<_FlyerBanner> createState() => _FlyerBannerState();
}

class _FlyerBannerState extends State<_FlyerBanner> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 82,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.flyers.length,
            onPageChanged: (index) {
              setState(() {
                _page = index;
              });
            },
            itemBuilder: (context, index) {
              final flyer = widget.flyers[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      flyer.accentColor.withOpacity(0.10),
                      flyer.accentColor.withOpacity(0.03),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: flyer.accentColor.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        flyer.icon,
                        color: flyer.accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            flyer.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _HomeScreenState.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            flyer.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _HomeScreenState.secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.flyers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              width: _page == index ? 14 : 4,
              decoration: BoxDecoration(
                color: _page == index
                    ? const Color(0xFF1557FF)
                    : const Color(0xFFD7DEEA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FLYER CONTENT POOL -- 11 promotional differentiator flyers. 3 of
// these are picked at random (see _pickFlyers in
// MainNavigationScreen) every time the customer lands on the Home
// tab. Public (no leading underscore) so MainNavigationScreen, in
// main_navigation_screen.dart, can import and shuffle it.
// ================================================================

class FlyerContent {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;

  const FlyerContent({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });
}

const List<FlyerContent> kHomeFlyers = [
  FlyerContent(
    icon: Icons.home_rounded,
    accentColor: Color(0xFF1557FF),
    title: 'One App for All Your Home Needs',
    subtitle:
        'From quick fixes to full home services -- book everything '
        'you need, all in one place.',
  ),
  FlyerContent(
    icon: Icons.celebration_rounded,
    accentColor: Color(0xFF15803D),
    title: 'Your First 3 Orders Are Fee-Free',
    subtitle:
        'No platform fee or GST on your first 3 orders -- pay only '
        'the service price.',
  ),
  FlyerContent(
    icon: Icons.receipt_long_rounded,
    accentColor: Color(0xFFD97706),
    title: 'No Hidden Charges, Ever',
    subtitle:
        'See the service price, platform fee and GST upfront -- '
        'before you pay a rupee.',
  ),
  FlyerContent(
    icon: Icons.bolt_rounded,
    accentColor: Color(0xFFEA580C),
    title: 'Instant Price, Instant Booking',
    subtitle:
        'Skip the wait for quotes -- Quick Services shows a fixed '
        'price you can book right away.',
  ),
  FlyerContent(
    icon: Icons.balance_rounded,
    accentColor: Color(0xFF4338CA),
    title: 'Fairness, Both Ways',
    subtitle:
        'Professionals are held accountable for cancellations too '
        '-- not just you.',
  ),
  FlyerContent(
    icon: Icons.verified_user_rounded,
    accentColor: Color(0xFF1557FF),
    title: 'Verified Pros, Real Ratings',
    subtitle:
        'Every professional is verified, rated and reviewed -- so '
        "you know who's coming.",
  ),
  FlyerContent(
    icon: Icons.camera_alt_rounded,
    accentColor: Color(0xFF7C3AED),
    title: 'Proof the Job Is Actually Done',
    subtitle:
        'Every job wraps up with photo verification -- no more '
        'taking their word for it.',
  ),
  FlyerContent(
    icon: Icons.support_agent_rounded,
    accentColor: Color(0xFFDB2777),
    title: 'A Real Person, Not a Bot',
    subtitle:
        'Need help? Chat with real human support, right inside the '
        'app.',
  ),
  FlyerContent(
    icon: Icons.schedule_rounded,
    accentColor: Color(0xFF0891B2),
    title: 'Book Any Time You Want',
    subtitle:
        'Pick any slot across the full day -- mornings, evenings, '
        'whatever works for you.',
  ),
  FlyerContent(
    icon: Icons.lock_rounded,
    accentColor: Color(0xFF0D9488),
    title: 'Pay Safely, Every Time',
    subtitle:
        'All payments are secured through Razorpay -- no cash, no '
        'guesswork.',
  ),
  FlyerContent(
    icon: Icons.emergency_rounded,
    accentColor: Color(0xFFDC2626),
    title: "Need It Urgently? We've Got You",
    subtitle:
        'Mark a request as urgent and get prioritized help when it '
        'matters most.',
  ),
];
