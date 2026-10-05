import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// ================================================================
// SERVICE AREA SERVICE (NEW — 2026-10-05)
// ================================================================
//
// Habio is only live in the cities an admin has switched on (admin
// panel > Cities). Before a customer's address is accepted for a
// request, AddressScreen asks this service whether the address is
// inside a live city.
//
// A city (cities/{cityId}) is one or more areas, each either:
//   BOX    {minLat, maxLat, minLng, maxLng}
//   CIRCLE {lat, lng, radiusKm}
// A point is inside the city if it is inside any area. This is the
// same geometry the Cloud Function uses to decide who is offered a
// request (functions/index.js, serviceAreaGate), so what the customer
// is told matches what the server will do.
//
// FAILS OPEN: while no city exists, or if the cities cannot be read,
// the check allows the address -- the server-side check is the
// authority, and a customer is never blocked by a read problem.
//

class ServiceAreaResult {
  final bool allowed;
  final String message;

  const ServiceAreaResult({required this.allowed, this.message = ''});

  static const ServiceAreaResult open = ServiceAreaResult(allowed: true);
}

class ServiceAreaService {
  static const String _defaultMessage =
      "We're not in your area yet. We're adding new areas soon.";

  static Future<ServiceAreaResult> check(double lat, double lng) async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('cities').get();

      if (snap.docs.isEmpty) return ServiceAreaResult.open;

      String? firstNote;

      for (final doc in snap.docs) {
        final data = doc.data();
        final note = (data['launchNote'] as String?)?.trim() ?? '';
        if (firstNote == null && note.isNotEmpty) firstNote = note;

        if (data['active'] != true) continue;

        final areas = data['areas'];
        if (areas is! List) continue;

        for (final area in areas) {
          if (area is Map && _inArea(Map<String, dynamic>.from(area), lat, lng)) {
            return ServiceAreaResult.open;
          }
        }
      }

      return ServiceAreaResult(
        allowed: false,
        message: firstNote ?? _defaultMessage,
      );
    } catch (_) {
      return ServiceAreaResult.open;
    }
  }

  /// Records the customer on the waitlist (admin panel > Cities >
  /// Waitlist). Returns false if it could not be saved.
  static Future<bool> joinWaitlist({
    required double lat,
    required double lng,
    String cityHint = '',
    String areaHint = '',
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('joinCityWaitlist').call({
        'latitude': lat,
        'longitude': lng,
        'cityHint': cityHint,
        'areaHint': areaHint,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool _inArea(Map<String, dynamic> area, double lat, double lng) {
    double n(String key) => (area[key] as num?)?.toDouble() ?? double.nan;

    if (area['kind'] == 'BOX') {
      return lat >= n('minLat') &&
          lat <= n('maxLat') &&
          lng >= n('minLng') &&
          lng <= n('maxLng');
    }

    if (area['kind'] == 'CIRCLE') {
      return _distanceKm(lat, lng, n('lat'), n('lng')) <= n('radiusKm');
    }

    return false;
  }

  static double _distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    double rad(double d) => d * math.pi / 180;

    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
