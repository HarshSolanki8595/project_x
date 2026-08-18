import 'dart:io';

class ServiceRequest {
  // ============================================================
  // REQUEST ID GENERATOR
  // ============================================================

  static int _requestCounter = 1;

  static String _generateRequestId() {
    final id =
        'REQ_${_requestCounter.toString().padLeft(6, '0')}';

    _requestCounter++;

    return id;
  }

  // ============================================================
  // CUSTOMER REQUEST INFORMATION
  // ============================================================

  String categoryName;
  String subCategoryName;
  String issueDescription;
  bool isEmergency;

  // ============================================================
  // MEDIA
  // ============================================================

  List<File> photos;
  File? video;

  // ============================================================
  // LOCATION / SCHEDULE
  // ============================================================

  String? address;
  double? latitude;
  double? longitude;

  DateTime? preferredDate;
  String? preferredTimeSlot;

  // ============================================================
  // MARKETPLACE IDENTIFIERS
  // ============================================================

  String? requestId;
  String? requestTypeId;
  String? capabilityId;
  String? categoryId;

  // ============================================================
  // CUSTOMER
  // ============================================================

  String? customerId;

  // ============================================================
  // URGENCY
  // ============================================================

  String urgency;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ServiceRequest({
    required this.categoryName,
    required this.subCategoryName,
    required this.issueDescription,
    required this.isEmergency,
    this.photos = const [],
    this.video,
    this.address,
    this.latitude,
    this.longitude,
    this.preferredDate,
    this.preferredTimeSlot,
    String? requestId,
    this.requestTypeId,
    this.capabilityId,
    this.categoryId,
    this.customerId,
    this.urgency = 'NORMAL',
  }) : requestId = requestId ?? _generateRequestId();

  // ============================================================
  // COPY WITH
  // ============================================================

  ServiceRequest copyWith({
    String? categoryName,
    String? subCategoryName,
    String? issueDescription,
    bool? isEmergency,
    List<File>? photos,
    File? video,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? preferredDate,
    String? preferredTimeSlot,
    String? requestId,
    String? requestTypeId,
    String? capabilityId,
    String? categoryId,
    String? customerId,
    String? urgency,
  }) {
    return ServiceRequest(
      categoryName:
          categoryName ?? this.categoryName,

      subCategoryName:
          subCategoryName ?? this.subCategoryName,

      issueDescription:
          issueDescription ?? this.issueDescription,

      isEmergency:
          isEmergency ?? this.isEmergency,

      photos:
          photos ?? this.photos,

      video:
          video ?? this.video,

      address:
          address ?? this.address,

      latitude:
          latitude ?? this.latitude,

      longitude:
          longitude ?? this.longitude,

      preferredDate:
          preferredDate ?? this.preferredDate,

      preferredTimeSlot:
          preferredTimeSlot ?? this.preferredTimeSlot,

      // IMPORTANT:
      // Preserve the existing request ID.
      requestId:
          requestId ?? this.requestId,

      requestTypeId:
          requestTypeId ?? this.requestTypeId,

      capabilityId:
          capabilityId ?? this.capabilityId,

      categoryId:
          categoryId ?? this.categoryId,

      customerId:
          customerId ?? this.customerId,

      urgency:
          urgency ?? this.urgency,
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'issueDescription': issueDescription,
      'isEmergency': isEmergency,

      'address': address,
      'latitude': latitude,
      'longitude': longitude,

      'preferredDate':
          preferredDate?.millisecondsSinceEpoch,

      'preferredTimeSlot':
          preferredTimeSlot,

      'requestId':
          requestId,

      'requestTypeId':
          requestTypeId,

      'capabilityId':
          capabilityId,

      'categoryId':
          categoryId,

      'customerId':
          customerId,

      'urgency':
          urgency,

      // Firebase Storage URLs will be added later.
      'photos': <String>[],

      'video': null,
    };
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory ServiceRequest.fromMap(
    Map<String, dynamic> map,
  ) {
    return ServiceRequest(
      categoryName:
          map['categoryName'] ?? '',

      subCategoryName:
          map['subCategoryName'] ?? '',

      issueDescription:
          map['issueDescription'] ?? '',

      isEmergency:
          map['isEmergency'] ?? false,

      address:
          map['address'],

      latitude:
          map['latitude'] == null
              ? null
              : (map['latitude'] as num).toDouble(),

      longitude:
          map['longitude'] == null
              ? null
              : (map['longitude'] as num).toDouble(),

      preferredDate:
          map['preferredDate'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  map['preferredDate'],
                ),

      preferredTimeSlot:
          map['preferredTimeSlot'],

      requestId:
          map['requestId'],

      requestTypeId:
          map['requestTypeId'],

      capabilityId:
          map['capabilityId'],

      categoryId:
          map['categoryId'],

      customerId:
          map['customerId'],

      urgency:
          map['urgency'] ?? 'NORMAL',

      photos: [],

      video: null,
    );
  }
}