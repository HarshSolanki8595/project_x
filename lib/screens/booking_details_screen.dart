import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/booking.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState
    extends State<BookingDetailsScreen> {
  // ============================================================
  // HABIO BLUE
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);

  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);

  bool _cancelling = false;

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<void> _cancelBooking() async {
    String selectedReason = "No longer needed";

    final otherController = TextEditingController();

    final result = await showDialog<String>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final reasons = [
              "Found another professional",
              "No longer needed",
              "Price is high",
              "Other",
            ];

            return AlertDialog(
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24),
              ),

              title: const Text(
                "Cancel Booking",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Why do you want to cancel this booking?",
                      style: TextStyle(
                        fontSize: 15,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...reasons.map(
                      (reason) {
                        return RadioListTile<String>(
                          value: reason,
                          groupValue: selectedReason,

                          activeColor: primaryBlue,

                          contentPadding:
                              EdgeInsets.zero,

                          title: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 15,
                              color: textPrimary,
                            ),
                          ),

                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setDialogState(() {
                              selectedReason =
                                  value;
                            });
                          },
                        );
                      },
                    ),

                    if (selectedReason == "Other")
                      TextField(
                        controller:
                            otherController,

                        maxLines: 3,

                        cursorColor: primaryBlue,

                        decoration:
                            InputDecoration(
                          hintText:
                              "Tell us more...",
                          filled: true,
                          fillColor:
                              const Color(
                            0xFFF7F8FC,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFE1E5EC,
                              ),
                            ),
                          ),

                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              actionsPadding:
                  const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20,
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: const Text(
                    "Keep Booking",
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFD92D20,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  onPressed: () {
                    final reason =
                        selectedReason ==
                                "Other"
                            ? otherController
                                .text
                                .trim()
                            : selectedReason;

                    Navigator.pop(
                      dialogContext,
                      reason.isEmpty
                          ? "Other"
                          : reason,
                    );
                  },

                  child: const Text(
                    "Cancel Booking",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    otherController.dispose();

    if (result == null) {
      return;
    }

    await _performCancellation(result);
  }

  // ============================================================
  // FIRESTORE CANCELLATION
  // ============================================================

  Future<void> _performCancellation(
    String reason,
  ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      _cancelling = true;
    });

    try {
      final bookingsRef =
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("bookings");

      // --------------------------------------------------------
      // First try bookingId as the Firestore document ID.
      // --------------------------------------------------------

      final directDoc =
          bookingsRef.doc(
        widget.booking.bookingId,
      );

      final directSnapshot =
          await directDoc.get();

      if (directSnapshot.exists) {
        await directDoc.update({
          "status": "cancelled",
          "cancellationReason": reason,
          "cancelledAt":
              FieldValue.serverTimestamp(),
        });
      } else {
        // ------------------------------------------------------
        // Fallback: locate the booking using bookingId field.
        // This protects us if the document ID and booking ID
        // are different.
        // ------------------------------------------------------

        final query =
            await bookingsRef
                .where(
                  "bookingId",
                  isEqualTo:
                      widget.booking.bookingId,
                )
                .limit(1)
                .get();

        if (query.docs.isEmpty) {
          throw Exception(
            "Booking could not be found.",
          );
        }

        await query.docs.first.reference
            .update({
          "status": "cancelled",
          "cancellationReason":
              reason,
          "cancelledAt":
              FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Booking cancelled successfully.",
          ),
          backgroundColor:
              Color(0xFF35A853),
        ),
      );

      // --------------------------------------------------------
      // Return TRUE to BookingsScreen.
      // It will automatically switch to Cancelled.
      // --------------------------------------------------------

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not cancel booking.\n$e",
          ),
          backgroundColor:
              const Color(0xFFD92D20),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    final canCancel =
        booking.status ==
                BookingStatus.awaitingAcceptance ||
            booking.status ==
                BookingStatus.accepted ||
            booking.status ==
                BookingStatus.onTheWay ||
            booking.status ==
                BookingStatus.inProgress;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          "Booking Details",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  30,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // BOOKING HEADER
                    // =================================================

                    _buildHeaderCard(
                      booking,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // PROFESSIONAL
                    // =================================================

                    _sectionTitle(
                      "Professional",
                    ),

                    const SizedBox(height: 10),

                    _buildProfessionalCard(
                      booking,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // SERVICE
                    // =================================================

                    _sectionTitle(
                      "Service Details",
                    ),

                    const SizedBox(height: 10),

                    _buildServiceCard(
                      booking,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // ADDRESS
                    // =================================================

                    _sectionTitle(
                      "Service Address",
                    ),

                    const SizedBox(height: 10),

                    _buildInfoCard(
                      icon:
                          Icons.location_on_rounded,
                      title: "Address",
                      value:
                          booking.request.address ??
                              "Address not available",
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // SCHEDULE
                    // =================================================

                    _sectionTitle(
                      "Schedule",
                    ),

                    const SizedBox(height: 10),

                    _buildScheduleCard(
                      booking,
                    ),

                    // =================================================
                    // ISSUE
                    // =================================================

                    if (booking.request
                            .issueDescription
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 24),

                      _sectionTitle(
                        "Issue Description",
                      ),

                      const SizedBox(height: 10),

                      _buildInfoCard(
                        icon: Icons
                            .description_outlined,
                        title: "What you described",
                        value: booking
                            .request
                            .issueDescription,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // =================================================
                    // STATUS
                    // =================================================

                    _sectionTitle(
                      "Booking Status",
                    ),

                    const SizedBox(height: 10),

                    _buildStatusTimeline(
                      booking.status,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ========================================================
            // BOTTOM ACTION
            // ========================================================

            if (canCancel)
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 14,
                      offset:
                          const Offset(0, -4),
                    ),
                  ],
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: OutlinedButton.icon(
                    onPressed:
                        _cancelling
                            ? null
                            : _cancelBooking,

                    icon: _cancelling
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Color(
                                0xFFD92D20,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons
                                .cancel_outlined,
                            color:
                                Color(
                              0xFFD92D20,
                            ),
                          ),

                    label: Text(
                      _cancelling
                          ? "Cancelling..."
                          : "Cancel Booking",

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFFD92D20,
                        ),
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      side:
                          const BorderSide(
                        color:
                            Color(
                          0xFFF1A7A2,
                        ),
                        width: 1.5,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard(
    Booking booking,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: const Color(0xFFE2E6ED),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  booking.request
                      .subCategoryName,

                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              _statusChip(
                booking.status,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: primaryBlue,
                size: 21,
              ),

              const SizedBox(width: 9),

              const Text(
                "Booking ID",
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  booking.bookingId,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFESSIONAL CARD
  // ============================================================

  Widget _buildProfessionalCard(
    Booking booking,
  ) {
    final professional =
        booking.professional;

    return _card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                height: 68,
                width: 68,

                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    19,
                  ),
                ),

                child: const Icon(
                  Icons.person_rounded,
                  color: primaryBlue,
                  size: 37,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      professional.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color:
                              Color(
                            0xFFFFC107,
                          ),
                          size: 20,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          "${professional.rating}",
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                textPrimary,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            "(${professional.reviews} reviews)",
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 14,
                              color:
                                  textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${professional.experience} Years Experience",

                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),

            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius:
                  BorderRadius.circular(17),
            ),

            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Agreed quote",
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ),

                Text(
                  "₹${professional.quote.toStringAsFixed(0)}",

                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          if (professional.quoteDescription
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 14),

            Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                professional.quoteDescription,

                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _buildServiceCard(
    Booking booking,
  ) {
    return _card(
      child: Column(
        children: [
          _detailRow(
            Icons.category_outlined,
            "Category",
            booking.request.categoryName,
          ),

          const Divider(height: 26),

          _detailRow(
            Icons.handyman_outlined,
            "Service",
            booking.request.subCategoryName,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEDULE CARD
  // ============================================================

  Widget _buildScheduleCard(
    Booking booking,
  ) {
    final date =
        booking.request.preferredDate;

    final time =
        booking.request.preferredTimeSlot;

    return _card(
      child: Column(
        children: [
          if (date != null)
            _detailRow(
              Icons.calendar_month_rounded,
              "Date",
              _formatDate(date),
            ),

          if (date != null &&
              time != null &&
              time.isNotEmpty)
            const Divider(height: 26),

          if (time != null &&
              time.isNotEmpty)
            _detailRow(
              Icons.access_time_rounded,
              "Preferred Time",
              time,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return _card(
      child: _detailRow(
        icon,
        title,
        value,
      ),
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFE2E6ED),
        ),
      ),

      child: child,
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          height: 46,
          width: 46,

          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color: primaryBlue,
            size: 24,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight:
                      FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS TIMELINE
  // ============================================================

  Widget _buildStatusTimeline(
    BookingStatus status,
  ) {
    if (status == BookingStatus.cancelled) {
      return _card(
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,

              decoration: BoxDecoration(
                color: const Color(
                  0xFFFDECEC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: const Icon(
                Icons.cancel_rounded,
                color:
                    Color(0xFFD92D20),
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Text(
                "This booking has been cancelled.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      (
        "Booking Requested",
        BookingStatus.awaitingAcceptance,
      ),
      (
        "Professional Accepted",
        BookingStatus.accepted,
      ),
      (
        "Professional On The Way",
        BookingStatus.onTheWay,
      ),
      (
        "Service In Progress",
        BookingStatus.inProgress,
      ),
      (
        "Service Completed",
        BookingStatus.completed,
      ),
    ];

    int currentIndex = 0;

    switch (status) {
      case BookingStatus.awaitingAcceptance:
        currentIndex = 0;
        break;

      case BookingStatus.accepted:
        currentIndex = 1;
        break;

      case BookingStatus.onTheWay:
        currentIndex = 2;
        break;

      case BookingStatus.inProgress:
        currentIndex = 3;
        break;

      case BookingStatus.completed:
        currentIndex = 4;
        break;

      case BookingStatus.cancelled:
        currentIndex = 0;
        break;
    }

    return _card(
      child: Column(
        children: [
          for (int i = 0;
              i < steps.length;
              i++)
            _timelineItem(
              title: steps[i].$1,
              completed:
                  i <= currentIndex,
              isLast:
                  i == steps.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required bool completed,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Column(
          children: [
            Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: completed
                  ? const Color(0xFF35A853)
                  : const Color(0xFF98A2B3),
              size: 23,
            ),

            if (!isLast)
              Container(
                height: 32,
                width: 2,
                color: completed
                    ? const Color(
                        0xFFB7E2C3,
                      )
                    : const Color(
                        0xFFE4E7EC,
                      ),
              ),
          ],
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 2,
            ),

            child: Text(
              title,

              style: TextStyle(
                fontSize: 15,
                fontWeight: completed
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: completed
                    ? textPrimary
                    : textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
    BookingStatus status,
  ) {
    Color background;
    Color foreground;
    String label;

    switch (status) {
      case BookingStatus.awaitingAcceptance:
        background =
            const Color(0xFFFFF1D6);
        foreground =
            const Color(0xFFE89B16);
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
        background =
            const Color(0xFFE8F7EE);
        foreground =
            const Color(0xFF35A853);
        label = "In Progress";
        break;

      case BookingStatus.completed:
        background =
            const Color(0xFFE8F7EE);
        foreground =
            const Color(0xFF35A853);
        label = "Completed";
        break;

      case BookingStatus.cancelled:
        background =
            const Color(0xFFFDECEC);
        foreground =
            const Color(0xFFD92D20);
        label = "Cancelled";
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),

      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        label,

        maxLines: 1,

        overflow:
            TextOverflow.ellipsis,

        style: TextStyle(
          color: foreground,
          fontSize: 12.5,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // DATE
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    );
  }
}