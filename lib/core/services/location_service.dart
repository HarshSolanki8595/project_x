import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        "Please enable Location Services.",
      );
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        "Location permission denied.",
      );
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw Exception(
        "Location permission permanently denied.",
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return "Unknown location";
      }

      final place = placemarks.first;

      final address = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.postalCode,
      ]
          .where(
            (element) =>
                element != null &&
                element.toString().trim().isNotEmpty,
          )
          .join(", ");

      return address;
    } catch (_) {
      return "Unable to fetch address";
    }
  }

  Future<Map<String, String>> getAddressComponents(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return {};
      }

      final place = placemarks.first;

      return {
        "house": place.name ?? "",
        "street": place.street ?? "",
        "area": place.subLocality ?? "",
        "city": place.locality ?? "",
        "state": place.administrativeArea ?? "",
        "pincode": place.postalCode ?? "",
      };
    } catch (_) {
      return {};
    }
  }
}