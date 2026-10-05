import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ================================================================
// SERVICE REQUEST MEDIA SERVICE (NEW — 2026-10-02)
// ================================================================
//
// Uploads the photos/video/voice note a customer attaches on
// ServiceRequestScreen to Firebase Storage and returns their
// download URLs, ready to be written onto ServiceRequestModel.
//
// Before this existed, ServiceRequest.toMap() (lib/models/
// service_request.dart) hardcoded 'photos': [] and 'video': null
// with a comment saying Storage URLs would be "added later" --
// the files were picked in the UI but never actually uploaded or
// persisted anywhere. This service finally does that upload, and
// is also used for the new voice-note feature so all three kinds
// of request media go through one place.
//
// Follows the exact same Storage pattern already used by
// OrderService.uploadCompletionPhotos/uploadPickupConditionPhotos
// on the professional app -- Storage paths:
//   service_request_photos/{customerFirebaseUid}/{requestId}/...
//   service_request_videos/{customerFirebaseUid}/{requestId}/...
//   service_request_voice_notes/{customerFirebaseUid}/{requestId}/...
// (see storage.rules for the matching access rules).
//
// Called from RequestService.createRequest, after the real
// Firestore requestId has been generated -- so uploads only ever
// happen for a request that is actually being created, and the
// Storage path is keyed by the same requestId the customer will
// see everywhere else.
//

class ServiceRequestMediaService {
  // ============================================================
  // UPLOAD PHOTOS
  // ============================================================
  //
  // Up to 6 photos (matches ServiceRequestScreen's picker, which
  // doesn't itself cap the count -- capped here defensively so a
  // runaway selection can't flood Storage).
  //

  static Future<List<String>> uploadPhotos({
    required String requestId,
    required List<File> photos,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to upload photos.');
    }

    if (photos.isEmpty) {
      return [];
    }

    if (photos.length > 6) {
      throw StateError('Please select at most 6 photos.');
    }

    final List<String> downloadUrls = [];

    for (var i = 0; i < photos.length; i++) {
      final file = photos[i];

      if (!await file.exists()) {
        throw StateError('One of the selected photos could not be found.');
      }

      final String timestamp =
          DateTime.now().millisecondsSinceEpoch.toString();

      final Reference reference = FirebaseStorage.instance
          .ref()
          .child('service_request_photos')
          .child(user.uid)
          .child(requestId)
          .child('${timestamp}_$i.jpg');

      try {
        await reference.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final url = await reference.getDownloadURL();
        downloadUrls.add(url);
      } on FirebaseException catch (e) {
        throw StateError(
          'Photo upload failed: ${e.message ?? e.code}',
        );
      }
    }

    return downloadUrls;
  }

  // ============================================================
  // UPLOAD VIDEO
  // ============================================================
  //
  // A single optional video (ServiceRequestScreen only ever lets
  // the customer attach one).
  //

  static Future<String?> uploadVideo({
    required String requestId,
    required File? video,
  }) async {
    if (video == null) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to upload a video.');
    }

    if (!await video.exists()) {
      throw StateError('The selected video could not be found.');
    }

    final String timestamp =
        DateTime.now().millisecondsSinceEpoch.toString();

    final Reference reference = FirebaseStorage.instance
        .ref()
        .child('service_request_videos')
        .child(user.uid)
        .child(requestId)
        .child('$timestamp.mp4');

    try {
      await reference.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );

      return await reference.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StateError(
        'Video upload failed: ${e.message ?? e.code}',
      );
    }
  }

  // ============================================================
  // UPLOAD VOICE NOTE
  // ============================================================
  //
  // A single optional voice note describing the problem, recorded
  // on ServiceRequestScreen (capped client-side at 60 seconds, so
  // a real recording never approaches storage.rules' 10MB ceiling
  // for this path).
  //

  static Future<String?> uploadVoiceNote({
    required String requestId,
    required File? voiceNote,
  }) async {
    if (voiceNote == null) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to upload a voice note.');
    }

    if (!await voiceNote.exists()) {
      throw StateError('The recorded voice note could not be found.');
    }

    final String timestamp =
        DateTime.now().millisecondsSinceEpoch.toString();

    final Reference reference = FirebaseStorage.instance
        .ref()
        .child('service_request_voice_notes')
        .child(user.uid)
        .child(requestId)
        .child('$timestamp.m4a');

    try {
      await reference.putFile(
        voiceNote,
        SettableMetadata(contentType: 'audio/m4a'),
      );

      return await reference.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StateError(
        'Voice note upload failed: ${e.message ?? e.code}',
      );
    }
  }
}
