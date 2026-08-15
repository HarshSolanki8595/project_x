import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String label;

  final String houseNo;
  final String building;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String landmark;

  final bool isDefault;
  final DateTime createdAt;

  // ------------------------------------------------------------
  // SERVICE LOCATION
  // ------------------------------------------------------------

  final double? latitude;
  final double? longitude;

  const Address({
    required this.id,
    required this.label,
    required this.houseNo,
    required this.building,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    required this.landmark,
    required this.isDefault,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  // ------------------------------------------------------------
  // FULL ADDRESS
  // ------------------------------------------------------------

  String get fullAddress {
    final parts = <String>[
      houseNo,
      building,
      street,
      area,
      city,
      state,
      pincode,
    ].where((value) => value.trim().isNotEmpty).toList();

    return parts.join(', ');
  }

  // ------------------------------------------------------------
  // FIRESTORE MAP
  // ------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'houseNo': houseNo,
      'building': building,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),

      // Location used for professional matching.
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // ------------------------------------------------------------
  // FIRESTORE → MODEL
  // ------------------------------------------------------------

  factory Address.fromMap(
    Map<String, dynamic> map,
  ) {
    return Address(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? 'Home',

      houseNo:
          map['houseNo'] as String? ?? '',

      building:
          map['building'] as String? ?? '',

      street:
          map['street'] as String? ?? '',

      area:
          map['area'] as String? ?? '',

      city:
          map['city'] as String? ?? '',

      state:
          map['state'] as String? ?? '',

      pincode:
          map['pincode'] as String? ?? '',

      landmark:
          map['landmark'] as String? ?? '',

      isDefault:
          map['isDefault'] as bool? ?? false,

      createdAt:
          _readDate(map['createdAt']),

      latitude:
          (map['latitude'] as num?)?.toDouble(),

      longitude:
          (map['longitude'] as num?)?.toDouble(),
    );
  }

  // ------------------------------------------------------------
  // SAFE DATE READER
  // ------------------------------------------------------------

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}