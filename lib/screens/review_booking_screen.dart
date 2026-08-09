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

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color backgroundColor = Color(0xFFF7F8FC);

  Widget _buildSectionTitle(String title) {
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
      padding: const EdgeInsets.all(18),
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

  String get formattedDate {
    if (request.preferredDate == null) {
      return "Not Selected";
    }

    return DateFormat(
      "dd MMM yyyy",
    ).format(request.preferredDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          "Review Booking",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
                      "Review your request",
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Make sure everything looks right before sending your request.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSectionTitle("Service"),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.categoryName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            request.subCategoryName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          if (request.isEmergency) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade100,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Emergency Service",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    _buildSectionTitle("Issue Description"),

                    _buildCard(
                      child: Text(
                        request.issueDescription.isEmpty
                            ? "No description provided."
                            : request.issueDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    _buildSectionTitle("Photos"),

                    _buildCard(
                      child: request.photos.isEmpty
                          ? const Row(
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "No photos attached.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: request.photos.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      right: 12,
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      child: Image.file(
                                        request.photos[index],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),

                    _buildSectionTitle("Service Address"),

                    _buildCard(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color:
                                  primaryBlue.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: primaryBlue,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              request.address == null ||
                                      request.address!.isEmpty
                                  ? "No address selected"
                                  : request.address!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle("Preferred Schedule"),

                    _buildCard(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color:
                                  primaryBlue.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: primaryBlue,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  request.preferredTimeSlot ??
                                      "Not Selected",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle("What Happens Next"),

                    _buildCard(
                      child: Column(
                        children: const [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            title: Text(
                              "Your request will be sent to nearby verified professionals.",
                            ),
                          ),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            title: Text(
                              "Professionals will review your request and send quotations.",
                            ),
                          ),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            title: Text(
                              "Compare prices, ratings and reviews before choosing one.",
                            ),
                          ),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            title: Text(
                              "No payment is required until you accept a quotation.",
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    color: Colors.black.withValues(alpha: 0.06),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FindingProfessionalsScreen(
                          request: request,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Request Quotes",
                    style: TextStyle(
                      fontSize: 16,
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
}
