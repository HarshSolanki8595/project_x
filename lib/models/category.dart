import 'package:flutter/material.dart';
import 'subcategory.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SubCategory> subCategories;

  // Added 2026-09-01: flags a category as a "Quick Service" (currently
  // Helper Services + Cleaning) so the home screen can pull it into its
  // own segregated section instead of the general Browse Categories
  // grid. Defaults to false so every existing Category(...) call site
  // in service_categories.dart keeps compiling unchanged.
  final bool isQuickService;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subCategories,
    this.isQuickService = false,
  });
}
