import 'package:flutter/material.dart';

import '../models/service_request.dart';
import 'review_booking_screen.dart';

class DateTimeScreen extends StatefulWidget {
  final ServiceRequest request;

  const DateTimeScreen({
    super.key,
    required this.request,
  });

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  DateTime selectedDate = DateTime.now();

  String selectedSlot = "Anytime";

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget buildOption(String title) {
    return RadioListTile<String>(
      value: title,
      groupValue: selectedSlot,
      title: Text(title),
      onChanged: (value) {
        setState(() {
          selectedSlot = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text("Schedule Service"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "When do you need the service?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: pickDate,
            ),

            const SizedBox(height: 20),

            buildOption("Morning"),
            buildOption("Afternoon"),
            buildOption("Evening"),
            buildOption("Anytime"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
  onPressed: () {
    widget.request.preferredDate = selectedDate;
    widget.request.preferredTimeSlot = selectedSlot;

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReviewBookingScreen(
      request: widget.request,
    ),
  ),
);
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