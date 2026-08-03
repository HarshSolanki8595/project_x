import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777), // Mumbai
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project X Map"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: initialPosition,

        // Disable location for now.
        myLocationEnabled: false,
        myLocationButtonEnabled: false,

        zoomControlsEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: false,

        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}