import 'package:flutter/material.dart';

// ============================================================
// DAY-TO-DAY SERVICES -- "COMING SOON" PREVIEW LIST
// ============================================================
//
// Added 2026-09-30, per Harsh: the "Day-to-Day Services" /
// "Trial & Retain" concept built earlier (recurring maids, cooks,
// drivers, daily cleaning, etc. as a dedicated fixed-price category)
// was dropped as a real, bookable category -- see service_categories
// .dart, where Cleaning and Helper Services went back to being their
// own normal Quick Service categories, and every one of these
// subcategory ids lives there instead.
//
// Harsh then asked NOT to delete the Day-to-Day Services concept
// outright: he wants it to stay visible on the home screen and its
// own "see all" list, purely as a "Coming Soon" preview -- so
// customers know these recurring services are on the way -- with
// tapping a tile doing nothing for now. Because these names/ids
// already exist as real, bookable subcategories under Cleaning /
// Helper Services (same ids, deliberately, so nothing has to be
// renamed later if Day-to-Day Services ever becomes real again),
// this preview is a plain presentational list -- NOT wired into
// Category/SubCategory/ServiceCategories.all in any way. It is not a
// Category, doesn't set isQuickService, isn't in CategoryGrid's or
// SubcategoryScreen's lookups, and a tap here can't accidentally
// route into the real (already-bookable) Cleaning/Helper Services
// flow for the same-named service.
//
// If/when this becomes a real category again, promote these back
// into service_categories.dart the same way the 2026-09-29 restructure
// did (see that file's git history / the project's decision log) and
// delete this file.
// ============================================================

class ComingSoonService {
  final IconData icon;
  final String name;

  const ComingSoonService({
    required this.icon,
    required this.name,
  });
}

const List<ComingSoonService> kDayToDayComingSoonServices = [
  ComingSoonService(icon: Icons.home, name: 'Full-Time Maid / Domestic Help'),
  ComingSoonService(icon: Icons.cleaning_services, name: 'Part-Time Maid / Domestic Help'),
  ComingSoonService(icon: Icons.kitchen, name: 'Cook (Daily / Occasional)'),
  ComingSoonService(icon: Icons.directions_car, name: 'Driver on Hire'),
  ComingSoonService(icon: Icons.pets, name: 'Dog Walking / Pet Care'),
  ComingSoonService(icon: Icons.nightlight_round, name: 'Night Nurse / Caregiver'),
  ComingSoonService(icon: Icons.home_filled, name: 'Home Cleaning'),
  ComingSoonService(icon: Icons.bathtub_outlined, name: 'Bathroom Cleaning'),
  ComingSoonService(icon: Icons.soup_kitchen_outlined, name: 'Kitchen/Utensil Cleaning'),
  ComingSoonService(icon: Icons.business, name: 'Office & Commercial Cleaning'),
  ComingSoonService(icon: Icons.local_laundry_service, name: 'Clothes Cleaning'),
  ComingSoonService(icon: Icons.local_laundry_service_outlined, name: 'Clothes Washing'),
  ComingSoonService(icon: Icons.local_car_wash, name: 'Regular Car Cleaning'),
];
