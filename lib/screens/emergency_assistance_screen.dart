import 'package:flutter/material.dart';

import '../data/service_categories.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import 'fixed_price_request_screen.dart';
import 'service_request_screen.dart';

// ================================================================
// EMERGENCY ASSISTANCE -- added 2026-09-04
// ================================================================
// Reached by tapping the "Emergency Assistance" card on the customer
// home screen (previously EmergencyCard's onTap was `() {}`, a
// no-op -- see home_screen.dart).
//
// DEFINITION, per Harsh's 2026-09-04 request ("emergency assistance
// to be defined as nighttime assistance... I'll leave it up to you
// as to define what all categories or subcategories are included"):
// an emergency doesn't wait for a clock to say it's night, so this
// is scoped by WHICH services genuinely can't wait -- safety and
// habitability issues a customer could just as easily hit at 2pm as
// 2am -- rather than gating the card itself to a time window. The
// "night" framing lives in the copy below (this is explicitly the
// thing you reach for when something goes wrong after hours), while
// the feature itself stays available and useful at any hour.
//
// Curated list (existing taxonomy ids, so capabilityId/categoryId
// stay identical to normal requests -- matching is untouched):
//   Electrical      -- general, distribution_board (MCB/fuse trip),
//                       wiring (short circuit / total power loss)
//   Plumbing        -- water_leakage (burst pipe), drainage,
//                       general_plumbing
//   Home Repair     -- hardware (locked out), general_home
//   Appliances      -- air_conditioner, refrigerator,
//                       general_appliance (spoiling food overnight)
//   Helper Services -- night_caregiver (already named "Night
//                       Nurse / Caregiver" in the taxonomy)
//
// REVISED 2026-09-29: elderly_care was removed from the taxonomy
// entirely (Habio isn't onboarding for it for now, per Harsh) --
// dropped from this list too.
//
// Deliberately excluded: cosmetic/schedulable categories (Painting,
// Beauty, Moving, Decoration & Events, etc.) -- nothing there is a
// genuine can't-wait-until-morning situation.
//
// Picking a subcategory here goes into ServiceRequestScreen with
// initialIsEmergency: true (flagged the same way manually toggling
// "Mark this request as an emergency" on that screen would), UNLESS
// the subcategory's category is a Quick Service (Helper Services or
// Cleaning) -- those always go through FixedPriceRequestScreen
// instead, same as everywhere else in the app (see
// SubcategoryScreen/search_screen.dart for the same
// category.isQuickService branch). FixedPriceRequestScreen doesn't
// have an emergency flag yet, so an emergency night-caregiver booking
// today gets the right tiered pricing but isn't marked emergency
// internally -- worth a follow-up if that flag needs to reach Quick
// Service bookings too.
// ================================================================

class _EmergencyOption {
  final String categoryId;
  final String subCategoryId;
  final String reason;

  const _EmergencyOption({
    required this.categoryId,
    required this.subCategoryId,
    required this.reason,
  });
}

class EmergencyAssistanceScreen extends StatelessWidget {
  const EmergencyAssistanceScreen({super.key});

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color pageBackground = Color(0xFFF7F8FC);
  static const Color emergencyRed = Color(0xFFD92D20);
  static const Color emergencyRedBg = Color(0xFFFFF7F7);
  static const Color emergencyRedBorder = Color(0xFFFECACA);

  static const List<_EmergencyOption> _options = [
    _EmergencyOption(
      categoryId: 'electrical',
      subCategoryId: 'general',
      reason: 'Total power loss or sparking',
    ),
    _EmergencyOption(
      categoryId: 'electrical',
      subCategoryId: 'distribution_board',
      reason: 'MCB keeps tripping / fuse blown',
    ),
    _EmergencyOption(
      categoryId: 'electrical',
      subCategoryId: 'wiring',
      reason: 'Short circuit / burning smell',
    ),
    _EmergencyOption(
      categoryId: 'plumbing',
      subCategoryId: 'water_leakage',
      reason: 'Burst pipe or major leak',
    ),
    _EmergencyOption(
      categoryId: 'plumbing',
      subCategoryId: 'drainage',
      reason: 'Sewage backup or total blockage',
    ),
    _EmergencyOption(
      categoryId: 'plumbing',
      subCategoryId: 'general_plumbing',
      reason: 'Any other plumbing emergency',
    ),
    _EmergencyOption(
      categoryId: 'home_repair',
      subCategoryId: 'hardware',
      reason: 'Locked out / broken lock',
    ),
    _EmergencyOption(
      categoryId: 'home_repair',
      subCategoryId: 'general_home',
      reason: 'Structural or safety issue',
    ),
    _EmergencyOption(
      categoryId: 'appliances',
      subCategoryId: 'air_conditioner',
      reason: 'AC down in extreme heat',
    ),
    _EmergencyOption(
      categoryId: 'appliances',
      subCategoryId: 'refrigerator',
      reason: 'Fridge down, food at risk',
    ),
    _EmergencyOption(
      categoryId: 'appliances',
      subCategoryId: 'general_appliance',
      reason: 'Any other appliance emergency',
    ),
    _EmergencyOption(
      categoryId: 'helper_services',
      subCategoryId: 'night_caregiver',
      reason: 'Overnight nursing / caregiving',
    ),
  ];

  void _openRequest(
    BuildContext context,
    Category category,
    SubCategory subCategory,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => category.isQuickService
            ? FixedPriceRequestScreen(
                categoryName: category.name,
                subCategoryName: subCategory.name,
                subCategoryId: subCategory.id,
                categoryId: category.id,
              )
            : ServiceRequestScreen(
                categoryName: category.name,
                subCategoryName: subCategory.name,
                subCategoryId: subCategory.id,
                categoryId: category.id,
                initialIsEmergency: true,
                matchGroup: subCategory.matchGroup,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Resolve the curated ids against the live taxonomy rather than
    // hardcoding names/icons here a second time -- if a subcategory
    // is ever renamed in service_categories.dart, this list follows
    // automatically instead of silently drifting out of sync.
    final Map<Category, List<SubCategory>> grouped = {};

    for (final option in _options) {
      final category = ServiceCategories.getCategoryById(option.categoryId);
      if (category == null) continue;

      final subCategory = category.subCategories
          .where((s) => s.id == option.subCategoryId)
          .toList();
      if (subCategory.isEmpty) continue;

      grouped.putIfAbsent(category, () => []).add(subCategory.first);
    }

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: darkText,
        title: const Text(
          "Emergency Assistance",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _buildIntroCard(),
            const SizedBox(height: 26),
            for (final entry in grouped.entries) ...[
              _buildCategoryLabel(entry.key),
              const SizedBox(height: 10),
              ...entry.value.map(
                (sub) => _buildOptionTile(
                  context,
                  entry.key,
                  sub,
                  _options
                      .firstWhere(
                        (o) =>
                            o.categoryId == entry.key.id &&
                            o.subCategoryId == sub.id,
                      )
                      .reason,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: emergencyRedBg,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: emergencyRedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: emergencyRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "For issues that can't wait",
                  style: TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Day or night, these are flagged as urgent so nearby "
                  "professionals are notified first. Pick what's "
                  "happening below.",
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLabel(Category category) {
    return Row(
      children: [
        Icon(category.icon, color: category.color, size: 18),
        const SizedBox(width: 8),
        Text(
          category.name,
          style: const TextStyle(
            color: darkText,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    Category category,
    SubCategory subCategory,
    String reason,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openRequest(context, category, subCategory),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subCategory.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subCategory.name,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFFCBD1DB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
