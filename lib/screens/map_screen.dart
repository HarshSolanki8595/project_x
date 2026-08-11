import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place_prediction.dart';
import '../core/services/location_service.dart';
import '../core/services/places_service.dart';
import '../core/widgets/address_bottom_sheet.dart';
import '../core/widgets/address_search_bar.dart';
import '../core/widgets/center_location_pin.dart';
import 'address_search_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ============================================================
  // DESIGN SYSTEM
  // ============================================================

  static const Color primaryBlue =
      Color(0xFF1557FF);

  static const Color lightBlue =
      Color(0xFFEEF3FF);

  static const Color textPrimary =
      Color(0xFF0F172A);

  static const Color textSecondary =
      Color(0xFF64748B);

  // ============================================================
  // MAP
  // ============================================================

  GoogleMapController? _mapController;

  final LocationService _locationService =
      LocationService();

  final PlacesService _placesService =
      PlacesService();

  String _selectedAddress =
      "Fetching your location...";

  LatLng _selectedLatLng =
      const LatLng(
    19.0760,
    72.8777,
  );

  static const CameraPosition
      _initialPosition =
      CameraPosition(
    target: LatLng(
      19.0760,
      72.8777,
    ),
    zoom: 14,
  );

  Map<String, String>
      _addressComponents = {};

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _moveToCurrentLocation();
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void>
      _moveToCurrentLocation() async {
    try {
      final Position position =
          await _locationService
              .getCurrentLocation();

      _selectedLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            _selectedLatLng,
            17,
          ),
        );
      }

      await _updateAddress();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // ============================================================
  // REVERSE GEOCODING
  // ============================================================

  Future<void> _updateAddress() async {
    try {
      final address =
          await _locationService
              .getAddressFromCoordinates(
        _selectedLatLng.latitude,
        _selectedLatLng.longitude,
      );

      final components =
          await _locationService
              .getAddressComponents(
        _selectedLatLng.latitude,
        _selectedLatLng.longitude,
      );

      if (!mounted) return;

      setState(() {
        _selectedAddress = address;
        _addressComponents = components;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _selectedAddress =
            "Unable to determine address";
      });
    }
  }

  // ============================================================
  // ADDRESS SEARCH
  // ============================================================

  Future<void> _openSearch() async {
    final PlacePrediction? prediction =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddressSearchScreen(),
      ),
    );

    if (prediction == null) return;

    try {
      final location =
          await _placesService
              .getPlaceLocation(
        prediction.placeId,
      );

      _selectedLatLng = LatLng(
        location["lat"]!,
        location["lng"]!,
      );

      await _mapController
          ?.animateCamera(
        CameraUpdate.newLatLngZoom(
          _selectedLatLng,
          17,
        ),
      );

      await _updateAddress();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // ============================================================
  // CONFIRM LOCATION
  // ============================================================

  void _confirmLocation() {
    Navigator.pop(
      context,
      {
        "address": _selectedAddress,
        "house":
            _addressComponents["house"],
        "street":
            _addressComponents["street"],
        "area":
            _addressComponents["area"],
        "city":
            _addressComponents["city"],
        "state":
            _addressComponents["state"],
        "pincode":
            _addressComponents["pincode"],
        "latitude":
            _selectedLatLng.latitude,
        "longitude":
            _selectedLatLng.longitude,
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 27,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Select Service Address",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Stack(
        children: [
          // ========================================================
          // MAP
          // ========================================================

          GoogleMap(
            initialCameraPosition:
                _initialPosition,

            myLocationEnabled: true,
            myLocationButtonEnabled:
                false,

            compassEnabled: true,
            zoomControlsEnabled: false,

            onMapCreated:
                (controller) {
              _mapController =
                  controller;

              _moveToCurrentLocation();
            },

            onCameraMove:
                (position) {
              _selectedLatLng =
                  position.target;
            },

            onCameraIdle:
                () {
              _updateAddress();
            },
          ),

          // ========================================================
          // CENTER PIN
          // ========================================================

          const CenterLocationPin(),

          // ========================================================
          // SEARCH
          // ========================================================

          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: AddressSearchBar(
              onTap: _openSearch,
            ),
          ),

          // ========================================================
          // CURRENT LOCATION BUTTON
          // ========================================================

          Positioned(
            right: 16,
            bottom: 196,
            child: Material(
              color: Colors.white,
              elevation: 3,
              shadowColor:
                  Colors.black26,
              shape:
                  const CircleBorder(),
              child: InkWell(
                customBorder:
                    const CircleBorder(),
                onTap:
                    _moveToCurrentLocation,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons.my_location_rounded,
                    color:
                        primaryBlue,
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ==========================================================
      // COMPACT ADDRESS BOTTOM SHEET
      // ==========================================================

      bottomSheet: Material(
        color: Colors.white,
        elevation: 10,

        borderRadius:
            const BorderRadius.vertical(
          top: Radius.circular(24),
        ),

        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              9,
              20,
              14,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ====================================================
                // HANDLE
                // ====================================================

                Center(
                  child: Container(
                    height: 4,
                    width: 38,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFD1D5DB,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ====================================================
                // TITLE
                // ====================================================

                const Text(
                  "Selected Address",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing:
                        -0.3,
                  ),
                ),

                const SizedBox(height: 9),

                // ====================================================
                // ADDRESS
                // ====================================================

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: lightBlue,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .location_on_rounded,
                          color:
                              primaryBlue,
                          size: 22,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          _selectedAddress,
                          maxLines: 3,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                textPrimary,
                            fontSize: 13.5,
                            height: 1.35,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 11),

                // ====================================================
                // CONFIRM
                // ====================================================

                SizedBox(
                  width:
                      double.infinity,
                  height: 54,
                  child:
                      ElevatedButton(
                    onPressed:
                        _confirmLocation,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryBlue,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                      ),
                    ),

                    child:
                        const Text(
                      "Confirm Location",
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}