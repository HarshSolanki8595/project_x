import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController =
      TextEditingController();

  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE1E7EF);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final phone = _phoneController.text.trim();

    // ------------------------------------------------------------
    // VALIDATE PHONE NUMBER
    // ------------------------------------------------------------

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid 10-digit mobile number",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final fullPhoneNumber = "+91$phone";

    print("==============================================");
    print("FIREBASE PHONE AUTH STARTED");
    print("PHONE: $fullPhoneNumber");
    print("==============================================");

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        // --------------------------------------------------------
        // AUTOMATIC VERIFICATION
        // --------------------------------------------------------

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          print("==============================================");
          print("FIREBASE VERIFICATION COMPLETED AUTOMATICALLY");
          print("==============================================");

          try {
            await FirebaseAuth.instance
                .signInWithCredential(credential);

            print("Firebase sign-in successful.");

            if (!mounted) return;

            setState(() {
              _isLoading = false;
            });

            Navigator.pushReplacementNamed(
              context,
              "/home",
            );
          } on FirebaseAuthException catch (e) {
            print("==============================================");
            print("SIGN-IN WITH CREDENTIAL FAILED");
            print("CODE: ${e.code}");
            print("MESSAGE: ${e.message}");
            print("==============================================");

            if (!mounted) return;

            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.message ??
                      "Unable to complete sign-in.",
                ),
              ),
            );
          }
        },

        // --------------------------------------------------------
        // VERIFICATION FAILED
        // --------------------------------------------------------

        verificationFailed:
            (FirebaseAuthException e) {
          print("==============================================");
          print("FIREBASE PHONE AUTH FAILED");
          print("CODE: ${e.code}");
          print("MESSAGE: ${e.message}");
          print("PLUGIN: ${e.plugin}");
          print("==============================================");

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 6),
              content: Text(
                "${e.code}\n${e.message ?? "Phone verification failed"}",
              ),
            ),
          );
        },

        // --------------------------------------------------------
        // SMS CODE SENT
        // --------------------------------------------------------

        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          print("==============================================");
          print("FIREBASE OTP CODE SENT");
          print("VERIFICATION ID RECEIVED");
          print("==============================================");

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phoneNumber: phone,
                verificationId: verificationId,
              ),
            ),
          );
        },

        // --------------------------------------------------------
        // AUTO RETRIEVAL TIMEOUT
        // --------------------------------------------------------

        codeAutoRetrievalTimeout:
            (String verificationId) {
          print("==============================================");
          print("FIREBASE AUTO RETRIEVAL TIMEOUT");
          print("==============================================");
        },
      );
    } on FirebaseAuthException catch (e) {
      print("==============================================");
      print("FIREBASE AUTH EXCEPTION");
      print("CODE: ${e.code}");
      print("MESSAGE: ${e.message}");
      print("PLUGIN: ${e.plugin}");
      print("==============================================");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            "${e.code}\n${e.message ?? "Firebase authentication error"}",
          ),
        ),
      );
    } catch (e) {
      print("==============================================");
      print("UNEXPECTED PHONE AUTH ERROR");
      print(e);
      print("==============================================");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            "Unexpected error: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primaryBlue,
          selectionColor: Color(0x331557FF),
          selectionHandleColor: primaryBlue,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ============================================================
                // TOP LOGO
                // ============================================================

                const SizedBox(height: 42),

                Center(
                  child: Hero(
                    tag: "habio_logo",
                    child: Image.asset(
                      "assets/logo/habio_logo_blue.png",
                      height: 92,
                      width: 92,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // ============================================================
                // TITLE
                // ============================================================

                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    "Enter Your Mobile\nNumber",
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

                // ============================================================
                // SUBTITLE
                // ============================================================

                const SizedBox(height: 14),

                const Center(
                  child: Text(
                    "Login or create your Habio account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),

                // ============================================================
                // MOBILE NUMBER SECTION
                // ============================================================

                const SizedBox(height: 42),

                const Text(
                  "Mobile Number",
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: lightBorder,
                      width: 1.3,
                    ),
                  ),

                  child: Row(
                    children: [

                      // ======================================================
                      // COUNTRY CODE
                      // ======================================================

                      const Padding(
                        padding: EdgeInsets.only(
                          left: 18,
                          right: 12,
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "🇮🇳",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),

                            SizedBox(width: 8),

                            Text(
                              "+91",
                              style: TextStyle(
                                color: darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ======================================================
                      // VERTICAL DIVIDER
                      // ======================================================

                      Container(
                        height: 28,
                        width: 1,
                        color: lightBorder,
                      ),

                      // ======================================================
                      // PHONE INPUT
                      // ======================================================

                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          cursorColor: primaryBlue,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          style: const TextStyle(
                            color: darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),

                          decoration:
                              const InputDecoration(
                            hintText:
                                "Enter mobile number",

                            hintStyle: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),

                            border: InputBorder.none,

                            counterText: "",

                            contentPadding:
                                EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================================
                // CONTINUE BUTTON
                // ============================================================

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _continue,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,

                      disabledBackgroundColor:
                          primaryBlue.withValues(
                        alpha: 0.6,
                      ),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                // ============================================================
                // OR
                // ============================================================

                const SizedBox(height: 34),

                Row(
                  children: [

                    const Expanded(
                      child: Divider(
                        color: Color(0xFFE1E7EF),
                        thickness: 1,
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),

                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w500,
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

                // ============================================================
                // GOOGLE BUTTON
                // ============================================================

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Google Sign-In will be added later.",
                                ),
                              ),
                            );
                          },

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,

                      side: const BorderSide(
                        color: lightBorder,
                        width: 1.3,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        const Text(
                          "G",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ============================================================
                // SECURITY MESSAGE
                // ============================================================

                const SizedBox(height: 34),

                Center(
                  child: Column(
                    children: [

                      const Text(
                        "We'll send you a one-time password",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "By continuing, you agree to our\n"
                        "Terms & Privacy Policy",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================================
                // BOTTOM SPACE
                // ============================================================

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}