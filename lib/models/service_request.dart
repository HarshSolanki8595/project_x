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
  // FIXED-PRICE PRICING MODEL (Helper Services + Cleaning only)
  // Added 2026-09-02 -- see fixed_price_service_config.dart.
  // ============================================================
  //
  // pricingType is 'BID' for every other category (default, so
  // nothing about the existing professional-quoted flow changes)
  // or 'FIXED_PRICE' for Helper Services/Cleaning requests, where
  // the customer posts a price up front instead of collecting bids.
  //

  String pricingType;

  // Answers to the predefined pricing questions for this request's
  // subcategory -- currently just {'hours': ..., 'recipients': ...},
  // kept as a map so future subcategory-specific questions can be
  // added without another model change.
  Map<String, dynamic> fixedPriceAnswers;

  int? numberOfServiceRecipients;
  double? serviceDurationHours;

  // The system-computed fair price from FixedPriceSubCategoryConfig,
  // for the answers above.
  double? computedFairPrice;

  // What the customer actually posts the request at -- starts equal
  // to computedFairPrice (auto-filled), can be edited down (triggers
  // the below-floor warning) or raised later via the raise-price flow.
  double? postedPrice;

  // ============================================================
  // MATERIAL SOURCING (non-Quick-Service requests only)
  // Added 2026-09-04 -- ServiceRequestScreen is only ever used for
  // BID-priced requests (Quick Services / FIXED_PRICE goes through
  // FixedPriceRequestScreen instead -- see subcategory_screen.dart),
  // so these fields only ever get set there.
  // ============================================================
  //
  // null until the customer makes a choice (mandatory before they
  // can continue) -- true: customer brings their own material, so
  // the professional's Materials Cost field is grayed out/locked to
  // ₹0 on their side; false: professional sources it, in which case
  // materialGrade is mandatory (customer picks it on this screen)
  // and materialBrandPreference is an optional free-text hint.
  //

  bool? customerProvidesMaterial;
  String? materialGrade;
  String? materialBrandPreference;

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
    this.pricingType = 'BID',
    this.fixedPriceAnswers = const {},
    this.numberOfServiceRecipients,
    this.serviceDurationHours,
    this.computedFairPrice,
    this.postedPrice,
    this.customerProvidesMaterial,
    this.materialGrade,
    this.materialBrandPreference,
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
    String? pricingType,
    Map<String, dynamic>? fixedPriceAnswers,
    int? numberOfServiceRecipients,
    double? serviceDurationHours,
    double? computedFairPrice,
    double? postedPrice,
    bool? customerProvidesMaterial,
    String? materialGrade,
    String? materialBrandPreference,
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

      pricingType:
          pricingType ?? this.pricingType,

      fixedPriceAnswers:
          fixedPriceAnswers ?? this.fixedPriceAnswers,

      numberOfServiceRecipients:
          numberOfServiceRecipients ?? this.numberOfServiceRecipients,

      serviceDurationHours:
          serviceDurationHours ?? this.serviceDurationHours,

      computedFairPrice:
          computedFairPrice ?? this.computedFairPrice,

      postedPrice:
          postedPrice ?? this.postedPrice,

      customerProvidesMaterial:
          customerProvidesMaterial ?? this.customerProvidesMaterial,

      materialGrade:
          materialGrade ?? this.materialGrade,

      materialBrandPreference:
          materialBrandPreference ?? this.materialBrandPreference,
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

      'pricingType':
          pricingType,

      'fixedPriceAnswers':
          fixedPriceAnswers,

      'numberOfServiceRecipients':
          numberOfServiceRecipients,

      'serviceDurationHours':
          serviceDurationHours,

      'computedFairPrice':
          computedFairPrice,

      'postedPrice':
          postedPrice,

      'customerProvidesMaterial':
          customerProvidesMaterial,

      'materialGrade':
          materialGrade,

      'materialBrandPreference':
          materialBrandPreference,

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

      pricingType:
          map['pricingType'] ?? 'BID',

      fixedPriceAnswers:
          map['fixedPriceAnswers'] == null
              ? const {}
              : Map<String, dynamic>.from(
                  map['fixedPriceAnswers'],
                ),

      numberOfServiceRecipients:
          map['numberOfServiceRecipients'] == null
              ? null
              : (map['numberOfServiceRecipients'] as num).toInt(),

      serviceDurationHours:
          map['serviceDurationHours'] == null
              ? null
              : (map['serviceDurationHours'] as num).toDouble(),

      computedFairPrice:
          map['computedFairPrice'] == null
              ? null
              : (map['computedFairPrice'] as num).toDouble(),

      postedPrice:
          map['postedPrice'] == null
              ? null
              : (map['postedPrice'] as num).toDouble(),

      customerProvidesMaterial:
          map['customerProvidesMaterial'] as bool?,

      materialGrade:
          map['materialGrade'] as String?,

      materialBrandPreference:
          map['materialBrandPreference'] as String?,

      photos: [],

      video: null,
    );
  }
}