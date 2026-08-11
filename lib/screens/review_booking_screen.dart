import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/service_request.dart';
import 'finding_professionals_screen.dart';

class ReviewBookingScreen extends StatelessWidget {
  final ServiceRequest request;

  const ReviewBookingScreen({
    super.key,
    required this.request,
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
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
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

  Widget _card({
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.all(15),
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      padding: padding,
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
  // DATE
  // ============================================================

  String get formattedDate {
    if (request.preferredDate == null) {
      return "Not Selected";
    }

    return DateFormat(
      "dd MMM yyyy",
    ).format(
      request.preferredDate!,
    );
  }

  // ============================================================
  // SMALL ICON
  // ============================================================

  Widget _iconBox(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: primaryBlue,
        size: 21,
      ),
    );
  }

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
          "Review Booking",
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
                      "Review your request",
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
                      "Make sure everything looks right before sending your request.",
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

                    _card(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _iconBox(
                            Icons.build_circle_outlined,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.categoryName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  request.subCategoryName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color:
                                        textSecondary,
                                  ),
                                ),

                                if (request.isEmergency)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFFFDECEC,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          20,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons
                                                .warning_amber_rounded,
                                            color:
                                                Color(
                                              0xFFD92D20,
                                            ),
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "Emergency",
                                            style:
                                                TextStyle(
                                              color:
                                                  Color(
                                                0xFFD92D20,
                                              ),
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // ISSUE
                    // =================================================

                    _sectionTitle(
                      "Issue Description",
                    ),

                    _card(
                      child: Text(
                        request.issueDescription
                                .trim()
                                .isEmpty
                            ? "No description provided."
                            : request.issueDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: textPrimary,
                        ),
                      ),
                    ),

                    // =================================================
                    // PHOTOS
                    // =================================================

                    _sectionTitle("Photos"),

                    _card(
                      child: request.photos.isEmpty
                          ? const Row(
                              children: [
                                Icon(
                                  Icons
                                      .photo_library_outlined,
                                  color:
                                      textSecondary,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "No photos attached.",
                                  style:
                                      TextStyle(
                                    color:
                                        textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 72,
                              child: ListView.builder(
                                scrollDirection:
                                    Axis.horizontal,
                                itemCount:
                                    request.photos.length,
                                itemBuilder:
                                    (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      right: 9,
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                      child: Image.file(
                                        request
                                            .photos[index],
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),

                    // =================================================
                    // ADDRESS
                    // =================================================

                    _sectionTitle(
                      "Service Address",
                    ),

                    _card(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _iconBox(
                            Icons.location_on_rounded,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              request.address ==
                                          null ||
                                      request.address!
                                          .trim()
                                          .isEmpty
                                  ? "No address selected"
                                  : request.address!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // SCHEDULE
                    // =================================================

                    _sectionTitle(
                      "Preferred Schedule",
                    ),

                    _card(
                      child: Row(
                        children: [
                          _iconBox(
                            Icons.calendar_month_rounded,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style:
                                      const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  request.preferredTimeSlot ??
                                      "Not Selected",
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                    color:
                                        textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // WHAT HAPPENS NEXT
                    // =================================================

                    _sectionTitle(
                      "What Happens Next",
                    ),

                    _card(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _nextStep(
                            "Your request will be sent to nearby verified professionals.",
                          ),
                          _nextStep(
                            "Professionals will review your request and send quotations.",
                          ),
                          _nextStep(
                            "Compare prices, ratings and reviews before choosing one.",
                          ),
                          _nextStep(
                            "No payment is required until you accept a quotation.",
                          ),
                        ],
                      ),
                    ),
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
                10,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FindingProfessionalsScreen(
                          request: request,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    "Request Quotes",
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
  // NEXT STEP ROW
  // ============================================================

  Widget _nextStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF35A853),
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}