import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review_model.dart';

// ================================================================
// REVIEW SERVICE
// ================================================================
//
// A review is a direct client write (no Cloud Function, unlike
// acceptBid) -- firestore.rules already guarantees the review can
// only be created by the order's own customer, for an order that
// is actually ORDER_COMPLETED, with a 1-5 rating, and only once
// (the review doc ID == orderId, so a second attempt becomes an
// `update`, which the rules block). See the `reviews` match block
// in firestore.rules for the full constraint.
//

class ReviewService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _collection = 'reviews';

  static CollectionReference<Map<String, dynamic>> _reviews() {
    return _firestore.collection(_collection);
  }

  // ============================================================
  // SUBMIT REVIEW
  // ============================================================

  static Future<void> submitReview({
    required String orderId,
    required String requestId,
    required String professionalId,
    required int rating,
    required String comment,
  }) async {
    final customerId = FirebaseAuth.instance.currentUser?.uid;

    if (customerId == null) {
      throw StateError('You must be signed in to leave a review.');
    }

    if (rating < 1 || rating > 5) {
      throw StateError('Please select a rating between 1 and 5.');
    }

    final review = ReviewModel(
      reviewId: orderId,
      orderId: orderId,
      requestId: requestId,
      customerId: customerId,
      professionalId: professionalId,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _reviews().doc(orderId).set({
        ...review.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw StateError(
        e.message ?? 'Unable to submit your review right now.',
      );
    }
  }

  // ============================================================
  // WATCH REVIEW FOR ORDER
  // ============================================================
  //
  // Used by the Order Status screen to know whether this order
  // already has a review (and if so, show it read-only) or still
  // needs one (show the "Rate this service" prompt).
  //

  static Stream<ReviewModel?> watchReviewForOrder(String orderId) {
    return _reviews().doc(orderId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return ReviewModel.fromFirestore(data);
    });
  }
}