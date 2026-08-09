import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  final String uid;
  final String phoneNumber;

  const CreateProfileScreen({
    super.key,
    required this.uid,
    required this.phoneNumber,
  });

  @override
  State<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF0D47FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color lightText = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFD1D5DB);
  static const Color softBlue = Color(0xFFF1F5FF);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your full name."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .set({
        "uid": widget.uid,
        "fullName": name,
        "phoneNumber": widget.phoneNumber,
        "role": "customer",
        "createdAt": FieldValue.serverTimestamp(),
        "lastLogin": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create account: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // TOP BAR
              // ============================================================

              const SizedBox(height: 12),

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
                      "Create your account",
                      style: TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // HABIO LOGO
              // ============================================================

              const SizedBox(height: 20),

              Center(
                child: Hero(
                  tag: "habio_logo",
                  child: Image.asset(
                    "assets/logo/habio_logo_blue.png",
                    height: 72,
                    width: 72,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ============================================================
              // TITLE
              // ============================================================

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  "Almost there!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
              ),

              // ============================================================
              // SUBTITLE
              // ============================================================

              const SizedBox(height: 12),

              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Tell us your name to complete your\nHabio account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),
              ),

              // ============================================================
              // NAME LABEL
              // ============================================================

              const SizedBox(height: 34),

              const Text(
                "Full Name",
                style: TextStyle(
                  color: darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              // ============================================================
              // NAME FIELD
              // ============================================================

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,

                style: const TextStyle(
                  color: darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),

                decoration: InputDecoration(
                  hintText: "Enter your full name",

                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),

                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: secondaryText,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: borderColor,
                      width: 1.3,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: borderColor,
                      width: 1.3,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),

              // ============================================================
              // VERIFIED MOBILE LABEL
              // ============================================================

              const SizedBox(height: 25),

              const Text(
                "Verified Mobile Number",
                style: TextStyle(
                  color: darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              // ============================================================
              // VERIFIED MOBILE
              // ============================================================

              Container(
                width: double.infinity,
                height: 60,

                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDCE6FF),
                    width: 1.2,
                  ),
                ),

                child: Row(
                  children: [
                    const SizedBox(width: 17),

                    const Icon(
                      Icons.verified_outlined,
                      color: primaryBlue,
                      size: 23,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "+91 ${widget.phoneNumber}",
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        "Verified",
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // INFORMATION
              // ============================================================

              const SizedBox(height: 14),

              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: lightText,
                  ),

                  SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      "Your mobile number has been verified and "
                      "will be linked to your Habio account.",
                      style: TextStyle(
                        color: lightText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              // ============================================================
              // CREATE ACCOUNT BUTTON
              // ============================================================

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _createAccount,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor:
                        const Color(0xFFB8C7F5),
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              // ============================================================
              // BOTTOM MESSAGE
              // ============================================================

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  "You can update your profile details later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lightText,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
