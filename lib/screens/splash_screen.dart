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
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
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

          /// CITY OUTLINE
          Positioned(
            left: 0,
            right: 0,
            top: size.height * .45,
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: .22,
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/images/city_outline_gold.png",
                    width: size.width,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          /// LOGO
          Positioned(
            top: size.height * .08,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Hero(
                  tag: "habio_logo",
                  child: Image.asset(
                    "assets/logo/habio_logo_white.png",
                    height: 340,
                  ),
                ),
              ),
            ),
          ),

          /// HABIO TITLE
          Positioned(
            top: size.height * .39,
            left: 0,
            right: 0,
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
                      fontSize: 74,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// TAGLINE
          Positioned(
            top: size.height * .515,
            left: 28,
            right: 28,
            child: FadeTransition(
              opacity: _textFade,
              child: const Text(
                "Connecting Homes\nwith Trusted Professionals",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}