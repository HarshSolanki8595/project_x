import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  // ============================================================
  // HABIO BLUE
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);

  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            "Please login first.",
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
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
          "My Bookings",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,

          isScrollable: true,

          tabAlignment: TabAlignment.start,

          labelColor: primaryBlue,

          unselectedLabelColor: textSecondary,

          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),

          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),

          indicatorColor: primaryBlue,

          indicatorWeight: 3,

          indicatorSize: TabBarIndicatorSize.label,

          dividerColor: const Color(0xFFD9DDE5),

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
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Unable to load your bookings.\n\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          // ----------------------------------------------------
          // UPCOMING
          // ----------------------------------------------------

          final upcomingBookings = bookings.where((booking) {
            return booking.status ==
                    BookingStatus.awaitingAcceptance ||
                booking.status == BookingStatus.accepted;
          }).toList();

          // ----------------------------------------------------
          // ONGOING
          // ----------------------------------------------------

          final ongoingBookings = bookings.where((booking) {
            return booking.status == BookingStatus.onTheWay ||
                booking.status == BookingStatus.inProgress;
          }).toList();

          // ----------------------------------------------------
          // COMPLETED
          // ----------------------------------------------------

          final completedBookings = bookings.where((booking) {
            return booking.status == BookingStatus.completed;
          }).toList();

          // ----------------------------------------------------
          // CANCELLED
          // ----------------------------------------------------

          final cancelledBookings = bookings.where((booking) {
            return booking.status == BookingStatus.cancelled;
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
  }

  // ============================================================
  // BOOKING LIST
  // ============================================================

  Widget _buildBookings(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        30,
      ),

      itemCount: bookings.length,

      itemBuilder: (context, index) {
        final booking = bookings[index];

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: _bookingCard(
            context,
            booking,
          ),
        );
      },
    );
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _bookingCard(
    BuildContext context,
    Booking booking,
  ) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(24),

      child: InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(
                booking: booking,
              ),
            ),
          );

          // ----------------------------------------------------
          // If the booking was cancelled, automatically move
          // the user to the Cancelled tab.
          // ----------------------------------------------------

          if (result == true && mounted) {
            _tabController.animateTo(3);
          }
        },

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: const Color(0xFFE2E6ED),
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.045,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =================================================
              // SERVICE + STATUS
              // =================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Text(
                      booking.request.subCategoryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Flexible(
                    child: _statusChip(
                      booking.status,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =================================================
              // PROFESSIONAL + PRICE
              // =================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Container(
                    height: 64,
                    width: 64,

                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.person_rounded,
                      color: primaryBlue,
                      size: 34,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          booking.professional.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC107),
                              size: 20,
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                "${booking.professional.rating} • "
                                "${booking.professional.experience} Years Experience",

                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 15,
                                  color:
                                      textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ------------------------------------------------
                  // PRICE
                  // ------------------------------------------------

                  Text(
                    "₹${booking.professional.quote.toStringAsFixed(0)}",

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Divider(
                height: 1,
                color: Color(0xFFE4E7EC),
              ),

              const SizedBox(height: 17),

              // =================================================
              // DATE
              // =================================================

              if (booking.request.preferredDate != null)
                _infoLine(
                  Icons.calendar_today_rounded,
                  _formatDate(
                    booking.request.preferredDate!,
                  ),
                ),

              const SizedBox(height: 13),

              // =================================================
              // TIME
              // =================================================

              if ((booking.request.preferredTimeSlot ??
                      "")
                  .isNotEmpty)
                _infoLine(
                  Icons.access_time_rounded,
                  booking.request.preferredTimeSlot!,
                ),

              // =================================================
              // ADDRESS
              // =================================================

              if ((booking.request.address ?? "")
                  .isNotEmpty) ...[
                const SizedBox(height: 13),

                _infoLine(
                  Icons.location_on_rounded,
                  booking.request.address!,
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 20),

              // =================================================
              // VIEW DETAILS
              // =================================================

              Align(
                alignment: Alignment.centerRight,

                child: TextButton.icon(
                  onPressed: () async {
                    final result =
                        await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(
                          booking: booking,
                        ),
                      ),
                    );

                    if (result == true &&
                        mounted) {
                      _tabController.animateTo(3);
                    }
                  },

                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: primaryBlue,
                    size: 25,
                  ),

                  label: const Text(
                    "View Details",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO LINE
  // ============================================================

  Widget _infoLine(
    IconData icon,
    String text, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          color: const Color(0xFF98A2B3),
          size: 22,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            text,

            maxLines: maxLines,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 16,
              color: textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(BookingStatus status) {
    Color background;
    Color foreground;
    String label;

    switch (status) {
      case BookingStatus.awaitingAcceptance:
        background = const Color(0xFFFFF1D6);
        foreground = const Color(0xFFE89B16);
        label = "Awaiting Acceptance";
        break;

      case BookingStatus.accepted:
        background = lightBlue;
        foreground = primaryBlue;
        label = "Accepted";
        break;

      case BookingStatus.onTheWay:
        background = lightBlue;
        foreground = primaryBlue;
        label = "On The Way";
        break;

      case BookingStatus.inProgress:
        background = const Color(0xFFE8F7EE);
        foreground = const Color(0xFF35A853);
        label = "In Progress";
        break;

      case BookingStatus.completed:
        background = const Color(0xFFE8F7EE);
        foreground = const Color(0xFF35A853);
        label = "Completed";
        break;

      case BookingStatus.cancelled:
        background = const Color(0xFFFDECEC);
        foreground = const Color(0xFFD92D20);
        label = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),

      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,

        style: TextStyle(
          color: foreground,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              height: 82,
              width: 82,

              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.receipt_long_rounded,
                color: primaryBlue,
                size: 40,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "No bookings found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Your bookings will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}