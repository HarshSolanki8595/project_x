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

  // ============================================================
  // EMERGENCY FLAG (added 2026-09-27 -- urgency wiring fix)
  // ============================================================
  // The REAL urgency flag, set via the customer app's "Need urgent
  // help?" toggle on ServiceRequestScreen (ServiceRequest.isEmergency
  // there). `urgency` above is a separate, legacy field that's never
  // actually updated from that toggle -- it stays at its 'NORMAL'
  // default regardless -- so it was never a reliable urgency signal.
  // The professional app's opportunity/bid/request-details screens
  // already read `isEmergency` (mirrors this same field there); this
  // was simply never being written from the customer app's create-
  // request path until now.
  // ============================================================

  final bool isEmergency;

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

  // ============================================================
  // APPLIANCES / AUTOMOBILE NARROWER MATCHING (added 2026-10-02)
  // Mirrors SubCategory.matchGroup (lib/models/subcategory.dart) --
  // see that file for the full explanation. Set from the chosen
  // subcategory's matchGroup at request-creation time (see
  // RequestService.createRequest / RequestRepository.addRequest),
  // and read by the Cloud Function's fallback-matching tier so an
  // Appliances/Automobile request only falls back to professionals
  // covering the same real-world trade family, not the whole
  // category. Null for every other category -- their fallback is
  // unchanged.
  final String? matchGroup;

  // Only meaningful for the handful of Automobile subcategories
  // tagged matchGroup: 'both' (vehicle-agnostic items like Battery
  // Service or Tyre & Puncture) -- for those, the subcategory id
  // alone can't tell a car job from a bike job, so the customer is
  // asked directly on ServiceRequestScreen. 'car' or 'bike'; null
  // for every other subcategory/category, where the subcategory
  // itself already says which vehicle (or isn't Automobile at all).
  final String? vehicleType;

  // ============================================================
  // MEDIA (added 2026-10-02)
  // ============================================================
  //
  // Firebase Storage download URLs for the photos/video/voice note
  // the customer attached on ServiceRequestScreen. Previously these
  // were collected as local Files on ServiceRequest
  // (lib/models/service_request.dart) but never actually uploaded
  // anywhere -- toMap() there hardcoded empty/null. Now uploaded by
  // ServiceRequestMediaService at request-creation time (see
  // RequestService.createRequest) and the resulting URLs are stored
  // here, the real Firestore-backed model. All null/empty for a
  // request with no media attached, and for any request created
  // before this existed.
  // ============================================================

  final List<String> photoUrls;
  final String? videoUrl;
  final String? voiceNoteUrl;

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
    this.isEmergency = false,
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
    this.matchGroup,
    this.vehicleType,
    this.photoUrls = const [],
    this.videoUrl,
    this.voiceNoteUrl,
  });
}