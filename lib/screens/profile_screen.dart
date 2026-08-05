import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bookings_screen.dart';
import 'saved_addresses_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first."),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data =
            snapshot.data?.data() as Map<String, dynamic>?;

        final fullName =
            data?["fullName"] ?? "User";

        final phoneNumber =
            data?["phoneNumber"] ?? "";

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Profile"),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(
                radius: 55,
                child: Icon(
                  Icons.person,
                  size: 55,
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "+91 $phoneNumber",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ListTile(
                leading:
                    const Icon(Icons.receipt_long),
                title: const Text("My Bookings"),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BookingsScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(Icons.location_on),
                title:
                    const Text("Saved Addresses"),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SavedAddressesScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(Icons.settings),
                title: const Text("Settings"),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {},
              ),

              ListTile(
                leading:
                    const Icon(Icons.help_outline),
                title:
                    const Text("Help & Support"),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance
                      .signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}