import 'package:flutter/material.dart';
import 'subcategory.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SubCategory> subCategories;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subCategories,
  });
}
