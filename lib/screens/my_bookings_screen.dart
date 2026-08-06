import 'package:flutter/material.dart';

import '../data/dummy_bookings.dart';
import '../models/booking.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({
    super.key,
  });

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState
    extends State<MyBookingsScreen> {

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,

      child: Scaffold(
        backgroundColor:
            const Color(0xffF7F8FC),

        appBar: AppBar(
          title: const Text(
            "My Bookings",
          ),

          centerTitle: true,

          bottom: const TabBar(
            tabs: [

              Tab(
                text: "Upcoming",
              ),

              Tab(
                text: "Completed",
              ),

              Tab(
                text: "Cancelled",
              ),

            ],
          ),
        ),

        body: TabBarView(
          children: [

            _BookingsTab(
              status:
                  BookingStatus.awaitingAcceptance,
              onUpdated: _refresh,
            ),

            _BookingsTab(
              status:
                  BookingStatus.completed,
              onUpdated: _refresh,
            ),

            _BookingsTab(
              status:
                  BookingStatus.cancelled,
              onUpdated: _refresh,
            ),

          ],
        ),
      ),
    );
  }
}class _BookingsTab extends StatefulWidget {
  final BookingStatus status;
  final Future<void> Function() onUpdated;

  const _BookingsTab({
    required this.status,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {

    final bookings = dummyBookings
        .where((booking) => booking.status == status)
        .toList();

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: onUpdated,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [

            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.60,

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.event_busy,
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    status ==
                            BookingStatus.completed
                        ? "No Completed Bookings"
                        : status ==
                                BookingStatus.cancelled
                            ? "No Cancelled Bookings"
                            : "No Upcoming Bookings",

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Your bookings will appear here.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      );
    }

    return RefreshIndicator(

      onRefresh: onUpdated,

      child: ListView.builder(

        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(16),

        itemCount: bookings.length,

        itemBuilder: (context, index) {

          return _BookingCard(

            booking: bookings[index],

            onUpdated: onUpdated,

          );

        },
      ),
    );
  }
}class _BookingCard extends StatelessWidget {
  final Booking booking;
  final Future<void> Function() onUpdated;

  const _BookingCard({
    required this.booking,
    required this.onUpdated,
  });

  Color get statusColor {
    switch (booking.status) {
      case BookingStatus.awaitingAcceptance:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.onTheWay:
        return Colors.indigo;
      case BookingStatus.inProgress:
        return Colors.deepPurple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String get statusText {
    switch (booking.status) {
      case BookingStatus.awaitingAcceptance:
        return "Awaiting Acceptance";
      case BookingStatus.accepted:
        return "Accepted";
      case BookingStatus.onTheWay:
        return "On The Way";
      case BookingStatus.inProgress:
        return "In Progress";
      case BookingStatus.completed:
        return "Completed";
      case BookingStatus.cancelled:
        return "Cancelled";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    booking.professional.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 14),

            Text(
              booking.request.subCategoryName,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Booking ID: ${booking.bookingId}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              booking.request.address ?? "No Address",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                const Icon(
                  Icons.calendar_today,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  "${booking.request.preferredDate?.day ?? "-"}"
                  "/${booking.request.preferredDate?.month ?? "-"}"
                  "/${booking.request.preferredDate?.year ?? "-"}",
                ),

              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [

                const Icon(
                  Icons.currency_rupee,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  booking.professional.quote
                      .toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  final updated =
                      await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingDetailsScreen(
                        booking: booking,
                      ),
                    ),
                  );

                  if (updated == true) {
                    await onUpdated();
                  }
                },
                child: const Text(
                  "View Details",
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}