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
          });

          return;
        }

        setState(() {
          _loading = true;
        });

        try {

          final results =
              await _placesService.searchPlaces(
            value,
          );

          if (!mounted) return;

          setState(() {
            _predictions = results;
          });

        } catch (e) {

          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
              ),
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

  @override
  void dispose() {

    _debounce?.cancel();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Search Address",
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: Column(

        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(

              controller: _controller,

              autofocus: true,

              onChanged: _onSearchChanged,

              decoration: InputDecoration(

                hintText:
                    "Search address...",

                prefixIcon: const Icon(
                  Icons.search,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (_loading)
            const LinearProgressIndicator(),

          Expanded(

            child: ListView.builder(

              itemCount:
                  _predictions.length,

              itemBuilder:
                  (context, index) {

                final place =
                    _predictions[index];

                return ListTile(

                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                  ),

                  title: Text(
                    place.description,
                  ),

                  onTap: () {

                    Navigator.pop(
                      context,
                      place,
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}