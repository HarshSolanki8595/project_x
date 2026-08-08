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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Confirm your booking",
                      style: TextStyle(
                        fontSize: 29,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Review the details before confirming your service.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _sectionTitle("Service"),

                    _buildCard(
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.home_repair_service_rounded,
                            "Category",
                            request.categoryName,
                          ),
                          const SizedBox(height: 15),
                          _infoRow(
                            Icons.handyman_rounded,
                            "Service",
                            request.subCategoryName,
                          ),
                        ],
                      ),
                    ),

                    _sectionTitle("Issue"),

                    _buildCard(
                      child: Text(
                        request.issueDescription.isEmpty
                            ? "No description provided."
                            : request.issueDescription,
                        style: const TextStyle(
                          fontSize: 15.5,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    _sectionTitle("Professional"),

                    _buildCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 58,
                                width: 58,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF3FF),
                                  borderRadius:
                                      BorderRadius.circular(17),
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
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 17,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${professional.rating}",
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          "${professional.reviews} reviews",
                                          style: TextStyle(
                                            color:
                                                Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 17),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5FF),
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Agreed quote",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Professional's quote",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "₹${professional.quote.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              professional.quoteDescription,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _sectionTitle("Service Address"),

                    _buildCard(
                      child: _infoRow(
                        Icons.location_on_rounded,
                        "Address",
                        request.address ?? "",
                      ),
                    ),

                    _sectionTitle("Schedule"),

                    _buildCard(
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.calendar_month_rounded,
                            "Date",
                            request.preferredDate == null
                                ? ""
                                : "${request.preferredDate!.day}/${request.preferredDate!.month}/${request.preferredDate!.year}",
                          ),
                          const SizedBox(height: 15),
                          _infoRow(
                            Icons.access_time_rounded,
                            "Time",
                            request.preferredTimeSlot ?? "",
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF9F2),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFD5EEDC),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.green,
                            size: 21,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "You will only be charged according to the booking terms after confirming the service.",
                              style: TextStyle(
                                color: Color(0xFF356344),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(
                            color: primaryBlue,
                          ),
                        ),
                      );

                      final bookingId =
                          await BookingService.createBooking(
                        request: request,
                        professional: professional,
                      );

                      if (!context.mounted) return;

                      Navigator.pop(context);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmedScreen(
                            bookingId: bookingId,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
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
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
