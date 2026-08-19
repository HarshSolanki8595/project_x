import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/marketplace_status.dart';
import '../models/professional_bid_model.dart';
import 'opportunity_service.dart';

class BidService {
  // ============================================================
  // FIRESTORE-BACKED VERSION
  // ============================================================
  //
  // Bids are stored as fields directly on the existing opportunity
  // document at:
  //
  //   professional_opportunities/{firebaseUid}/requests/{requestId}
  //
  // This reuses your existing Firestore rules for that collection
  // -- no separate `bids` collection or rules needed.
  //
  // IMPORTANT: acceptBid/rejectBid/withdrawBid below only flip the
  // opportunity's own status field -- they do NOT create an order
  // or touch activeOrderCount. The real "customer accepts this
  // bid" action goes through the acceptBid Cloud Function (see
  // order_acceptance_service.dart), which is the only place that
  // atomically creates the order and enforces the 2-active-orders
  // cap. Don't call BidService.acceptBid() expecting an order to
  // come out of it.
  //

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _rootCollection =
      'professional_opportunities';

  static const String _requestsCollection =
      'requests';

  static String _firestoreProfessionalKey(String professionalId) {
    if (professionalId.startsWith('PRO_')) {
      return professionalId.substring(4);
    }
    return professionalId;
  }

  static DocumentReference<Map<String, dynamic>>
      _opportunityReference({
    required String professionalId,
    required String requestId,
  }) {
    final firestoreProfessionalKey =
        _firestoreProfessionalKey(professionalId);

    return _firestore
        .collection(_rootCollection)
        .doc(firestoreProfessionalKey)
        .collection(_requestsCollection)
        .doc(requestId);
  }

  // ============================================================
  // SUBMIT BID
  // ============================================================

  static Future<ProfessionalBidModel> submitBid({
    required String requestId,
    required String professionalId,
    required double servicePrice,
    required double materialsCost,
    required double visitInspectionCost,
    required double urgencyCost,
    required String warranty,
    required String additionalWork,
    required String message,
  }) async {
    final bool canBid = await OpportunityService.canProfessionalBid(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (!canBid) {
      throw StateError(
        'Professional is not authorized to bid on this request.',
      );
    }

    final reference = _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    );

    final existing = await reference.get();
    final existingData = existing.data();

    if (existingData != null && existingData['bidId'] != null) {
      throw StateError(
        'Professional has already submitted a bid for this '
        'request.',
      );
    }

    final double totalPrice =
        servicePrice + materialsCost + visitInspectionCost + urgencyCost;

    if (totalPrice <= 0) {
      throw ArgumentError(
        'Your total quote must be greater than zero.',
      );
    }

    final String bidId = '${professionalId}_$requestId';
    final DateTime now = DateTime.now();

    await reference.set({
      'bidId': bidId,
      'servicePrice': servicePrice,
      'materialsCost': materialsCost,
      'visitInspectionCost': visitInspectionCost,
      'urgencyCost': urgencyCost,
      'warranty': warranty,
      'additionalWork': additionalWork,
      'message': message,
      'bidSubmittedAt': Timestamp.fromDate(now),
      'status': MarketplaceStatus.bidSubmitted,
    }, SetOptions(merge: true));

    return ProfessionalBidModel(
      bidId: bidId,
      requestId: requestId,
      professionalId: professionalId,
      servicePrice: servicePrice,
      materialsCost: materialsCost,
      visitInspectionCost: visitInspectionCost,
      urgencyCost: urgencyCost,
      warranty: warranty,
      additionalWork: additionalWork,
      message: message,
      status: MarketplaceStatus.submitted,
      createdAt: now,
    );
  }

  // ============================================================
  // GET A SINGLE BID
  // ============================================================

  static Future<ProfessionalBidModel?> getBid({
    required String requestId,
    required String professionalId,
  }) async {
    final reference = _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    );

    final snapshot = await reference.get();
    final data = snapshot.data();

    if (data == null || data['bidId'] == null) {
      return null;
    }

    return _bidFromOpportunityData(
      data,
      status: _bidStatusFromOpportunityStatus(
        data['status'] as String?,
      ),
    );
  }

  // ============================================================
  // ACCEPT BID (LOCAL STATUS ONLY -- SEE COMMENT ABOVE)
  // ============================================================

  static Future<ProfessionalBidModel> acceptBid({
    required String requestId,
    required String professionalId,
  }) async {
    final reference = _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    );

    final snapshot = await reference.get();
    final data = snapshot.data();

    if (data == null || data['bidId'] == null) {
      throw StateError('Bid not found.');
    }

    if (data['status'] != MarketplaceStatus.bidSubmitted) {
      throw StateError('Only a submitted bid can be accepted.');
    }

    await reference.update({
      'status': MarketplaceStatus.selected,
    });

    return _bidFromOpportunityData(
      data,
      status: MarketplaceStatus.accepted,
    );
  }

  // ============================================================
  // REJECT BID
  // ============================================================

  static Future<ProfessionalBidModel> rejectBid({
    required String requestId,
    required String professionalId,
  }) async {
    final reference = _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    );

    final snapshot = await reference.get();
    final data = snapshot.data();

    if (data == null || data['bidId'] == null) {
      throw StateError('Bid not found.');
    }

    if (data['status'] != MarketplaceStatus.bidSubmitted) {
      throw StateError('Only a submitted bid can be rejected.');
    }

    await reference.update({
      'status': MarketplaceStatus.closed,
    });

    return _bidFromOpportunityData(
      data,
      status: MarketplaceStatus.rejected,
    );
  }

  // ============================================================
  // WITHDRAW BID
  // ============================================================

  static Future<ProfessionalBidModel> withdrawBid({
    required String requestId,
    required String professionalId,
  }) async {
    final reference = _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    );

    final snapshot = await reference.get();
    final data = snapshot.data();

    if (data == null || data['bidId'] == null) {
      throw StateError('Bid not found.');
    }

    if (data['status'] != MarketplaceStatus.bidSubmitted) {
      throw StateError('Only a submitted bid can be withdrawn.');
    }

    await reference.update({
      'status': MarketplaceStatus.closed,
    });

    return _bidFromOpportunityData(
      data,
      status: MarketplaceStatus.withdrawn,
    );
  }

  // ============================================================
  // GET BIDS FOR REQUEST (CUSTOMER SIDE)
  // ============================================================

  static Future<List<ProfessionalBidModel>> getBidsForRequest(
    String requestId,
  ) async {
    final snapshot = await _firestore
        .collectionGroup(_requestsCollection)
        .where('requestId', isEqualTo: requestId)
        .get();

    final List<ProfessionalBidModel> bids = [];

    for (final document in snapshot.docs) {
      final data = document.data();
      if (data['bidId'] == null) continue;

      bids.add(_bidFromOpportunityData(
        data,
        status: _bidStatusFromOpportunityStatus(
          data['status'] as String?,
        ),
      ));
    }

    return bids;
  }

  // ============================================================
  // REALTIME BIDS FOR REQUEST (CUSTOMER SIDE)
  // ============================================================

  static Stream<List<ProfessionalBidModel>> watchBidsForRequest(
    String requestId,
  ) {
    return _firestore
        .collectionGroup(_requestsCollection)
        .where('requestId', isEqualTo: requestId)
        .snapshots()
        .map((snapshot) {
      final List<ProfessionalBidModel> bids = [];

      for (final document in snapshot.docs) {
        final data = document.data();
        if (data['bidId'] == null) continue;

        bids.add(_bidFromOpportunityData(
          data,
          status: _bidStatusFromOpportunityStatus(
            data['status'] as String?,
          ),
        ));
      }

      return bids;
    });
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _bidStatusFromOpportunityStatus(
    String? opportunityStatus,
  ) {
    switch (opportunityStatus) {
      case MarketplaceStatus.selected:
        return MarketplaceStatus.accepted;
      case MarketplaceStatus.bidSubmitted:
        return MarketplaceStatus.submitted;
      default:
        return MarketplaceStatus.rejected;
    }
  }

  static ProfessionalBidModel _bidFromOpportunityData(
    Map<String, dynamic> data, {
    required String status,
  }) {
    return ProfessionalBidModel(
      bidId: data['bidId'] as String,
      requestId: data['requestId'] as String,
      professionalId: data['professionalId'] as String,
      servicePrice: (data['servicePrice'] as num?)?.toDouble() ?? 0,
      materialsCost: (data['materialsCost'] as num?)?.toDouble() ?? 0,
      visitInspectionCost:
          (data['visitInspectionCost'] as num?)?.toDouble() ?? 0,
      urgencyCost: (data['urgencyCost'] as num?)?.toDouble() ?? 0,
      warranty: data['warranty'] as String? ?? '',
      additionalWork: data['additionalWork'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: status,
      createdAt: data['bidSubmittedAt'] is Timestamp
          ? (data['bidSubmittedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}