import 'dart:async';

import 'package:flutter/material.dart';
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

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration:
                const Duration(milliseconds: 900),

            pageBuilder: (_, __, ___) =>
                const OnboardingScreen(),

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
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D47FF);

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