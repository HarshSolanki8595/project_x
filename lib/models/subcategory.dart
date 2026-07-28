import 'package:flutter/material.dart';

class SubCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final List<String> keywords;

  const SubCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.keywords,
  });
}