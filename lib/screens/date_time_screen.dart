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
  // STATE
  // ============================================================

  DateTime selectedDate = DateTime.now();

  String selectedSlot = "Anytime";

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> pickDate() async {
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

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  // ============================================================
  // TIME OPTION
  // ============================================================

  Widget _buildTimeOption(
    String title,
    IconData icon,
  ) {
    final bool selected = selectedSlot == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            selectedSlot = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? lightBlue : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? primaryBlue : borderColor,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE0E9FF)
                      : const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? primaryBlue
                      : textSecondary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              ),

              Container(
                height: 23,
                width: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? primaryBlue
                        : const Color(0xFF94A3B8),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          height: 11,
                          width: 11,
                          decoration: const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTINUE
  // ============================================================

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
          "Schedule Service",
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
                    // TITLE
                    // =================================================

                    const Text(
                      "When do you need the\nservice?",
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =================================================
                    // DATE
                    // =================================================

                    const Text(
                      "Select a date",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    InkWell(
                      borderRadius:
                          BorderRadius.circular(18),
                      onTap: pickDate,
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: primaryBlue,
                                size: 25,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Service date",
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontSize: 17,
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
                              size: 23,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =================================================
                    // TIME
                    // =================================================

                    const Text(
                      "Preferred time",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    _buildTimeOption(
                      "Morning",
                      Icons.wb_sunny_outlined,
                    ),

                    _buildTimeOption(
                      "Afternoon",
                      Icons.wb_sunny_rounded,
                    ),

                    _buildTimeOption(
                      "Evening",
                      Icons.nightlight_outlined,
                    ),

                    _buildTimeOption(
                      "Anytime",
                      Icons.access_time_rounded,
                    ),
                  ],
                ),
              ),
            ),

            // =========================================================
            // BOTTOM BUTTON
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
                  onPressed: _continue,
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
                    "Continue",
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
}