import 'package:flutter/material.dart';

class AddressScreen extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;
  final String issueDescription;
  final bool isEmergency;

  const AddressScreen({
    super.key,
    required this.categoryName,
    required this.subCategoryName,
    required this.issueDescription,
    required this.isEmergency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: const Text("Service Address"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Where do you need the service?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Choose an address or add a new one.",
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.my_location,
                  color: Colors.deepPurple,
                ),
                title: const Text("Use Current Location"),
                subtitle: const Text(
                  "Detect automatically",
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.home,
                  color: Colors.deepPurple,
                ),
                title: const Text("Home"),
                subtitle: const Text(
                  "No saved address",
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.add_location_alt,
                  color: Colors.deepPurple,
                ),
                title: const Text("Add New Address"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {

                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}