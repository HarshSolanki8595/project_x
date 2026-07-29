import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              "Harsh Solanki",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("My Bookings"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Saved Addresses"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help & Support"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}