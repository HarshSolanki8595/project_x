import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/professional_model.dart';

// ================================================================
// PROFESSIONAL FIRESTORE SERVICE (CUSTOMER SIDE, READ-ONLY)
// ================================================================
//
// Looks up professional details (name, capabilities, verification,
// phone) from the real `professionals` collection that the
// professional app writes to. Used by OrderStatusScreen to show
// the professional's name/verified badge/call button on an order.
//
// A small in-memory cache avoids re-fetching the same professional
// on every rebuild while a StreamBuilder is live.
//

class ProfessionalFirestoreService {
  ProfessionalFirestoreService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _collection = 'professionals';

  static final Map<String, ProfessionalModel> _cache = {};

  static Future<ProfessionalModel?> getProfessional(
    String professionalId,
  ) async {
    final cached = _cache[professionalId];
    if (cached != null) {
      return cached;
    }

    final snapshot = await _firestore
        .collection(_collection)
        .doc(professionalId)
        .get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    final professional = ProfessionalModel.fromFirestore(data);

    _cache[professionalId] = professional;

    return professional;
  }
}