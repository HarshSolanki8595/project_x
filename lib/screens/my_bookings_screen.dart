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

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7FF),

        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF7FF),
          elevation: 0,
          scrolledUnderElevation: 0,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text(
            'My Bookings',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
            ),
          ),

          centerTitle: true,

          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(62),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    text: 'Upcoming',
                  ),
                  Tab(
                    text: 'Completed',
                  ),
                  Tab(
                    text: 'Cancelled',
                  ),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _BookingsTab(
              type: _BookingTabType.upcoming,
              onUpdated: _refresh,
            ),

            _BookingsTab(
              type: _BookingTabType.completed,
              onUpdated: _refresh,
            ),

            _BookingsTab(
              type: _BookingTabType.cancelled,
              onUpdated: _refresh,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// BOOKING TAB TYPE
// ======================================================================

enum _BookingTabType {
  upcoming,
  completed,
  cancelled,
}

// ======================================================================
// BOOKINGS TAB
// ======================================================================

class _BookingsTab extends StatelessWidget {
  final _BookingTabType type;
  final Future<void> Function() onUpdated;

  const _BookingsTab({
    required this.type,
    required this.onUpdated,
  });

  List<Booking> _getBookings() {
    switch (type) {
      case _BookingTabType.upcoming:
        return dummyBookings.where((booking) {
          return booking.status != BookingStatus.completed &&
              booking.status != BookingStatus.cancelled;
        }).toList();

      case _BookingTabType.completed:
        return dummyBookings.where((booking) {
          return booking.status == BookingStatus.completed;
        }).toList();

      case _BookingTabType.cancelled:
        return dummyBookings.where((booking) {
          return booking.status == BookingStatus.cancelled;
        }).toList();
    }
  }

  String get emptyTitle {
    switch (type) {
      case _BookingTabType.upcoming:
        return 'No Upcoming Bookings';

      case _BookingTabType.completed:
        return 'No Completed Bookings';

      case _BookingTabType.cancelled:
        return 'No Cancelled Bookings';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _getBookings();

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: onUpdated,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.62,
              child: _EmptyBookings(
                title: emptyTitle,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onUpdated,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          120,
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: _BookingCard(
              booking: bookings[index],
              onUpdated: onUpdated,
            ),
          );
        },
      ),
    );
  }
}

// ======================================================================
// BOOKING CARD
// ======================================================================

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final Future<void> Function() onUpdated;

  const _BookingCard({
    required this.booking,
    required this.onUpdated,
  });

  Color _statusColor(BuildContext context) {
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

  String get _statusText {
    switch (booking.status) {
      case BookingStatus.awaitingAcceptance:
        return 'Awaiting Acceptance';

      case BookingStatus.accepted:
        return 'Accepted';

      case BookingStatus.onTheWay:
        return 'On The Way';

      case BookingStatus.inProgress:
        return 'In Progress';

      case BookingStatus.completed:
        return 'Completed';

      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get _serviceIcon {
    return Icons.home_repair_service_rounded;
  }

  String get _dateText {
    final date = booking.request.preferredDate;

    if (date == null) {
      return 'Date not selected';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9FF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          22,
          22,
          22,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------
            // SERVICE HEADER
            // ----------------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _serviceIcon,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.request.subCategoryName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        booking.professional.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6C6670),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------------
            // STATUS
            // ----------------------------------------------------------

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  'ID: ${booking.bookingId}',
                  style: const TextStyle(
                    color: Color(0xFF8A858C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(
              height: 1,
              color: Color(0xFFEAE5EA),
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------------
            // DATE
            // ----------------------------------------------------------

            _BookingInfoRow(
              icon: Icons.calendar_today_rounded,
              title: 'Date',
              value: _dateText,
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------------
            // ADDRESS
            // ----------------------------------------------------------

            _BookingInfoRow(
              icon: Icons.location_on_rounded,
              title: 'Address',
              value: booking.request.address ??
                  'No address provided',
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------------
            // PRICE
            // ----------------------------------------------------------

            _BookingInfoRow(
              icon: Icons.currency_rupee_rounded,
              title: 'Quoted Price',
              value:
                  '₹${booking.professional.quote.toStringAsFixed(0)}',
              valueBold: true,
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------------
            // VIEW DETAILS
            // ----------------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 54,
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
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// BOOKING INFO ROW
// ======================================================================

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool valueBold;

  const _BookingInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF777178),
            fontWeight: FontWeight.w500,
          ),
        ),

        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF302B31),
              fontWeight:
                  valueBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// EMPTY BOOKINGS
// ======================================================================

class _EmptyBookings extends StatelessWidget {
  final String title;

  const _EmptyBookings({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: primaryColor.withValues(
              alpha: 0.08,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.event_busy_rounded,
            size: 56,
            color: primaryColor,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Your bookings will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}