import 'dart:async';

import 'package:flutter/material.dart';

import '../models/service_request.dart';
import 'professionals_screen.dart';

class FindingProfessionalsScreen extends StatefulWidget {
  final ServiceRequest request;

  const FindingProfessionalsScreen({
    super.key,
    required this.request,
  });

  @override
  State<FindingProfessionalsScreen> createState() =>
      _FindingProfessionalsScreenState();
}

class _FindingProfessionalsScreenState
    extends State<FindingProfessionalsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color backgroundColor = Color(0xFFF7F8FC);

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfessionalsScreen(
              request: widget.request,
            ),
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

  Widget _statusItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 21,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              ScaleTransition(
                scale: _animation,
                child: Container(
                  height: 118,
                  width: 118,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.20),
                        blurRadius: 28,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Finding Professionals",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Searching nearby verified professionals\nwho can help with your request.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                height: 7,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _statusItem(
                      icon: Icons.verified_rounded,
                      iconColor: Colors.green,
                      title: "Verified Professionals Only",
                      subtitle: "Matching trusted professionals",
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    _statusItem(
                      icon: Icons.location_on_rounded,
                      iconColor: primaryBlue,
                      title: "Checking Your Location",
                      subtitle: "Finding professionals nearby",
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    _statusItem(
                      icon: Icons.request_quote_rounded,
                      iconColor: Colors.orange,
                      title: "Request Sent",
                      subtitle: "Waiting for quotations",
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              const Text(
                "Professionals will decide their price.\nYou decide which offer is right for you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
