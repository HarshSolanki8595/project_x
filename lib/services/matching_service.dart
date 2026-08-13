import 'dart:math';

import '../data/professional_data.dart';
import '../models/professional_model.dart';
import '../models/service_request_model.dart';

class MatchingService {
  // ============================================================
  // MAIN MATCHING ENTRY POINT
  // ============================================================
  //
  // This is the method that the rest of Project X will eventually
  // call when a customer creates a service request.
  //
  // Request
  //    ↓
  // MatchingService
  //    ↓
  // Eligible Professionals
  //
  static List<ProfessionalModel> matchRequest(
    ServiceRequestModel request,
  ) {
    return findEligibleProfessionals(request);
  }

  // ============================================================
  // FIND ELIGIBLE PROFESSIONALS
  // ============================================================
  //
  // A professional is eligible only when ALL conditions pass:
  //
  // 1. Required capability matches
  // 2. Professional is verified
  // 3. Professional account is active
  // 4. Professional is available
  // 5. Customer is within professional's service radius
  //
  static List<ProfessionalModel> findEligibleProfessionals(
    ServiceRequestModel request,
  ) {
    final List<ProfessionalModel> eligibleProfessionals = [];

    for (final professional in ProfessionalData.professionals) {
      // --------------------------------------------------------
      // 1. CAPABILITY MATCH
      // --------------------------------------------------------
      //
      // The professional does NOT need the exact request type.
      //
      // Example:
      //
      // Customer request:
      // AC_REPAIR_NOT_COOLING
      //
      // Required capability:
      // AC_REPAIR
      //
      // Professional capability:
      // AC_REPAIR
      //
      // Result:
      // MATCH
      //

      if (!professional.capabilityIds.contains(
        request.capabilityId,
      )) {
        continue;
      }

      // --------------------------------------------------------
      // 2. PROFESSIONAL MUST BE VERIFIED
      // --------------------------------------------------------

      if (!professional.isVerified) {
        continue;
      }

      // --------------------------------------------------------
      // 3. PROFESSIONAL ACCOUNT MUST BE ACTIVE
      // --------------------------------------------------------

      if (!professional.isActive) {
        continue;
      }

      // --------------------------------------------------------
      // 4. PROFESSIONAL MUST BE AVAILABLE
      // --------------------------------------------------------

      if (!professional.isAvailable) {
        continue;
      }

      // --------------------------------------------------------
      // 5. CUSTOMER MUST BE WITHIN SERVICE RADIUS
      // --------------------------------------------------------

      final double distance = calculateDistanceInKm(
        request.latitude,
        request.longitude,
        professional.latitude,
        professional.longitude,
      );

      if (distance > professional.serviceRadiusKm) {
        continue;
      }

      // --------------------------------------------------------
      // ALL CONDITIONS PASSED
      // --------------------------------------------------------

      eligibleProfessionals.add(professional);
    }

    return eligibleProfessionals;
  }

  // ============================================================
  // CALCULATE DISTANCE BETWEEN CUSTOMER AND PROFESSIONAL
  // ============================================================
  //
  // Uses the Haversine formula to calculate approximate
  // distance between two latitude/longitude coordinates.
  //
  static double calculateDistanceInKm(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double lat1 = _degreesToRadians(latitude1);
    final double lat2 = _degreesToRadians(latitude2);

    final double deltaLat =
        _degreesToRadians(latitude2 - latitude1);

    final double deltaLon =
        _degreesToRadians(longitude2 - longitude1);

    final double a =
        pow(sin(deltaLat / 2), 2) +
        cos(lat1) *
            cos(lat2) *
            pow(sin(deltaLon / 2), 2);

    final double c =
        2 * atan2(
          sqrt(a),
          sqrt(1 - a),
        );

    return earthRadiusKm * c;
  }

  // ============================================================
  // CONVERT DEGREES TO RADIANS
  // ============================================================

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}