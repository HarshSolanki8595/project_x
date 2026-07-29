import 'package:flutter/material.dart';

import '../models/booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.confirmation_number,
                  color: Colors.deepPurple,
                ),
                title: const Text("Booking ID"),
                subtitle: Text(booking.bookingId),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Professional",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Row(
                      children: [

                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                booking.professional.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "⭐ ${booking.professional.rating} (${booking.professional.reviews} Reviews)",
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "${booking.professional.experience} Years Experience",
                              ),

                            ],
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call),
                            label: const Text("Call"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat),
                            label: const Text("Chat"),
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),            const Text(
              "Service Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_repair_service),
                    title: const Text("Category"),
                    subtitle: Text(booking.request.categoryName),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.handyman),
                    title: const Text("Service"),
                    subtitle: Text(booking.request.subCategoryName),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text("Issue Description"),
                    subtitle: Text(
                      booking.request.issueDescription,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Visit Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Address"),
                    subtitle: Text(
                      booking.request.address ?? "-",
                    ),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Date"),
                    subtitle: Text(
                      booking.request.preferredDate == null
                          ? "-"
                          : "${booking.request.preferredDate!.day}/${booking.request.preferredDate!.month}/${booking.request.preferredDate!.year}",
                    ),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text("Time Slot"),
                    subtitle: Text(
                      booking.request.preferredTimeSlot ?? "-",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Quote",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.currency_rupee,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  "₹${booking.professional.quote.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.deepPurple,
                  ),
                ),
                subtitle: Text(
                  booking.professional.quoteDescription,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Booking Status",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [

                    _TimelineTile(
                      title: "Booking Confirmed",
                      completed: true,
                    ),

                    Divider(),

                    _TimelineTile(
                      title: "Professional Accepted",
                      completed: false,
                    ),

                    Divider(),

                    _TimelineTile(
                      title: "Professional On The Way",
                      completed: false,
                    ),

                    Divider(),

                    _TimelineTile(
                      title: "Service Started",
                      completed: false,
                    ),

                    Divider(),

                    _TimelineTile(
                      title: "Service Completed",
                      completed: false,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Cancel Booking feature coming soon",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.cancel),
                label: const Text(
                  "Cancel Booking",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String title;
  final bool completed;

  const _TimelineTile({
    required this.title,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.grey,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: completed ? Colors.black : Colors.grey,
              fontWeight: completed
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}