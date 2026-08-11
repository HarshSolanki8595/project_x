import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1557FF);
    const Color darkText = Color(0xFF0F172A);
    const Color secondaryText = Color(0xFF64748B);
    const Color lightText = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            children: [

              // ------------------------------------------------------------
              // HABIO LOGO
              // ------------------------------------------------------------
              const SizedBox(height: 42),

              Hero(
                tag: "habio_logo",
                child: Image.asset(
                  "assets/logo/habio_logo_blue.png",
                  height: 105,
                  width: 105,
                  fit: BoxFit.contain,
                ),
              ),

              // ------------------------------------------------------------
              // WELCOME TITLE
              // ------------------------------------------------------------
              const SizedBox(height: 28),

              const Hero(
                tag: "habio_text",
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    "Welcome to Habio",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                      height: 1.15,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // MAIN TAGLINE
              // ------------------------------------------------------------
              const SizedBox(height: 14),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Connecting Homes with Trusted\nProfessionals",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // SUPPORTING TEXT
              // ------------------------------------------------------------
              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Find the right professional, compare your\n"
                  "options, and choose what works best for you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // CONTROLLED SPACE
              // ------------------------------------------------------------
              const SizedBox(height: 34),

              // ------------------------------------------------------------
              // LOGIN LABEL
              // ------------------------------------------------------------
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    bottom: 9,
                  ),
                  child: Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // LOGIN BUTTON
              // ------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // OR DIVIDER
              // ------------------------------------------------------------
              const SizedBox(height: 18),

              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE1E7EF),
                      thickness: 1,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE1E7EF),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              // ------------------------------------------------------------
              // CREATE ACCOUNT LABEL
              // ------------------------------------------------------------
              const SizedBox(height: 18),

              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    bottom: 9,
                  ),
                  child: Text(
                    "New to Habio?",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // CREATE ACCOUNT BUTTON
              // ------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,

                    side: const BorderSide(
                      color: primaryBlue,
                      width: 1.7,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),

                  child: const Text(
                    "Create New Account",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // GUEST
              // ------------------------------------------------------------
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {},

                style: TextButton.styleFrom(
                  foregroundColor: secondaryText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                ),

                child: const Text(
                  "Continue as Guest",
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // TRUST MESSAGE
              // ------------------------------------------------------------
              const SizedBox(height: 6),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 15,
                    color: primaryBlue,
                  ),

                  SizedBox(width: 6),

                  Text(
                    "Trusted professionals",
                    style: TextStyle(
                      color: lightText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "•",
                      style: TextStyle(
                        color: lightText,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  Text(
                    "Transparent pricing",
                    style: TextStyle(
                      color: lightText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // ------------------------------------------------------------
              // BOTTOM SAFE SPACE
              // ------------------------------------------------------------
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}