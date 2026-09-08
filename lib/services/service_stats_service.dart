import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// SERVICE STATS -- powers Trending Services (Harsh's point 5)
// ============================================================
//
// Added 2026-09-06. Reads serviceStats/{categoryId}, a Firestore
// collection the acceptBid and acceptFixedPriceOpportunity Cloud
// Functions increment every time a customer's bid is accepted for
// a request in that category -- i.e. every real order placed on
// the app. See functions/index.js for where orderCount is written;
// this service only ever reads it. firestore.rules makes this
// collection read-only for signed-in customers.
// ============================================================

class ServiceStatsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'serviceStats';

  // ============================================================
  // WATCH TOP CATEGORIES BY ORDER COUNT
  // ============================================================
  //
  // Returns categoryId -> orderCount, most-ordered first. The
  // caller (TrendingServices) maps each categoryId back to a
  // display name/icon/color via ServiceCategories.getCategoryById.
  //

  static Stream<List<MapEntry<String, int>>> watchTopCategories({
    int limit = 6,
  }) {
    return _firestore
        .collection(_collection)
        .orderBy('orderCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final int count = (data['orderCount'] as num?)?.toInt() ?? 0;
        return MapEntry(doc.id, count);
      }).toList();
    });
  }
}
