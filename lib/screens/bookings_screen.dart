import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/services/booking_repository.dart';
import '../models/booking.dart';
import 'booking_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      body: StreamBuilder<List<Booking>>(

        stream: BookingRepository.bookings(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          final upcomingBookings = bookings.where((booking) {

            return booking.status ==
                    BookingStatus.awaitingAcceptance ||
                booking.status ==
                    BookingStatus.accepted;

          }).toList();

          final ongoingBookings = bookings.where((booking) {

            return booking.status ==
                    BookingStatus.onTheWay ||
                booking.status ==
                    BookingStatus.inProgress;

          }).toList();

          final completedBookings = bookings.where((booking) {

            return booking.status ==
                BookingStatus.completed;

          }).toList();

          final cancelledBookings = bookings.where((booking) {

            return booking.status ==
                BookingStatus.cancelled;

          }).toList();

          return TabBarView(

            controller: _tabController,

            children: [

              _buildBookings(upcomingBookings),

              _buildBookings(ongoingBookings),

              _buildBookings(completedBookings),

              _buildBookings(cancelledBookings),

            ],

          );

        },

      ),

    );

  }  Widget _buildBookings(List<Booking> bookings) {

    if (bookings.isEmpty) {

      return const Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey,
            ),

            SizedBox(height: 20),

            Text(
              "No bookings found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Your bookings will appear here.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

          ],

        ),

      );

    }

    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: bookings.length,

      itemBuilder: (context, index) {

        final booking = bookings[index];

        return Card(

          margin: const EdgeInsets.only(bottom: 16),

          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: InkWell(

            borderRadius: BorderRadius.circular(16),

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => BookingDetailsScreen(
                    booking: booking,
                  ),

                ),

              );

            },

            child: Padding(

              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Row(

                    children: [

                      Expanded(

                        child: Text(

                          booking.request.subCategoryName,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),

                        ),

                      ),

                      _statusChip(booking.status),

                    ],

                  ),

                  const SizedBox(height: 16),

                  ListTile(

                    contentPadding: EdgeInsets.zero,

                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),

                    title: Text(
                      booking.professional.name,
                    ),

                    subtitle: Text(
                      "⭐ ${booking.professional.rating} • ${booking.professional.experience} Years Experience",
                    ),

                    trailing: Text(
                      "₹${booking.professional.quote.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 18,
                      ),
                    ),

                  ),

                  const Divider(),

                  const SizedBox(height: 8),

                  Row(

                    children: [

                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 8),

                      Text(

                        booking.request.preferredDate == null
                            ? "-"
                            : "${booking.request.preferredDate!.day}/${booking.request.preferredDate!.month}/${booking.request.preferredDate!.year}",

                      ),

                    ],

                  ),

                  const SizedBox(height: 10),

                  Row(

                    children: [

                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        booking.request.preferredTimeSlot ?? "-",
                      ),

                    ],

                  ),

                  const SizedBox(height: 10),

                  Row(

                    children: [

                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 8),

                      Expanded(

                        child: Text(

                          booking.request.address ?? "-",

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 16),

                  Align(

                    alignment: Alignment.centerRight,

                    child: TextButton.icon(

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) => BookingDetailsScreen(
                              booking: booking,
                            ),

                          ),

                        );

                      },

                      icon: const Icon(Icons.arrow_forward),

                      label: const Text("View Details"),

                    ),

                  ),

                ],

              ),

            ),

          ),

        );

      },

    );

  }  Widget _statusChip(BookingStatus status) {
    Color color;
    String text;

    switch (status) {
      case BookingStatus.awaitingAcceptance:
        color = Colors.orange;
        text = "Awaiting Acceptance";
        break;

      case BookingStatus.accepted:
        color = Colors.blue;
        text = "Accepted";
        break;

      case BookingStatus.onTheWay:
        color = Colors.purple;
        text = "On The Way";
        break;

      case BookingStatus.inProgress:
        color = Colors.teal;
        text = "In Progress";
        break;

      case BookingStatus.completed:
        color = Colors.green;
        text = "Completed";
        break;

      case BookingStatus.cancelled:
        color = Colors.red;
        text = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}