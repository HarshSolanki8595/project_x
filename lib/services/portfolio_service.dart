import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// PORTFOLIO MODEL + SERVICE (NEW — 2026-08-23)
// ================================================================
//
// Reads professionals/{professionalId}/portfolio/{orderId} --
// written EXCLUSIVELY by the completeJob Cloud Function (Admin
// SDK) as a deliberately minimal, non-sensitive record of a
// completed job's photos. See firestore.rules and index.js for
// why this exists as its own subcollection rather than exposing
// full order documents publicly.
//

class PortfolioEntryModel {
  final String orderId;
  final List<String> photoUrls;
  final DateTime completedAt;

  const PortfolioEntryModel({
    required this.orderId,
    required this.photoUrls,
    required this.completedAt,
  });

  factory PortfolioEntryModel.fromFirestore(Map<String, dynamic> data) {
    return PortfolioEntryModel(
      orderId: data['orderId'] as String? ?? '',
      photoUrls: (data['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      completedAt: _readDate(data['completedAt']),
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

class PortfolioService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // WATCH PORTFOLIO FOR PROFESSIONAL
  // ============================================================
  //
  // NOTE: this is a composite query (where implicit via
  // subcollection path + orderBy). The first time it runs,
  // Firestore may throw with a link to auto-create the required
  // index -- open that link once and it starts working from then
  // on, same as every other composite query in this app.
  //

  static Stream<List<PortfolioEntryModel>> watchPortfolio(
    String professionalId, {
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('professionals')
        .doc(professionalId)
        .collection('portfolio')
        .orderBy('completedAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PortfolioEntryModel.fromFirestore(doc.data()))
          .toList();
    });
  }
}