import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../models/service_request.dart';
import 'booking_confirmed_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  final ServiceRequest request;
  final Professional professional;

  const BookingSummaryScreen({
    super.key,
    required this.request,
    required this.professional,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Summary"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Service"),

            _infoTile(
              Icons.home_repair_service,
              request.categoryName,
            ),

            _infoTile(
              Icons.handyman,
              request.subCategoryName,
            ),

            const SizedBox(height: 20),

            _sectionTitle("Issue"),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  request.issueDescription,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Professional"),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(professional.name),
                subtitle: Text(
                  "⭐ ${professional.rating} • ${professional.experience} Years Experience",
                ),
                trailing: Text(
                  "₹${professional.quote.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Address"),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  request.address ?? "",
                ),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Schedule"),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      request.preferredDate == null
                          ? ""
                          : "${request.preferredDate!.day}/${request.preferredDate!.month}/${request.preferredDate!.year}",
                    ),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      request.preferredTimeSlot ?? "",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingConfirmedScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String text,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }
}