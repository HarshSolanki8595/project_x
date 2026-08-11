import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../models/service_request.dart';
import 'booking_summary_screen.dart';

class ProfessionalsScreen extends StatelessWidget {
  final ServiceRequest request;

  const ProfessionalsScreen({
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
          "Professionals & Quotes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          24,
        ),
        children: [
          // =========================================================
          // HEADER
          // =========================================================

          const Text(
            "Choose the right professional",
            style: TextStyle(
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "Compare verified professionals, their experience and their quotes before deciding.",
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 15),

          // =========================================================
          // MARKETPLACE MESSAGE
          // =========================================================

          _marketplaceMessage(),

          const SizedBox(height: 14),

          // =========================================================
          // PROFESSIONALS
          // =========================================================

          ...dummyProfessionals.map(
            (professional) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _professionalCard(
                context,
                professional,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MARKETPLACE MESSAGE
  // ============================================================

  Widget _marketplaceMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD7E2FF),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            color: primaryBlue,
            size: 24,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              "Professionals decide their price. You decide which offer gives you the best value.",
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFESSIONAL CARD
  // ============================================================

  Widget _professionalCard(
    BuildContext context,
    Professional professional,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .025,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =====================================================
            // PROFESSIONAL HEADER
            // =====================================================

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
                        BorderRadius.circular(15),
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
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.15,
                          fontWeight:
                              FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),

                      if (professional.verified) ...[
                        const SizedBox(height: 6),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE8F7EE),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color:
                                    Color(0xFF35A853),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Verified Professional",
                                style: TextStyle(
                                  color:
                                      Color(0xFF35A853),
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================================
            // STATS
            // =====================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _infoItem(
                    Icons.star_rounded,
                    const Color(0xFFF59E0B),
                    "${professional.rating}",
                  ),

                  _divider(),

                  _infoItem(
                    Icons.reviews_outlined,
                    const Color(0xFF64748B),
                    "${professional.reviews} reviews",
                  ),

                  _divider(),

                  _infoItem(
                    Icons.work_outline_rounded,
                    primaryBlue,
                    "${professional.experience} yrs",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 11),

            // =====================================================
            // DETAILS
            // =====================================================

            _detailRow(
              Icons.build_circle_outlined,
              "${professional.jobsCompleted} jobs completed",
            ),

            const SizedBox(height: 7),

            _detailRow(
              Icons.location_on_outlined,
              "${professional.distance} km away",
            ),

            const SizedBox(height: 7),

            _detailRow(
              Icons.access_time_rounded,
              "Can arrive in ${professional.arrivalTime}",
            ),

            const SizedBox(height: 12),

            // =====================================================
            // QUOTE
            // =====================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                13,
                11,
                13,
                11,
              ),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Their quote",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 2),

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

                  const Icon(
                    Icons.request_quote_outlined,
                    color: primaryBlue,
                    size: 27,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // =====================================================
            // QUOTE DESCRIPTION
            // =====================================================

            Text(
              professional.quoteDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 12),

            // =====================================================
            // ACTIONS
            // =====================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showProfessionalProfile(
                        context,
                        professional,
                      );
                    },
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          primaryBlue,
                      side: const BorderSide(
                        color: Color(0xFFD7E0F2),
                      ),
                      minimumSize:
                          const Size.fromHeight(48),
                      padding:
                          EdgeInsets.zero,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                    child: const Text(
                      "View Profile",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingSummaryScreen(
                            request: request,
                            professional:
                                professional,
                          ),
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryBlue,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      minimumSize:
                          const Size.fromHeight(48),
                      padding:
                          EdgeInsets.zero,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Choose",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _infoItem(
    IconData icon,
    Color color,
    String text,
  ) {
    return Expanded(
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),

          const SizedBox(width: 4),

          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
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

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Container(
      height: 20,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: textSecondary,
          size: 17,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFESSIONAL PROFILE BOTTOM SHEET
  // ============================================================

  void _showProfessionalProfile(
    BuildContext context,
    Professional professional,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle

                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                // Avatar

                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius:
                        BorderRadius.circular(21),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primaryBlue,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  professional.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w700,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                if (professional.verified)
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF35A853),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Verified Professional",
                        style: TextStyle(
                          color:
                              Color(0xFF35A853),
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 13),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color:
                            Color(0xFFF59E0B),
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${professional.rating}",
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${professional.reviews} reviews",
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 1,
                        color:
                            const Color(
                          0xFFD1D5DB,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${professional.experience} yrs",
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 13),

                // Quote

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius:
                        BorderRadius.circular(16),
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
                              "Their quote",
                              style: TextStyle(
                                color:
                                    textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Service quotation",
                              style: TextStyle(
                                color:
                                    textPrimary,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${professional.quote.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 23,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // About

                if (professional
                    .quoteDescription
                    .isNotEmpty)
                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      professional
                          .quoteDescription,
                      style:
                          const TextStyle(
                        color:
                            textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingSummaryScreen(
                            request: request,
                            professional:
                                professional,
                          ),
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryBlue,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Choose Professional",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}