import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/place_prediction.dart';

class PlacesService {
  // Paste your Google Maps API Key here.
  static const String apiKey = "AIzaSyA1cDaGC7kapQJS9rU94eOqVkcKOk8H54c";

  static const String _autocompleteUrl =
      "https://places.googleapis.com/v1/places:autocomplete";

  Future<List<PlacePrediction>> searchPlaces(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final response = await http.post(
      Uri.parse(_autocompleteUrl),
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": apiKey,

        // Return only what we need.
        "X-Goog-FieldMask":
            "suggestions.placePrediction.placeId,"
            "suggestions.placePrediction.text.text",
      },
      body: jsonEncode({
        "input": query,

        // Bias results towards India.
        "includedRegionCodes": ["IN"],

        "sessionToken": "projectx-session",

        "languageCode": "en",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    final List suggestions = json["suggestions"] ?? [];

    return suggestions
        .where((e) => e["placePrediction"] != null)
        .map<PlacePrediction>(
          (e) => PlacePrediction.fromJson(e),
        )
        .toList();
  }

  Future<Map<String, double>> getPlaceLocation(
    String placeId,
  ) async {
    final response = await http.get(
      Uri.parse(
        "https://places.googleapis.com/v1/places/$placeId",
      ),
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": apiKey,

        "X-Goog-FieldMask":
            "location",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    return {
      "lat": json["location"]["latitude"],
      "lng": json["location"]["longitude"],
    };
  }
}