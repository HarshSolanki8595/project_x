import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/service_categories.dart';
import '../../models/category.dart';

// ============================================================
// FREQUENTLY USED -- rebuilt 2026-09-04
// ============================================================
//
// Previously this was a StatelessWidget with a hardcoded list of
// six categories (Electrician, Plumber, AC Repair, Cleaning,
// Painting, Carpenter) that never changed no matter what the
// customer actually did in the app, AND its card taps went to
// `onServiceTap` which home_screen.dart wired to `(service) {}` --
// a literal no-op. So the section was "not working" in two ways at
// once: it wasn't personalized, and tapping a tile did nothing.
//
// Now: it reads the customer's own service_requests history
// (RequestService.createRequest -> RequestRepository.addRequest
// writes categoryId on every request, never categoryName -- see
// request_repository.dart), tallies how often each categoryId
// appears, and shows the top ones actually used, most-used first.
// A new customer (or one under 6 categories of history) has the
// row topped up with a sensible default set so the section never
// looks empty on day one. Tapping a tile calls onServiceTap with
// the category's real name, same contract as before, so
// home_screen.dart only needs its callback wired to navigate (see
// the matching CategoryGrid/QuickServicesSection callbacks there)
// instead of changing shape here.
// ============================================================

class FrequentlyUsedSection extends StatefulWidget {
  const FrequentlyUsedSection({
    super.key,
    this.onServiceTap,
  });

  final Function(String)? onServiceTap;

  @override
  State<FrequentlyUsedSection> createState() =>
      _FrequentlyUsedSectionState();
}

class _FrequentlyUsedSectionState extends State<FrequentlyUsedSection> {
  // Fallback set for new customers / thin history -- same categories
  // the old hardcoded version showed, just resolved through the real
  // ServiceCategories list instead of a separate ad hoc icon/color
  // list, so they stay in sync with the taxonomy automatically.
  static const List<String> _defaultCategoryIds = [
    'electrical',
    'plumbing',
    'appliances',
    'cleaning',
    'painting',
    'carpentry',
  ];

  static const int _maxTiles = 6;

  bool _loading = true;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadFrequentlyUsed();
  }

  Future<void> _loadFrequentlyUsed() async {
    final user = FirebaseAuth.instance.currentUser;

    List<Category> result = [];

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('service_requests')
            .where('customerId', isEqualTo: user.uid)
            .get();

        final Map<String, int> counts = {};

        for (final doc in snapshot.docs) {
          final String categoryId =
              (doc.data()['categoryId'] as String?) ?? '';

          if (categoryId.isEmpty) continue;

          counts[categoryId] = (counts[categoryId] ?? 0) + 1;
        }

        final sortedIds = counts.keys.toList()
          ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

        result = sortedIds
            .map((id) => ServiceCategories.getCategoryById(id))
            .whereType<Category>()
            .toList();
      } catch (e) {
        debugPrint('FrequentlyUsedSection: failed to load history: $e');
        // Falls through to the default top-up below -- a failed read
        // here should never block the rest of the home screen.
      }
    }

    // Top up with defaults (skipping anything already present) until
    // there's a full row. Covers brand-new customers with no request
    // history at all, and customers who've only used 1-2 categories
    // so far.
    if (result.length < _maxTiles) {
      for (final id in _defaultCategoryIds) {
        if (result.length >= _maxTiles) break;
        if (result.any((c) => c.id == id)) continue;

        final category = ServiceCategories.getCategoryById(id);
        if (category != null) result.add(category);
      }
    }

    if (!mounted) return;

    setState(() {
      _categories = result.take(_maxTiles).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Frequently Used",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 116,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = _categories[index];

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => widget.onServiceTap?.call(category.name),
                child: Container(
                  width: 104,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFEEF3FF),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor:
                            category.color.withValues(alpha: 0.12),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
