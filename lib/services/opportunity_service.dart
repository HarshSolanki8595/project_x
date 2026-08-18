import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/matched_opportunity_model.dart';
import '../models/marketplace_status.dart';

class OpportunityService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _rootCollection =
      'professional_opportunities';

  static const String _requestsCollection =
      'requests';

  // ============================================================
  // FIRESTORE PROFESSIONAL KEY
  // ============================================================
  //
  // Application professional ID:
  //
  // PRO_<firebaseUid>
  //
  // Firestore security path:
  //
  // <firebaseUid>
  //
  // Keeping the raw Firebase UID in the Firestore path allows
  // Security Rules to directly compare the path with
  // request.auth.uid.
  //

  static String _firestoreProfessionalKey(
    String professionalId,
  ) {
    if (professionalId.startsWith('PRO_')) {
      return professionalId.substring(4);
    }

    return professionalId;
  }

  // ============================================================
  // OPPORTUNITY DOCUMENT REFERENCE
  // ============================================================

  static DocumentReference<Map<String, dynamic>>
      _opportunityReference({
    required String professionalId,
    required String requestId,
  }) {
    final firestoreProfessionalKey =
        _firestoreProfessionalKey(
      professionalId,
    );

    return _firestore
        .collection(_rootCollection)
        .doc(firestoreProfessionalKey)
        .collection(_requestsCollection)
        .doc(requestId);
  }

  // ============================================================
  // CREATE OPPORTUNITY
  // ============================================================

  static Future<MatchedOpportunityModel>
      createOpportunity({
    required String requestId,
    required String professionalId,
  }) async {
    final reference =
        _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    );

    final existing =
        await reference.get();

    if (existing.exists &&
        existing.data() != null) {
      return _fromFirestore(
        existing.data()!,
      );
    }

    final now =
        DateTime.now();

    final opportunity =
        MatchedOpportunityModel(
      opportunityId:
          '${professionalId}_$requestId',

      requestId:
          requestId,

      professionalId:
          professionalId,

      status:
          MarketplaceStatus.sent,

      createdAt:
          now,
    );

    await reference.set({
      'opportunityId':
          opportunity.opportunityId,

      'requestId':
          opportunity.requestId,

      'professionalId':
          opportunity.professionalId,

      'status':
          opportunity.status,

      'createdAt':
          Timestamp.fromDate(
        opportunity.createdAt,
      ),
    });

    return opportunity;
  }

  // ============================================================
  // CREATE OPPORTUNITIES FOR MATCHED PROFESSIONALS
  // ============================================================

  static Future<List<MatchedOpportunityModel>>
      createForMatchedProfessionals({
    required String requestId,
    required List<String> professionalIds,
  }) async {
    final List<MatchedOpportunityModel>
        opportunities = [];

    for (final professionalId
        in professionalIds) {
      final opportunity =
          await createOpportunity(
        requestId: requestId,
        professionalId: professionalId,
      );

      opportunities.add(
        opportunity,
      );
    }

    return opportunities;
  }

  // ============================================================
  // CHECK WHETHER PROFESSIONAL CAN BID
  // ============================================================

  static Future<bool>
      canProfessionalBid({
    required String requestId,
    required String professionalId,
  }) async {
    final opportunity =
        await _findOpportunity(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (opportunity == null) {
      return false;
    }

    return opportunity.status ==
            MarketplaceStatus.sent ||
        opportunity.status ==
            MarketplaceStatus.viewed;
  }

  // ============================================================
  // MARK OPPORTUNITY AS VIEWED
  // ============================================================

  static Future<bool>
      markAsViewed({
    required String requestId,
    required String professionalId,
  }) async {
    final opportunity =
        await _findOpportunity(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (opportunity == null ||
        opportunity.status !=
            MarketplaceStatus.sent) {
      return false;
    }

    await _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    ).update({
      'status':
          MarketplaceStatus.viewed,
    });

    return true;
  }

  // ============================================================
  // MARK OPPORTUNITY AS BID SUBMITTED
  // ============================================================

  static Future<bool>
      markAsBidSubmitted({
    required String requestId,
    required String professionalId,
  }) async {
    final opportunity =
        await _findOpportunity(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (opportunity == null) {
      return false;
    }

    if (opportunity.status !=
            MarketplaceStatus.sent &&
        opportunity.status !=
            MarketplaceStatus.viewed) {
      return false;
    }

    await _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    ).update({
      'status':
          MarketplaceStatus.bidSubmitted,
    });

    return true;
  }

  // ============================================================
  // MARK OPPORTUNITY AS SELECTED
  // ============================================================

  static Future<bool>
      markAsSelected({
    required String requestId,
    required String professionalId,
  }) async {
    final opportunity =
        await _findOpportunity(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (opportunity == null ||
        opportunity.status !=
            MarketplaceStatus.bidSubmitted) {
      return false;
    }

    await _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    ).update({
      'status':
          MarketplaceStatus.selected,
    });

    return true;
  }

  // ============================================================
  // CLOSE OTHER OPPORTUNITIES
  // ============================================================

  static Future<void>
      closeOtherOpportunities({
    required String requestId,
    required String selectedProfessionalId,
  }) async {
    final snapshot =
        await _firestore
            .collectionGroup(
              _requestsCollection,
            )
            .where(
              'requestId',
              isEqualTo: requestId,
            )
            .get();

    final batch =
        _firestore.batch();

    for (final document
        in snapshot.docs) {
      final data =
          document.data();

      final professionalId =
          data['professionalId']
                  as String? ??
              '';

      if (professionalId ==
          selectedProfessionalId) {
        continue;
      }

      final status =
          data['status']
                  as String? ??
              '';

      if (status ==
              MarketplaceStatus.sent ||
          status ==
              MarketplaceStatus.viewed ||
          status ==
              MarketplaceStatus.bidSubmitted) {
        batch.update(
          document.reference,
          {
            'status':
                MarketplaceStatus.closed,
          },
        );
      }
    }

    await batch.commit();
  }

  // ============================================================
  // GET OPPORTUNITIES FOR PROFESSIONAL
  // ============================================================

  static Future<List<MatchedOpportunityModel>>
      getOpportunitiesForProfessional(
    String professionalId,
  ) async {
    final firestoreProfessionalKey =
        _firestoreProfessionalKey(
      professionalId,
    );

    final snapshot =
        await _firestore
            .collection(
              _rootCollection,
            )
            .doc(
              firestoreProfessionalKey,
            )
            .collection(
              _requestsCollection,
            )
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();

    return snapshot.docs
        .map(
          (document) =>
              _fromFirestore(
            document.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // REALTIME OPPORTUNITIES
  // ============================================================

  static Stream<List<MatchedOpportunityModel>>
      watchOpportunitiesForProfessional(
    String professionalId,
  ) {
    final firestoreProfessionalKey =
        _firestoreProfessionalKey(
      professionalId,
    );

    return _firestore
        .collection(
          _rootCollection,
        )
        .doc(
          firestoreProfessionalKey,
        )
        .collection(
          _requestsCollection,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) =>
                      _fromFirestore(
                    document.data(),
                  ),
                )
                .toList();
          },
        );
  }

  // ============================================================
  // GET OPPORTUNITIES FOR REQUEST
  // ============================================================

  static Future<List<MatchedOpportunityModel>>
      getOpportunitiesForRequest(
    String requestId,
  ) async {
    final snapshot =
        await _firestore
            .collectionGroup(
              _requestsCollection,
            )
            .where(
              'requestId',
              isEqualTo: requestId,
            )
            .get();

    return snapshot.docs
        .map(
          (document) =>
              _fromFirestore(
            document.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET OPPORTUNITY BY ID
  // ============================================================

  static Future<MatchedOpportunityModel?>
      getOpportunityById({
    required String opportunityId,
    required String professionalId,
  }) async {
    final firestoreProfessionalKey =
        _firestoreProfessionalKey(
      professionalId,
    );

    final snapshot =
        await _firestore
            .collection(
              _rootCollection,
            )
            .doc(
              firestoreProfessionalKey,
            )
            .collection(
              _requestsCollection,
            )
            .where(
              'opportunityId',
              isEqualTo: opportunityId,
            )
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return _fromFirestore(
      snapshot.docs.first.data(),
    );
  }

  // ============================================================
  // INTERNAL LOOKUP
  // ============================================================

  static Future<MatchedOpportunityModel?>
      _findOpportunity({
    required String requestId,
    required String professionalId,
  }) async {
    final snapshot =
        await _opportunityReference(
      professionalId: professionalId,
      requestId: requestId,
    ).get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return null;
    }

    return _fromFirestore(
      snapshot.data()!,
    );
  }

  // ============================================================
  // FIRESTORE → MODEL
  // ============================================================

  static MatchedOpportunityModel
      _fromFirestore(
    Map<String, dynamic> data,
  ) {
    return MatchedOpportunityModel(
      opportunityId:
          data['opportunityId']
                  as String? ??
              '',

      requestId:
          data['requestId']
                  as String? ??
              '',

      professionalId:
          data['professionalId']
                  as String? ??
              '',

      status:
          data['status']
                  as String? ??
              MarketplaceStatus.sent,

      createdAt:
          _readDate(
        data['createdAt'],
      ),
    );
  }

  // ============================================================
  // SAFE DATE READER
  // ============================================================

  static DateTime _readDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}