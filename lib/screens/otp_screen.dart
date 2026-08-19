import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'create_profile_screen.dart';
import 'main_navigation_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color lightText = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);

  bool get isOtpComplete =>
      controllers.every((controller) => controller.text.isNotEmpty);

  String get otp => controllers.map((e) => e.text).join();

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> verifyOtp() async {
    if (!isOtpComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the complete OTP")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final uid = userCredential.user!.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (userDoc.exists) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CreateProfileScreen(
              uid: uid,
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "OTP verification failed")),
      );
    }
  }

  // ============================================================
  // AUTO-READ OTP
  // ============================================================
  //
  // Android's Autofill framework detects an incoming SMS OTP and
  // offers to fill it into whichever field carries
  // AutofillHints.oneTimeCode (box 0, see otpBox below). That
  // delivers the full 6-digit code as one string into a single
  // field -- this splits it across all 6 boxes and submits
  // automatically, without changing how any box looks or how
  // manual typing works. No new package, no extra permissions
  // required.
  //

  void _handleAutofillPaste(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 6) return;

    final code = digits.substring(digits.length - 6);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var i = 0; i < 6; i++) {
        controllers[i].text = code[i];
      }
      setState(() {});
      FocusScope.of(context).unfocus();
      verifyOtp();
    });
  }

  Widget otpBox(int index) {
    final bool isFilled = controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 48,
      height: 60,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        autofillHints:
            index == 0 ? const [AutofillHints.oneTimeCode] : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          if (index == 0)
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.length > 1) {
                _handleAutofillPaste(newValue.text);
                return oldValue;
              }
              return newValue;
            }),
        ],
        style: const TextStyle(
          color: primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: isFilled ? const Color(0xFFF5F8FF) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor, width: 1.3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor, width: 1.3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 29,
                        color: darkText,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 18),
                    const Text(
                      "Verify your number",
                      style: TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Hero(
                  tag: "habio_logo",
                  child: Image.asset(
                    "assets/logo/habio_logo_blue.png",
                    height: 70,
                    width: 70,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  "Verify your number",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  "We've sent a 6-digit verification code to\n"
                  "+91 ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              AutofillGroup(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, otpBox),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Resend OTP will be added shortly."),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryBlue,
                    backgroundColor: const Color(0xFFEEF3FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: (_isLoading || !isOtpComplete)
                      ? null
                      : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor: const Color(0xFFB8C7F5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  "Didn't receive the code?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: lightText, fontSize: 14),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Resend OTP will be added shortly."),
                      ),
                    );
                  },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}