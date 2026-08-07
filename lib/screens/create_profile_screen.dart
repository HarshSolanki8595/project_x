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

class _CreateProfileScreenState
    extends State<CreateProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  bool _isLoading = false;

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

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Create Your Account",
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 90,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "Almost There!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "Tell us your name to complete your Habio account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Full Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _nameController,
                textCapitalization:
                    TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Verified Mobile Number",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.phone),
                  hintText:
                      "+91 ${widget.phoneNumber}",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const Spacer(),              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor:
                        Colors.deepPurple.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}