class ServiceRequestModel {
  final String requestId;
  final String customerId;

  // Specific problem/request identified by Project X.
  final String requestTypeId;

  // Broad capability required to handle the request.
  final String capabilityId;

  // Main category the capability belongs to (e.g. "appliances").
  // Used as a fallback match when no professional's subcategoryIds
  // exactly contains capabilityId, so a customer request isn't
  // dropped just because the professional described their trade
  // slightly differently.
  final String categoryId;

  final String description;

  final double latitude;
  final double longitude;

  final String urgency;
  final String status;

  final DateTime createdAt;

  // ============================================================
  // DISPLAY / SCHEDULE FIELDS
  // Added 2026-09-08 -- these were already being collected on the
  // customer app's booking flow (FixedPriceRequestScreen sets
  // categoryName/subCategoryName, AddressScreen sets address,
  // DateTimeScreen sets preferredDate/preferredTimeSlot -- all on
  // the ServiceRequest object in lib/models/service_request.dart)
  // but were never forwarded into this model or written to
  // Firestore, so the professional app's request card had nothing
  // to show beyond the generic "Service Request" title and posted
  // price. See RequestService.createRequest and
  // RequestRepository.addRequest for the other half of this fix.
  // ============================================================

  final String? categoryName;
  final String? subCategoryName;
  final String? address;
  final DateTime? preferredDate;
  final String? preferredTimeSlot;

  // ============================================================
  // FIXED-PRICE PRICING MODEL (Helper Services + Cleaning only)
  // Added 2026-09-02 -- see fixed_price_service_config.dart and
  // ServiceRequest (lib/models/service_request.dart) for the
  // full explanation. 'BID' default keeps every other category's
  // existing request document shape unchanged.
  // ============================================================

  final String pricingType;
  final Map<String, dynamic> fixedPriceAnswers;
  final int? numberOfServiceRecipients;
  final double? serviceDurationHours;
  final double? computedFairPrice;
  final double? postedPrice;

  // ============================================================
  // MATERIAL SOURCING (non-Quick-Service requests only)
  // Added 2026-09-04 -- mirrors the same fields on ServiceRequest
  // (lib/models/service_request.dart). See that file for the full
  // explanation. All null on FIXED_PRICE / older requests.
  // ============================================================

  final bool? customerProvidesMaterial;
  final String? materialGrade;
  final String? materialBrandPreference;

  const ServiceRequestModel({
    required this.requestId,
    required this.customerId,
    required this.requestTypeId,
    required this.capabilityId,
    this.categoryId = '',
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.urgency,
    required this.status,
    required this.createdAt,
    this.categoryName,
    this.subCategoryName,
    this.address,
    this.preferredDate,
    this.preferredTimeSlot,
    this.pricingType = 'BID',
    this.fixedPriceAnswers = const {},
    this.numberOfServiceRecipients,
    this.serviceDurationHours,
    this.computedFairPrice,
    this.postedPrice,
    this.customerProvidesMaterial,
    this.materialGrade,
    this.materialBrandPreference,
  });
}