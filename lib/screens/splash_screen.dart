import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'create_profile_screen.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.35,
        1,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    Timer(
      const Duration(seconds: 5),
      () {
        if (!mounted) return;

        _routeAfterSplash();
      },
    );
  }

  // ============================================================
  // ROUTE BASED ON EXISTING FIREBASE AUTH SESSION
  // ============================================================
  //
  // Firebase Auth sessions persist across app restarts on their
  // own -- there was never any "inactivity logout" happening. The
  // real bug was that this splash screen always sent every launch
  // straight into the OnboardingScreen marketing carousel, ignoring
  // any already signed-in customer. This now checks the current
  // session and, if one exists, checks whether that customer's
  // profile document already exists (same check otp_screen.dart
  // already does after a fresh login) so they land on the main app
  // instead of being sent back through onboarding.
  //

  Future<void> _routeAfterSplash() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (userDoc.exists) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CreateProfileScreen(
            uid: user.uid,
            phoneNumber: user.phoneNumber ?? '',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1557FF);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [

          // --------------------------------------------------------
          // CITY OUTLINE (2026-08-28, FINAL): anchored to the
          // absolute bottom, faded, sits BEHIND the logo/text
          // --------------------------------------------------------
          //
          // This is the FIRST child in the Stack, so it renders
          // behind everything else placed after it (logo, "Habio",
          // tagline) -- it can never visually clash with or overlap
          // on top of them. Its bottom edge is pinned to bottom: 0
          // (the true bottom of the screen, not floating), and it
          // extends upward from there. A ShaderMask applies a
          // top-to-bottom alpha gradient on top of the existing
          // white re-tint (ColorFiltered srcIn) -- fully transparent
          // near the top, fading in to clearly visible by the
          // bottom -- so the cityscape reads as a soft background
          // texture rather than competing with the foreground
          // content above it.
          //

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * .55,
            child: ClipRect(
              child: IgnorePointer(
                child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                    ],
                    stops: [0.0, 0.55],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Opacity(
                    opacity: .6,
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        "assets/images/cityscape_gold_transparent_1.png",
                        width: size.width,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ),
          ),

          // --------------------------------------------------------
          // LOGO + WORDMARK + TAGLINE (2026-08-28, FINAL)
          // --------------------------------------------------------
          //
          // Reworked back to a single grouped Column, matching the
          // reference image directly, instead of three independently
          // percentage-positioned bands -- that approach kept
          // producing confusing, hard-to-predict sizing as each
          // element's box constrained or clipped it differently.
          // This group is vertically centered in the space ABOVE
          // the cityscape (not a fixed percentage offset), so it
          // stays correctly centered regardless of device screen
          // height. The cityscape above remains the FIRST child in
          // this Stack, so it always renders behind this group.
          //

          // --------------------------------------------------------
          // LOGO — ungrouped, independently positioned, sized by
          // WIDTH not height (2026-08-28). The mark is nearly
          // square (w/h ≈ 0.98), so on a tall narrow phone screen,
          // sizing it by a height fraction made it balloon out to
          // ~69% of screen WIDTH even at .32 height — width is the
          // tighter constraint here. 30% of screen width works out
          // to roughly 14% of screen height. Top offset unchanged
          // so it still clears the status bar / notch.
          // --------------------------------------------------------

          Positioned(
            top: size.height * .10,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Hero(
                    tag: "habio_logo",
                    child: Image.asset(
                      "assets/logo/habio_logo_white_solid_transparent.png",
                      width: size.width * .30,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --------------------------------------------------------
          // "HABIO" WORDMARK — ungrouped, independently positioned
          // --------------------------------------------------------
          //
          // Gap after logo (2026-08-28): with the logo now sized by
          // width (~14% of screen height instead of 32%), its
          // bottom edge sits much higher up, so this top offset was
          // brought in from .45 to .27 to close the resulting gap.
          //

          Positioned(
            top: size.height * .27,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _textFade,
                child: const Hero(
                  tag: "habio_text",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Habio",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --------------------------------------------------------
          // TAGLINE — same .10 gap after "Habio" as before
          // --------------------------------------------------------

          Positioned(
            top: size.height * .37,
            left: 24,
            right: 24,
            child: Center(
              child: FadeTransition(
                opacity: _textFade,
                child: const Text(
                  "Connecting Homes\nwith Trusted Professionals",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}