import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../models/service_request.dart';
import 'booking_confirmed_screen.dart';
import '../core/services/booking_service.dart';

class BookingSummaryScreen extends StatelessWidget {
  final ServiceRequest request;
  final Professional professional;

  const BookingSummaryScreen({
    super.key,
    required this.request,
    required this.professional,
  });

  // ============================================================
  // HABIO DESIGN SYSTEM
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          "Booking Summary",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================

                    const Text(
                      "Confirm your booking",
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Review the details before confirming your service.",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // SERVICE
                    // =================================================

                    _sectionTitle("Service"),

                    _buildCard(
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.home_repair_service_rounded,
                            "Category",
                            request.categoryName,
                          ),

                          const SizedBox(height: 10),

                          _infoRow(
                            Icons.handyman_rounded,
                            "Service",
                            request.subCategoryName,
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // ISSUE
                    // =================================================

                    _sectionTitle("Issue"),

                    _buildCard(
                      child: Text(
                        request.issueDescription.isEmpty
                            ? "No description provided."
                            : request.issueDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: textPrimary,
                        ),
                      ),
                    ),

                    // =================================================
                    // PROFESSIONAL
                    // =================================================

                    _sectionTitle("Professional"),

                    _buildCard(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: lightBlue,
                                  borderRadius:
                                      BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: primaryBlue,
                                  size: 29,
                                ),
                              ),

                              const SizedBox(width: 11),

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
                                      style:
                                          const TextStyle(
                                        fontSize: 17,
                                        height: 1.15,
                                        fontWeight:
                                            FontWeight.w700,
                                        color:
                                            textPrimary,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color:
                                              Color(0xFFF59E0B),
                                          size: 17,
                                        ),

                                        const SizedBox(
                                          width: 4,
                                        ),

                                        Text(
                                          "${professional.rating}",
                                          style:
                                              const TextStyle(
                                            fontSize: 13,
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
                                            "${professional.reviews} reviews",
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  textSecondary,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 11),

                          // QUOTE

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        "Agreed quote",
                                        style: TextStyle(
                                          color:
                                              textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),

                                      SizedBox(height: 2),

                                      Text(
                                        "Professional's quote",
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color:
                                              textPrimary,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  "₹${professional.quote.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (professional
                              .quoteDescription
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(height: 8),

                            Align(
                              alignment:
                                  Alignment.centerLeft,
                              child: Text(
                                professional
                                    .quoteDescription,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // =================================================
                    // ADDRESS
                    // =================================================

                    _sectionTitle("Service Address"),

                    _buildCard(
                      child: _infoRow(
                        Icons.location_on_rounded,
                        "Address",
                        request.address ?? "",
                        maxLines: 3,
                      ),
                    ),

                    // =================================================
                    // SCHEDULE
                    // =================================================

                    _sectionTitle("Schedule"),

                    _buildCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _infoRow(
                              Icons.calendar_month_rounded,
                              "Date",
                              request.preferredDate ==
                                      null
                                  ? ""
                                  : "${request.preferredDate!.day}/${request.preferredDate!.month}/${request.preferredDate!.year}",
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _infoRow(
                              Icons.access_time_rounded,
                              "Time",
                              request
                                      .preferredTimeSlot ??
                                  "",
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // INFORMATION
                    // =================================================

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF9F2),
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              const Color(0xFFD5EEDC),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF35A853),
                            size: 19,
                          ),

                          SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              "You will only be charged according to the booking terms after confirming the service.",
                              style: TextStyle(
                                color:
                                    Color(0xFF356344),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // =========================================================
            // BOTTOM CTA
            // =========================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                9,
                20,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: .05,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                  ),

                  onPressed: () async {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(
                          child:
                              CircularProgressIndicator(
                            color: primaryBlue,
                          ),
                        ),
                      );

                      final bookingId =
                          await BookingService
                              .createBooking(
                        request: request,
                        professional:
                            professional,
                      );

                      if (!context.mounted) return;

                      Navigator.pop(context);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingConfirmedScreen(
                            bookingId: bookingId,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Booking failed.\n$e",
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Confirm Booking",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
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
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 21,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 11.5,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value.isEmpty
                    ? "Not provided"
                    : value,
                maxLines: maxLines,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  height: 1.3,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}