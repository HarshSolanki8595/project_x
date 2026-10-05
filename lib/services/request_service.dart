import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';
import 'request_repository.dart';
import 'service_request_media_service.dart';

class RequestService {
  // ============================================================
  // NOTE ON REQUEST ID GENERATION
  // ============================================================
  //
  // The previous implementation used a local, in-memory counter
  // (`_requestCounter`) to build IDs like REQ_000001. That counter
  // resets to 1 every time the app restarts and is not shared
  // across devices or users, so two different customers (or the
  // same customer across two sessions) could generate the SAME
  // requestId. Since Firestore writes to a specific document ID
  // silently overwrite whatever was there before, this could
  // cause one customer's request to overwrite another's.
  //
  // This version uses Firestore's own collision-proof auto-ID
  // instead, which is guaranteed unique.
  //

  static Future<ServiceRequestModel> createRequest({
    required String customerId,
    required String requestTypeId,
    required String capabilityId,
    String categoryId = '',
    required String description,
    required double latitude,
    required double longitude,
    String urgency = 'NORMAL',
    bool isEmergency = false,
    String? categoryName,
    String? subCategoryName,
    String? address,
    DateTime? preferredDate,
    String? preferredTimeSlot,
    String pricingType = 'BID',
    Map<String, dynamic> fixedPriceAnswers = const {},
    int? numberOfServiceRecipients,
    double? serviceDurationHours,
    double? computedFairPrice,
    double? postedPrice,
    bool? customerProvidesMaterial,
    String? materialGrade,
    String? materialBrandPreference,
    String? matchGroup,
    String? vehicleType,
    // ----------------------------------------------------------
    // MEDIA (added 2026-10-02) -- local files picked/recorded on
    // ServiceRequestScreen. Uploaded to Firebase Storage below,
    // once the real requestId exists, via
    // ServiceRequestMediaService. See that file and
    // ServiceRequestModel.photoUrls/videoUrl/voiceNoteUrl for the
    // full explanation.
    // ----------------------------------------------------------
    List<File> photos = const [],
    File? video,
    File? voiceNote,
  }) async {
    // ----------------------------------------------------------
    // GENERATE A UNIQUE REQUEST ID
    // ----------------------------------------------------------

    final String requestId = FirebaseFirestore.instance
        .collection('service_requests')
        .doc()
        .id;

    // ----------------------------------------------------------
    // UPLOAD MEDIA (added 2026-10-02)
    // ----------------------------------------------------------
    //
    // Uploaded now that the real requestId is known, BEFORE the
    // request document itself is written, so the Firestore write
    // below already carries the final download URLs in one shot
    // instead of a create-then-update.
    //

    final List<String> photoUrls =
        await ServiceRequestMediaService.uploadPhotos(
      requestId: requestId,
      photos: photos,
    );

    final String? videoUrl =
        await ServiceRequestMediaService.uploadVideo(
      requestId: requestId,
      video: video,
    );

    final String? voiceNoteUrl =
        await ServiceRequestMediaService.uploadVoiceNote(
      requestId: requestId,
      voiceNote: voiceNote,
    );

    final ServiceRequestModel request = ServiceRequestModel(
      requestId: requestId,
      customerId: customerId,
      requestTypeId: requestTypeId,
      capabilityId: capabilityId,
      categoryId: categoryId,
      description: description,
      latitude: latitude,
      longitude: longitude,
      urgency: urgency,
      isEmergency: isEmergency,
      status: 'OPEN',
      createdAt: DateTime.now(),
      categoryName: categoryName,
      subCategoryName: subCategoryName,
      address: address,
      preferredDate: preferredDate,
      preferredTimeSlot: preferredTimeSlot,
      pricingType: pricingType,
      fixedPriceAnswers: fixedPriceAnswers,
      numberOfServiceRecipients: numberOfServiceRecipients,
      serviceDurationHours: serviceDurationHours,
      computedFairPrice: computedFairPrice,
      postedPrice: postedPrice,
      customerProvidesMaterial: customerProvidesMaterial,
      materialGrade: materialGrade,
      materialBrandPreference: materialBrandPreference,
      matchGroup: matchGroup,
      vehicleType: vehicleType,
      photoUrls: photoUrls,
      videoUrl: videoUrl,
      voiceNoteUrl: voiceNoteUrl,
    );

    await RequestRepository.addRequest(
      request,
    );

    return request;
  }
}
