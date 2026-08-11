import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onTap,
    this.onVoiceTap,
    this.controller,
  });

  final VoidCallback? onTap;
  final VoidCallback? onVoiceTap;
  final TextEditingController? controller;

  static const Color primaryBlue = Color(0xFF1557FF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE1E7EF),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 27,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: IgnorePointer(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search services...",
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: const Color(0xFFE1E7EF),
                ),
                const SizedBox(width: 11),
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: onVoiceTap,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_none_rounded,
                      color: primaryBlue,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
