import 'package:flutter/material.dart';

import '../models/service_request.dart';
import 'review_booking_screen.dart';

class DateTimeScreen extends StatefulWidget {
  final ServiceRequest request;

  const DateTimeScreen({
    super.key,
    required this.request,
  });

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);

  DateTime selectedDate = DateTime.now();

  String selectedSlot = "Evening";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _continue() {
    widget.request.preferredDate = selectedDate;
    widget.request.preferredTimeSlot = selectedSlot;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewBookingScreen(
          request: widget.request,
        ),
      ),
    );
  }

  Widget _timeSlotCard({
    required String title,
    required IconData icon,
  }) {
    final bool selected = selectedSlot == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSlot = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryBlue
                : Colors.grey.shade300,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: selected
                    ? primaryBlue.withValues(alpha: 0.10)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: selected
                    ? primaryBlue
                    : Colors.grey.shade600,
                size: 30,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? primaryBlue
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
    return "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          "Schedule Service",
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "When do you need the\nservice?",
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 42),

                    const Text(
                      "Select a date",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: primaryBlue
                                    .withValues(alpha: .10),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: primaryBlue,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Service date",
                                    style: TextStyle(
                                      color:
                                          Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formattedDate(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.edit_calendar_rounded,
                              color: primaryBlue,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      "Preferred time",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _timeSlotCard(
                      title: "Morning",
                      icon: Icons.wb_sunny_outlined,
                    ),

                    _timeSlotCard(
                      title: "Afternoon",
                      icon: Icons.wb_sunny_rounded,
                    ),

                    _timeSlotCard(
                      title: "Evening",
                      icon: Icons.nightlight_outlined,
                    ),

                    _timeSlotCard(
                      title: "Anytime",
                      icon: Icons.access_time_rounded,
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom button.
            Container(
              color: const Color(0xFFF7F8FC),
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
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
}