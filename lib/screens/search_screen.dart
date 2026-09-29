import 'package:flutter/material.dart';

import '../data/service_categories.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import 'fixed_price_request_screen.dart';
import 'service_request_screen.dart';

// ================================================================
// SEARCH SCREEN -- WIRED TO REAL SUGGESTIONS (2026-09-16)
// ================================================================
//
// Previously just a text field over two static, non-functional lists
// (a few hardcoded "Recent Searches" chips, a hardcoded "Popular
// Services" list with no onTap at all). Typing did nothing.
//
// Now, as the customer types, this matches against every
// SubCategory's name and `keywords` list (already defined per
// subcategory in data/service_categories.dart -- e.g. "fan",
// "ceiling fan", "exhaust fan" under Electrical > Fans) across every
// category, first on the whole typed phrase, then falling back to a
// per-word match so a multi-word phrase like "leaking tap" still
// finds "Plumbing > Taps & Faucets" even if no single keyword equals
// the whole phrase. If nothing matches at all, it falls back to
// showing one representative service from each category instead of
// an empty screen, per Harsh's "if nothing comes up any other
// services should come up from a category" instruction.
//
// Tapping any suggestion -- matched or fallback -- continues into
// the exact same booking flow SubcategoryScreen already uses
// (categories/subcategory_screen.dart): FixedPriceRequestScreen for
// Quick Service categories (fixed price, no bidding), otherwise
// ServiceRequestScreen. The "Recent Searches" chips and the original
// "Popular Services" tiles are kept, but now actually do something:
// tapping a chip runs that search, and tapping a Popular Services
// tile looks up and opens the matching subcategory directly.
// ================================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchResult {
  final Category category;
  final SubCategory subCategory;

  const _SearchResult({
    required this.category,
    required this.subCategory,
  });
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  static const List<String> _recentSearches = [
    "AC Service",
    "Electrician",
    "Plumber",
  ];

  static const List<String> _popularServiceLabels = [
    "Electrician",
    "Plumber",
    "AC Repair",
    "Home Cleaning",
    "Carpenter",
  ];

  static const Map<String, IconData> _popularServiceIcons = {
    "Electrician": Icons.electrical_services,
    "Plumber": Icons.plumbing,
    "AC Repair": Icons.ac_unit,
    "Home Cleaning": Icons.cleaning_services,
    "Carpenter": Icons.handyman,
  };

  @override
  void initState() {
    super.initState();
    // Cheap to re-filter on every keystroke -- the whole catalog is a
    // small, fully in-memory const list, nothing async involved.
    searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onQueryChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {});
  }

  // ============================================================
  // MATCHING
  // ============================================================

  List<_SearchResult> _findMatches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final words = q
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();

    // Two tiers: `exact` (substring matches, either direction) is
    // ranked first; `near` (typo-tolerant, edit-distance based --
    // "elecrician" or "plumer" still finding the right service) is
    // appended after, only for subcategories that didn't already
    // qualify as exact. UPDATED (2026-09-16, Harsh: "should not be
    // an exact match but a near match suggestions") -- substring
    // matching alone missed simple misspellings, since e.g.
    // "elecrician" is not a substring of "electrician" in either
    // direction.
    final exact = <_SearchResult>[];
    final near = <_SearchResult>[];

    for (final category in ServiceCategories.all) {
      for (final subCategory in category.subCategories) {
        final name = subCategory.name.toLowerCase();
        final keywords =
            subCategory.keywords.map((k) => k.toLowerCase()).toList();

        // Whole-phrase match first (either direction, so a keyword
        // like "ac" matches a typed "ac repair" and vice versa).
        final wholePhraseMatch = name.contains(q) ||
            keywords.any((k) => k.contains(q) || q.contains(k));

        // Word-level fallback -- lets "leaking tap" find "Taps &
        // Faucets" even though no single keyword equals the full
        // typed sentence.
        final anyWordMatch = words.isNotEmpty &&
            words.any(
              (w) => name.contains(w) || keywords.any((k) => k.contains(w)),
            );

        if (wholePhraseMatch || anyWordMatch) {
          exact.add(
            _SearchResult(category: category, subCategory: subCategory),
          );
          continue;
        }

        // Near-match tier -- compare each typed word against each
        // word in the subcategory's name and against each keyword,
        // tolerating a small edit distance that scales with word
        // length (short words need to be almost exact; longer words
        // tolerate a couple of typos).
        final nameWords = name.split(RegExp(r'[\s&/]+'));
        final candidateWords = [...nameWords, ...keywords];

        final hasNearMatch = words.isNotEmpty &&
            words.any(
              (w) => candidateWords.any((c) => _isNearMatch(w, c)),
            );

        if (hasNearMatch) {
          near.add(
            _SearchResult(category: category, subCategory: subCategory),
          );
        }
      }
    }

    return [...exact, ...near];
  }

  // Classic Levenshtein edit distance -- minimum single-character
  // insertions/deletions/substitutions to turn `a` into `b`.
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> previousRow = List<int>.generate(b.length + 1, (j) => j);
    List<int> currentRow = List<int>.filled(b.length + 1, 0);

    for (int i = 1; i <= a.length; i++) {
      currentRow[0] = i;

      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;

        final deletion = previousRow[j] + 1;
        final insertion = currentRow[j - 1] + 1;
        final substitution = previousRow[j - 1] + cost;

        currentRow[j] = [
          deletion,
          insertion,
          substitution,
        ].reduce((x, y) => x < y ? x : y);
      }

      final swap = previousRow;
      previousRow = currentRow;
      currentRow = swap;
    }

    return previousRow[b.length];
  }

  // Threshold scales with word length so short words ("ac", "led")
  // still require an almost-exact hit, while longer words like
  // "electrician" tolerate a couple of typos.
  bool _isNearMatch(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;

    final longer = a.length > b.length ? a.length : b.length;
    final threshold = longer <= 4
        ? 1
        : longer <= 8
            ? 2
            : 3;

    return _levenshtein(a, b) <= threshold;
  }

  // No matches at all for what was typed -- surface one service from
  // each category instead of leaving the customer at a dead end.
  List<_SearchResult> _fallbackSuggestions() {
    final results = <_SearchResult>[];

    for (final category in ServiceCategories.all) {
      if (category.subCategories.isEmpty) continue;

      results.add(
        _SearchResult(
          category: category,
          subCategory: category.subCategories.first,
        ),
      );

      if (results.length >= 10) break;
    }

    return results;
  }

  _SearchResult? _findByLabel(String label) {
    final matches = _findMatches(label);
    if (matches.isEmpty) return null;
    return matches.first;
  }

  // ============================================================
  // NAVIGATION -- same routing SubcategoryScreen uses, so a search
  // result lands in exactly the same booking flow a customer would
  // reach by browsing categories manually.
  // ============================================================

  void _openResult(_SearchResult result) {
    final category = result.category;
    final subCategory = result.subCategory;

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
              ),
      ),
    );
  }

  void _runSearch(String label) {
    searchController.text = label;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: label.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim();
    final isSearching = query.isNotEmpty;

    // Explicit List<_SearchResult> annotations -- without them, Dart
    // infers the ternary's "no query yet" branch (`const []`) as
    // List<dynamic>, widening `matches`/`fallback` to List<dynamic>
    // too and breaking the call into _buildSearchResults below
    // (argument_type_not_assignable).
    final List<_SearchResult> matches =
        isSearching ? _findMatches(query) : const [];
    final bool showFallback = isSearching && matches.isEmpty;
    final List<_SearchResult> fallback =
        showFallback ? _fallbackSuggestions() : const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Search Services",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: "Search for any service...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearching
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.mic),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: isSearching
                    ? _buildSearchResults(matches, showFallback, fallback, query)
                    : _buildIdleState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IDLE STATE -- nothing typed yet: Recent Searches + Popular
  // Services, same content as before, now both actually functional.
  // ============================================================

  Widget _buildIdleState() {
    return ListView(
      children: [
        const Text(
          "Recent Searches",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _recentSearches
              .map(
                (label) => ActionChip(
                  label: Text(label),
                  onPressed: () => _runSearch(label),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 35),
        const Text(
          "Popular Services",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        ..._popularServiceLabels.map(
          (label) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _popularServiceIcons[label] ?? Icons.build_outlined,
            ),
            title: Text(label),
            onTap: () {
              final result = _findByLabel(label);
              if (result != null) {
                _openResult(result);
              } else {
                // Shouldn't normally happen -- these labels are
                // curated to exist in the catalog -- but falls back
                // to running it as a live search instead of doing
                // nothing if the catalog ever changes.
                _runSearch(label);
              }
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCHING STATE
  // ============================================================

  Widget _buildSearchResults(
    List<_SearchResult> matches,
    bool showFallback,
    List<_SearchResult> fallback,
    String query,
  ) {
    if (!showFallback) {
      return ListView.separated(
        itemCount: matches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (context, index) =>
            _resultTile(matches[index]),
      );
    }

    // No matches for what was typed -- offer other services instead
    // of an empty screen, still leading into the normal booking flow.
    return ListView(
      children: [
        Text(
          'No matches for "$query"',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "You might still be looking for one of these:",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),
        ...fallback.map(_resultTile),
      ],
    );
  }

  Widget _resultTile(_SearchResult result) {
    final category = result.category;
    final subCategory = result.subCategory;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openResult(result),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF3FF)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: category.color.withValues(alpha: .15),
              child: Icon(subCategory.icon, color: category.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategory.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
