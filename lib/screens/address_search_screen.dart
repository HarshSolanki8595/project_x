import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place_prediction.dart';
import '../core/services/places_service.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState
    extends State<AddressSearchScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);

  final TextEditingController _controller =
      TextEditingController();

  final PlacesService _placesService =
      PlacesService();

  List<PlacePrediction> _predictions = [];

  bool _loading = false;

  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () async {
        if (value.trim().isEmpty) {
          if (!mounted) return;

          setState(() {
            _predictions.clear();
            _loading = false;
          });

          return;
        }

        setState(() {
          _loading = true;
        });

        try {
          final results =
              await _placesService.searchPlaces(value);

          if (!mounted) return;

          setState(() {
            _predictions = results;
          });
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }

        if (!mounted) return;

        setState(() {
          _loading = false;
        });
      },
    );
  }

  void _clearSearch() {
    _controller.clear();

    setState(() {
      _predictions.clear();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          "Search Address",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              20,
              6,
              20,
              18,
            ),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search area, building or address",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: primaryBlue,
                    size: 24,
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                ),
              ),
            ),
          ),

          if (_loading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: primaryBlue,
              backgroundColor: Color(0xFFE9EDFF),
            ),

          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_controller.text.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: primaryBlue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Find your service location",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Search for your area, building, street or landmark.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_loading && _predictions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 14),
              const Text(
                "No locations found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                "Try searching with a different area or landmark.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        30,
      ),
      itemCount: _predictions.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final place = _predictions[index];

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () {
              Navigator.pop(
                context,
                place,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color:
                          primaryBlue.withValues(alpha: .10),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: primaryBlue,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Text(
                      place.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
