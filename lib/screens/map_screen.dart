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
  static const Color primaryBlue = Color(0xFF1557FF);

  GoogleMapController? _mapController;

  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  String _selectedAddress = "Fetching your location...";

  LatLng _selectedLatLng = const LatLng(
    19.0760,
    72.8777,
  );

  static const CameraPosition _initialPosition =
      CameraPosition(
    target: LatLng(
      19.0760,
      72.8777,
    ),
    zoom: 14,
  );

  Map<String, String> _addressComponents = {};

  @override
  void initState() {
    super.initState();
    _moveToCurrentLocation();
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final Position position =
          await _locationService.getCurrentLocation();

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
        await _locationService.getAddressFromCoordinates(
      _selectedLatLng.latitude,
      _selectedLatLng.longitude,
    );

    final components =
        await _locationService.getAddressComponents(
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
        builder: (_) => const AddressSearchScreen(),
      ),
    );

    if (prediction == null) return;

    try {
      final location =
          await _placesService.getPlaceLocation(
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
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
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
          GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,

            onMapCreated: (controller) {
              _mapController = controller;
              _moveToCurrentLocation();
            },

            onCameraMove: (position) {
              _selectedLatLng = position.target;
            },

            onCameraIdle: () {
              _updateAddress();
            },
          ),

          const CenterLocationPin(),

          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: AddressSearchBar(
              onTap: _openSearch,
            ),
          ),

          Positioned(
            right: 20,
            bottom: 210,
            child: Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _moveToCurrentLocation,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomSheet: AddressBottomSheet(
        address: _selectedAddress,
        onConfirm: () {
          Navigator.pop(
            context,
            {
              "address": _selectedAddress,
              "house": _addressComponents["house"],
              "street": _addressComponents["street"],
              "area": _addressComponents["area"],
              "city": _addressComponents["city"],
              "state": _addressComponents["state"],
              "pincode": _addressComponents["pincode"],
              "latitude": _selectedLatLng.latitude,
              "longitude": _selectedLatLng.longitude,
            },
          );
        },
      ),
    );
  }
}
