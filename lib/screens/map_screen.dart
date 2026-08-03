import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../core/services/location_service.dart';
import '../core/widgets/address_bottom_sheet.dart';
import '../core/widgets/center_location_pin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  final LocationService _locationService = LocationService();

  String _selectedAddress = "Fetching your location...";

  LatLng _selectedLatLng = const LatLng(
    19.0760,
    72.8777,
  );

  static const CameraPosition _initialPosition = CameraPosition(
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
      Position position =
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

    if (!mounted) return;

    setState(() {
      _selectedAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Service Address"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,

            myLocationEnabled: true,
            myLocationButtonEnabled: true,

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
        ],
      ),

      bottomSheet: AddressBottomSheet(
        address: _selectedAddress,
        onConfirm: () {
          Navigator.pop(
            context,
            {
              "address": _selectedAddress,
              "latitude": _selectedLatLng.latitude,
              "longitude": _selectedLatLng.longitude,
            },
          );
        },
      ),
    );
  }
}