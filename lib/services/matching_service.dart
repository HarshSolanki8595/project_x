import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';
import 'opportunity_service.dart';

class MatchingService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // FALLBACK RADIUS
  // ============================================================
  //
  // Used only for professionals who don't have a serviceRadiusKm
  // value stored yet (older profiles / not set during onboarding).
  //
  static const double defaultRadiusKm = 15.0;

  // ============================================================
  // MATCH REQUEST
  // ============================================================
  //
  // Real Firestore-backed matching. Ported from the professional
  // app's MatchingService (which was correct but never wired up to
  // the customer app's request-submission flow — this is what was
  // causing new requests to never reach any professional).
  //
  // Eligibility:
  //
  // 1. Professional has the exact required capability
  //    (subcategoryIds arrayContains request.capabilityId)
  // 2. Professional is verified
  // 3. Professional is active
  // 4. Professional is available
  // 5. Customer is within the professional's own service radius
  //
  // Only matched professionals receive an opportunity, written to:
  //
  //   professional_opportunities/{firebaseUid}/requests/{requestId}
  //
  // ============================================================

  static Future<List<String>> matchRequest(
    ServiceRequestModel request,
  ) async {
    final String capabilityId =
        request.capabilityId.trim();

    if (capabilityId.isEmpty) {
      return [];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('professionals')
            .where(
              'subcategoryIds',
              arrayContains: capabilityId,
            )
            .get();

    final List<String> matchedProfessionalIds = [];

    for (final document in snapshot.docs) {
      final Map<String, dynamic> data = document.data();

      final bool isVerified =
          data['isVerified'] as bool? ?? false;

      if (!isVerified) {
        continue;
      }

      final bool isActive =
          data['isActive'] as bool? ?? false;

      if (!isActive) {
        continue;
      }

      final bool isAvailable =
          data['isAvailable'] as bool? ?? false;

      if (!isAvailable) {
        continue;
      }

      final String professionalId =
          data['professionalId'] as String? ?? document.id;

      if (professionalId.trim().isEmpty) {
        continue;
      }

      final double professionalLatitude =
          (data['latitude'] as num?)?.toDouble() ?? 0.0;

      final double professionalLongitude =
          (data['longitude'] as num?)?.toDouble() ?? 0.0;

      final double serviceRadiusKm =
          (data['serviceRadiusKm'] as num?)?.toDouble() ??
              defaultRadiusKm;

      final bool locationEligible = _isLocationEligible(
        requestLatitude: request.latitude,
        requestLongitude: request.longitude,
        professionalLatitude: professionalLatitude,
        professionalLongitude: professionalLongitude,
        radiusKm: serviceRadiusKm,
      );

      if (!locationEligible) {
        continue;
      }

      matchedProfessionalIds.add(professionalId);
    }

    if (matchedProfessionalIds.isNotEmpty) {
      await OpportunityService.createForMatchedProfessionals(
        requestId: request.requestId,
        professionalIds: matchedProfessionalIds,
      );
    }

    return matchedProfessionalIds;
  }

  // ============================================================
  // LOCATION ELIGIBILITY
  // ============================================================

  static bool _isLocationEligible({
    required double requestLatitude,
    required double requestLongitude,
    required double professionalLatitude,
    required double professionalLongitude,
    required double radiusKm,
  }) {
    // A professional without a valid stored location cannot be
    // considered location eligible.
    if (professionalLatitude == 0.0 &&
        professionalLongitude == 0.0) {
      return false;
    }

    if (requestLatitude == 0.0 && requestLongitude == 0.0) {
      return false;
    }

    final double distanceKm = _calculateDistanceInKm(
      requestLatitude,
      requestLongitude,
      professionalLatitude,
      professionalLongitude,
    );

    return distanceKm <= radiusKm;
  }

  // ============================================================
  // HAVERSINE DISTANCE (km)
  // ============================================================

  static double _calculateDistanceInKm(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double latitudeDifference =
        _degreesToRadians(latitude2 - latitude1);

    final double longitudeDifference =
        _degreesToRadians(longitude2 - longitude1);

    final double latitude1Radians =
        _degreesToRadians(latitude1);

    final double latitude2Radians =
        _degreesToRadians(latitude2);

    final double a = math.pow(
          math.sin(latitudeDifference / 2),
          2,
        ) +
        math.cos(latitude1Radians) *
            math.cos(latitude2Radians) *
            math.pow(
              math.sin(longitudeDifference / 2),
              2,
            );

    final double c =
        2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}
