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

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color backgroundColor = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          const Text(
            "Choose the right professional",
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            "Compare verified professionals, their experience and their quotes before deciding.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          _buildMarketplaceMessage(),
          const SizedBox(height: 22),
          ...dummyProfessionals.map(
            (professional) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProfessionalCard(
                context,
                professional,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceMessage() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
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
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Professionals decide their price. You decide which offer gives you the best value.",
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(
    BuildContext context,
    Professional professional,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primaryBlue,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 7),
                      if (professional.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EF),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.green,
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Verified Professional",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _infoItem(
                    Icons.star_rounded,
                    Colors.amber.shade700,
                    "${professional.rating}",
                  ),
                  _verticalDivider(),
                  _infoItem(
                    Icons.reviews_outlined,
                    Colors.blueGrey,
                    "${professional.reviews} reviews",
                  ),
                  _verticalDivider(),
                  _infoItem(
                    Icons.work_outline_rounded,
                    primaryBlue,
                    "${professional.experience} yrs",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _detailRow(
              Icons.build_circle_outlined,
              "${professional.jobsCompleted} jobs completed",
            ),
            const SizedBox(height: 9),
            _detailRow(
              Icons.location_on_outlined,
              "${professional.distance} km away",
            ),
            const SizedBox(height: 9),
            _detailRow(
              Icons.access_time_rounded,
              "Can arrive in ${professional.arrivalTime}",
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.fromLTRB(
                15,
                14,
                15,
                14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Their quote",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "₹${professional.quote.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.request_quote_outlined,
                    color: primaryBlue,
                    size: 28,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              professional.quoteDescription,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 18),

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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: const BorderSide(
                        color: Color(0xFFB8C9FF),
                      ),
                      minimumSize:
                          const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "View Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingSummaryScreen(
                            request: request,
                            professional: professional,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize:
                          const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Choose",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
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

  Widget _infoItem(
    IconData icon,
    Color color,
    String text,
  ) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 22,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _detailRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 19,
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

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
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              12,
              22,
              22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primaryBlue,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  professional.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                if (professional.verified)
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 17,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Verified Professional",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _profileStat(
                      "${professional.rating}",
                      "Rating",
                      Icons.star_rounded,
                    ),
                    _profileStat(
                      "${professional.experience}",
                      "Years",
                      Icons.work_outline_rounded,
                    ),
                    _profileStat(
                      "${professional.jobsCompleted}",
                      "Jobs",
                      Icons.build_circle_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _profileDetail(
                        Icons.reviews_outlined,
                        "${professional.reviews} Reviews",
                      ),
                      const SizedBox(height: 9),
                      _profileDetail(
                        Icons.location_on_outlined,
                        "${professional.distance} km away",
                      ),
                      const SizedBox(height: 9),
                      _profileDetail(
                        Icons.access_time_rounded,
                        "Can arrive in ${professional.arrivalTime}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: const BorderSide(
                        color: Color(0xFFB8C9FF),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
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

  Widget _profileStat(
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: primaryBlue,
          size: 21,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _profileDetail(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryBlue,
          size: 19,
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
