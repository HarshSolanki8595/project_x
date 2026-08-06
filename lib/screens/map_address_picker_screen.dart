import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapAddressPickerScreen extends StatefulWidget {
  const MapAddressPickerScreen({super.key});

  @override
  State<MapAddressPickerScreen> createState() =>
      _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState
    extends State<MapAddressPickerScreen> {

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  CameraPosition _cameraPosition =
      const CameraPosition(
    target: LatLng(
      19.0760,
      72.8777,
    ),
    zoom: 17,
  );

  bool _loading = true;

  String _selectedAddress =
      "Fetching current location...";
      String _house = "";
String _street = "";
String _area = "";
String _city = "";
String _state = "";
String _pincode = "";

  Position? _currentPosition;

final TextEditingController _searchController =
    TextEditingController();

final FocusNode _searchFocus =
    FocusNode();

List<dynamic> _predictions = [];

bool _isSearching = false;

static const String placesApiKey =
    "AIzaSyA1cDaGC7kapQJS9rU94eOqVkcKOk8H54c";

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        _loading = false;
        _selectedAddress =
            "Please enable Location Services.";
      });
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      setState(() {
        _loading = false;
        _selectedAddress =
            "Location Permission Denied";
      });
      return;
    }

    _currentPosition =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _cameraPosition = CameraPosition(
      target: LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      ),
      zoom: 18,
    );

    await _updateAddress(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateAddress(
    double latitude,
    double longitude,
  ) async {

    try {

      final placemarks =
          await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {

        final p = placemarks.first;

_house = p.name ?? "";

_street = p.street ?? "";

_area = p.subLocality ?? "";

_city = p.locality ?? "";

_state = p.administrativeArea ?? "";

_pincode = p.postalCode ?? "";

        setState(() {

          _selectedAddress =
              "${p.name ?? ""}, "
              "${p.street ?? ""}, "
              "${p.subLocality ?? ""}, "
              "${p.locality ?? ""}, "
              "${p.postalCode ?? ""}";

        });

      }

    } catch (_) {}

  }

Future<void> _cameraMoved(
  CameraPosition position,
) async {
  _cameraPosition = position;
}

Future<void> _searchPlaces(
  String input,
) async {

  if (input.trim().isEmpty) {

    setState(() {
      _predictions.clear();
    });

    return;
  }

  final url =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=$input"
      "&components=country:in"
      "&key=$placesApiKey";

  final response =
      await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    return;
  }

  final data =
      jsonDecode(response.body);

  setState(() {

    _predictions =
        data["predictions"] ?? [];

  });
}  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [

                GoogleMap(
                  initialCameraPosition:
                      _cameraPosition,

                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,

                  onMapCreated: (controller) {
                    _mapController.complete(
                      controller,
                    );
                  },

                  onCameraMove: (position) {
                    _cameraPosition = position;
                  },

                  onCameraIdle: () async {
                    await _updateAddress(
                      _cameraPosition.target.latitude,
                      _cameraPosition.target.longitude,
                    );
                  },
                ),

                const Center(
                  child: IgnorePointer(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 55,
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Material(
                      elevation: 4,
                      borderRadius:
                          BorderRadius.circular(14),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                        child: TextField(
  controller: _searchController,
  focusNode: _searchFocus,
  onChanged: (value) {
  _searchPlaces(value);
},
  decoration: const InputDecoration(
    hintText:
        "Search area, street or apartment",
    prefixIcon:
        Icon(Icons.search),
    border: InputBorder.none,
    contentPadding:
        EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 16,
    ),
  ),
),

                                                  ),
                    ),
                  ),
                ),
if (_predictions.isNotEmpty)
  Positioned(
    top: 85,
    left: 16,
    right: 16,
    child: Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 250,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _predictions.length,
          itemBuilder: (context, index) {

            final prediction =
                _predictions[index];

            return ListTile(
              leading: const Icon(
                Icons.location_on,
              ),
              title: Text(
                prediction["description"],
              ),
              onTap: () {

                _searchController.text =
                    prediction["description"];

                setState(() {
                  _predictions.clear();
                });

              },
            );

          },
        ),
      ),
    ),
  ),
                Align(
                  alignment:
                      Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      28,
                    ),
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Selected Location",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _selectedAddress,
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
  context,
  {
    "latitude": _cameraPosition.target.latitude,
    "longitude": _cameraPosition.target.longitude,
    "address": _selectedAddress,
    "house": _house,
    "street": _street,
    "area": _area,
    "city": _city,
    "state": _state,
    "pincode": _pincode,
  },
);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurple,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),
                            ),
                            child: const Text(
                              "Confirm Location",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}