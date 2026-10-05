import 'package:flutter/material.dart';

class SubCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final List<String> keywords;

  // Added 2026-10-01: cross-category subcategory-duplication cleanup.
  // When a subcategory's work used to be listed separately under
  // another category too (e.g. Geyser Repair, canonical here under
  // Appliances, used to also exist as Plumbing's own "Geyser
  // Installation & Connection"), that other category's id goes here
  // instead of the duplicate being kept around. It does NOT change
  // anything in this app -- the customer still only ever sees this
  // subcategory listed once, under its one real category. It's read
  // by the professional app's Skills screen, which uses it to let a
  // professional registered under a *related* category (e.g.
  // Plumbing) optionally pick this subcategory as one of their own
  // skills too, so the work doesn't get stranded under just one
  // category's professional pool. Defaults to empty so every existing
  // SubCategory(...) call site keeps compiling unchanged.
  final List<String> relatedCategories;

  // Added 2026-10-02: narrower cross-skill matching for Appliances
  // and Automobile. These two categories bundle genuinely different
  // trades under one main category (AC repair vs. TV repair; car
  // vs. bike mechanics), so the Cloud Function's old "nobody has the
  // exact subcategory? fall back to ANYONE in this main category"
  // safety net was notifying professionals about jobs well outside
  // their actual skill -- an AC-only professional seeing TV repair
  // requests, a car-only professional seeing bike jobs, whenever
  // supply for the exact subcategory was thin (which is often, this
  // early on). matchGroup narrows that fallback to professionals
  // covering the same real-world trade family instead of the whole
  // category. Null for every category where this doesn't apply --
  // the fallback there is untouched.
  //
  // Appliances values: 'cooling', 'kitchen_laundry', 'water_systems',
  // 'electronics'. Automobile values: 'car', 'bike', 'both' (a
  // handful of genuinely vehicle-agnostic items -- Battery, Tyre &
  // Puncture, Oil Change, Vehicle Inspection, Roadside Breakdown
  // Assistance, EV Charging, General Automobile Service -- that
  // either vehicle-type professional can pick; the customer's own
  // request flow asks which vehicle it's for on these specific
  // items, since the subcategory id alone can't tell).
  final String? matchGroup;

  const SubCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.keywords,
    this.relatedCategories = const [],
    this.matchGroup,
  });
}