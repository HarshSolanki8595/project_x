import 'package:flutter/material.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const Spacer(),

              Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 70,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Booking Confirmed!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your request has been sent successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [

                      ListTile(
                        leading: Icon(Icons.confirmation_number),
                        title: Text("Booking ID"),
                        trailing: Text("#PX102548"),
                      ),

                      Divider(),

                      ListTile(
                        leading: Icon(Icons.schedule),
                        title: Text("Status"),
                        trailing: Text("Awaiting Acceptance"),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}