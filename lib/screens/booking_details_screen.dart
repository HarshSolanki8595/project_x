import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  // HABIO DESIGN SYSTEM
  // ============================================================

  static const Color primaryBlue =
      Color(0xFF1557FF);

  static const Color lightBlue =
      Color(0xFFEEF3FF);

  static const Color background =
      Color(0xFFF7F8FC);

  static const Color textPrimary =
      Color(0xFF0F172A);

  static const Color textSecondary =
      Color(0xFF64748B);

  static const Color borderColor =
      Color(0xFFE1E7EF);

  static const Color danger =
      Color(0xFFD92D20);

  static const Color dangerBackground =
      Color(0xFFFDECEC);

  // ============================================================
  // STATE
  // ============================================================

  bool _isCancelling = false;

  // ============================================================
  // GETTERS
  // ============================================================

  Booking get booking => widget.booking;

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<void> _cancelBooking() async {
    if (_isCancelling) return;

    final shouldCancel =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: const Text(
            "Cancel Booking?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),

          content: const Text(
            "Are you sure you want to cancel this booking?",
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: textSecondary,
            ),
          ),

          actionsPadding:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Keep Booking",
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Cancel Booking",
                style: TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      // ========================================================
      // FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(booking.bookingId)
          .update({
        "status": "cancelled",
        "cancelledAt":
            FieldValue.serverTimestamp(),
        "cancelledBy": "customer",
      });

      if (!mounted) return;

      setState(() {
        _isCancelling = false;
      });

      // ========================================================
      // RETURN TRUE
      //
      // My Bookings already listens for this result and moves
      // the user to the Cancelled tab.
      // ========================================================

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Unable to cancel booking.\n$e",
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          "Booking Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

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
                  8,
                  20,
                  24,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // BOOKING HEADER
                    // ==================================================

                    _buildBookingHeader(),

                    // ==================================================
                    // PROFESSIONAL
                    // ==================================================

                    _sectionTitle(
                      "Professional",
                    ),

                    _buildProfessionalCard(),

                    // ==================================================
                    // SERVICE DETAILS
                    // ==================================================

                    _sectionTitle(
                      "Service Details",
                    ),

                    _buildServiceDetailsCard(),

                    // ==================================================
                    // SCHEDULE
                    // ==================================================

                    _sectionTitle(
                      "Schedule",
                    ),

                    _buildScheduleCard(),

                    // ==================================================
                    // ADDRESS
                    // ==================================================

                    _sectionTitle(
                      "Service Address",
                    ),

                    _buildAddressCard(),

                    const SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // FIXED CANCEL BUTTON
            // ========================================================

            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOOKING HEADER
  // ============================================================

  Widget _buildBookingHeader() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        16,
      ),

      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
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

                  maxLines: 3,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 27,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.7,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              _statusChip(
                booking.status,
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              Container(
                height: 38,
                width: 38,

                decoration:
                    BoxDecoration(
                  color: lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),

                child: const Icon(
                  Icons
                      .confirmation_number_outlined,
                  color: primaryBlue,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Text(
                "Booking ID",
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

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

  Widget _buildProfessionalCard() {
    return _card(
      marginBottom: 18,

      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                height: 66,
                width: 66,

                decoration:
                    BoxDecoration(
                  color: lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),

                child: const Icon(
                  Icons.person_rounded,
                  color: primaryBlue,
                  size: 36,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

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
                        fontSize: 20,
                        height: 1.15,
                        fontWeight:
                            FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color:
                              Color(0xFFFFC107),
                          size: 19,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          "${booking.professional.rating}",

                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                textPrimary,
                          ),
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Flexible(
                          child: Text(
                            "(${booking.professional.reviews} reviews)",

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 13,
                              color:
                                  textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      "${booking.professional.experience} Years Experience",

                      style:
                          const TextStyle(
                        fontSize: 14,
                        color:
                            textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          // --------------------------------------------------------
          // AGREED QUOTE
          // --------------------------------------------------------

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            decoration:
                BoxDecoration(
              color: lightBlue,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
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
                  "₹${booking.professional.quote.toStringAsFixed(0)}",

                  style:
                      const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          if (booking.professional.quoteDescription
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),

            Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                booking.professional
                    .quoteDescription,

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
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
  // SERVICE DETAILS CARD
  // ============================================================

  Widget _buildServiceDetailsCard() {
    return _card(
      marginBottom: 18,

      child: Column(
        children: [
          _detailRow(
            Icons
                .home_repair_service_rounded,
            "Category",
            booking.request.categoryName,
          ),

          const SizedBox(
            height: 12,
          ),

          _detailRow(
            Icons.handyman_rounded,
            "Service",
            booking.request
                .subCategoryName,
          ),

          if (booking.request.issueDescription
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),

            _detailRow(
              Icons.description_outlined,
              "Issue",
              booking.request
                  .issueDescription,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SCHEDULE CARD
  // ============================================================

  Widget _buildScheduleCard() {
    final date =
        booking.request.preferredDate;

    final time =
        booking.request.preferredTimeSlot;

    return _card(
      marginBottom: 18,

      child: Column(
        children: [
          if (date != null)
            _detailRow(
              Icons.calendar_month_rounded,
              "Date",
              _formatDate(date),
            ),

          if (date != null &&
              (time ?? "").isNotEmpty)
            const SizedBox(
              height: 12,
            ),

          if ((time ?? "").isNotEmpty)
            _detailRow(
              Icons.access_time_rounded,
              "Time",
              time!,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ADDRESS CARD
  // ============================================================

  Widget _buildAddressCard() {
    final address =
        booking.request.address ?? "";

    return _card(
      marginBottom: 18,

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            height: 44,
            width: 44,

            decoration:
                BoxDecoration(
              color: lightBlue,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),

            child: const Icon(
              Icons.location_on_rounded,
              color: primaryBlue,
              size: 23,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  "Service Address",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  address.isEmpty
                      ? "Address not available"
                      : address,

                  maxLines: 4,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight:
                        FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          height: 40,
          width: 40,

          decoration:
              BoxDecoration(
            color: lightBlue,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          child: Icon(
            icon,
            color: primaryBlue,
            size: 20,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style:
                    const TextStyle(
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,

                maxLines: maxLines,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight:
                      FontWeight.w600,
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
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child: Text(
        title,

        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
    double marginBottom = 18,
  }) {
    return Container(
      width: double.infinity,

      margin:
          EdgeInsets.only(
        bottom: marginBottom,
      ),

      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),

      child: child,
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
      case BookingStatus
          .awaitingAcceptance:
        background =
            const Color(0xFFFFF1D6);
        foreground =
            const Color(0xFFE89B16);
        label =
            "Awaiting Acceptance";
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
            dangerBackground;
        foreground = danger;
        label = "Cancelled";
        break;
    }

    return Flexible(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),

        decoration:
            BoxDecoration(
          color: background,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),

        child: Text(
          label,

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION
  // ============================================================

  Widget _buildBottomAction() {
    final canCancel =
        booking.status !=
            BookingStatus.cancelled &&
        booking.status !=
            BookingStatus.completed;

    if (!canCancel) {
      return const SizedBox.shrink();
    }

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        16,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, -3),
          ),
        ],
      ),

      child: SizedBox(
        width: double.infinity,
        height: 54,

        child: OutlinedButton.icon(
          onPressed:
              _isCancelling
                  ? null
                  : _cancelBooking,

          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                danger,

            side: BorderSide(
              color: danger.withValues(
                alpha: .35,
              ),
              width: 1.5,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
          ),

          icon: _isCancelling
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: danger,
                  ),
                )
              : const Icon(
                  Icons
                      .cancel_outlined,
                  size: 21,
                ),

          label: Text(
            _isCancelling
                ? "Cancelling..."
                : "Cancel Booking",

            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
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

    return "${date.day} "
        "${months[date.month - 1]} "
        "${date.year}";
  }
}