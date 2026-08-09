import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place_prediction.dart';
import '../core/services/location_service.dart';
import '../core/services/places_service.dart';
import '../core/widgets/center_location_pin.dart';
import 'address_search_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color primaryBlue =
      Color(0xFF1557FF);

  static const Color lightBlue =
      Color(0xFFEEF3FF);

  static const Color background =
      Color(0xFFF7F8FC);

  static const Color textPrimary =
      Color(0xFF101828);

  static const Color textSecondary =
      Color(0xFF667085);

  GoogleMapController? _mapController;

  final LocationService _locationService =
      LocationService();

  final PlacesService _placesService =
      PlacesService();

  String _selectedAddress =
      "Fetching your location...";

  LatLng _selectedLatLng =
      const LatLng(19.0760, 72.8777);

  Map<String, String> _addressComponents = {};

  static const CameraPosition _initialPosition =
      CameraPosition(
    target: LatLng(
      19.0760,
      72.8777,
    ),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _moveToCurrentLocation();
  }

  Future<void> _moveToCurrentLocation() async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _updateAddress() async {
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
  }

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

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          _selectedLatLng,
          17,
        ),
      );

      await _updateAddress();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: textPrimary,
            size: 30,
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Text(
          "Select Service Address",
          style: TextStyle(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                _initialPosition,

            myLocationEnabled: true,
            myLocationButtonEnabled: false,

            compassEnabled: false,
            zoomControlsEnabled: false,

            onMapCreated: (controller) {
              _mapController = controller;
              _moveToCurrentLocation();
            },

            onCameraMove: (position) {
              _selectedLatLng =
                  position.target;
            },

            onCameraIdle: () {
              _updateAddress();
            },
          ),

          const CenterLocationPin(),

          // SEARCH
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _openSearch,
              child: Container(
                height: 68,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: primaryBlue,
                      size: 32,
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Text(
                        "Search address",
                        style: TextStyle(
                          color:
                              Color(0xFF98A2B3),
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.mic_none_rounded,
                      color: primaryBlue,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CURRENT LOCATION
          Positioned(
            right: 20,
            bottom: 245,
            child: Material(
              color: Colors.white,
              elevation: 5,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder:
                    const CircleBorder(),
                onTap: _moveToCurrentLocation,
                child: const Padding(
                  padding: EdgeInsets.all(17),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: primaryBlue,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // BOTTOM SHEET
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildAddressSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        28,
        18,
        28,
        28,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "Selected Address",
            style: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: primaryBlue,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  _selectedAddress,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    "address":
                        _selectedAddress,
                    "house":
                        _addressComponents[
                            "house"],
                    "street":
                        _addressComponents[
                            "street"],
                    "area":
                        _addressComponents[
                            "area"],
                    "city":
                        _addressComponents[
                            "city"],
                    "state":
                        _addressComponents[
                            "state"],
                    "pincode":
                        _addressComponents[
                            "pincode"],
                    "latitude":
                        _selectedLatLng
                            .latitude,
                    "longitude":
                        _selectedLatLng
                            .longitude,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Confirm Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}