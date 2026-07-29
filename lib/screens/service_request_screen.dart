import 'package:flutter/material.dart';
import 'address_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String categoryName;
  final String subCategoryName;

  const ServiceRequestScreen({
    super.key,
    required this.categoryName,
    required this.subCategoryName,
  });

  @override
  State<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState
    extends State<ServiceRequestScreen> {
  final TextEditingController issueController =
      TextEditingController();

  bool isEmergency = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Describe Your Issue"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [              Text(
                widget.categoryName,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.subCategoryName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Describe your issue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: issueController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText:
                      "Describe the problem in detail...\n\nExample:\nThe ceiling fan makes noise and stops after 5 minutes.",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),              const SizedBox(height: 25),

              const Text(
                "Upload Photos (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo),
                label: const Text("Add Photos"),
              ),

              const SizedBox(height: 20),

              const Text(
                "Upload Video (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.videocam),
                label: const Text("Add Video"),
              ),              const SizedBox(height: 30),

              SwitchListTile(
  value: isEmergency,
  activeThumbColor: Colors.red,
  activeTrackColor: Colors.red.shade200,
                title: const Text("Emergency Service"),
                subtitle: const Text(
                  "Need immediate assistance?",
                ),
                onChanged: (value) {
                  setState(() {
                    isEmergency = value;
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
  if (issueController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please describe your issue."),
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddressScreen(
        categoryName: widget.categoryName,
        subCategoryName: widget.subCategoryName,
        issueDescription: issueController.text.trim(),
        isEmergency: isEmergency,
      ),
    ),
  );
},
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),            ],
          ),
        ),
      ),
    );
  }
}