import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/address.dart';

class AddressRepository {
  AddressRepository._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>
      _addressCollection() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("addresses");
  }

  static Future<void> addAddress(Address address) async {
    await _addressCollection()
        .doc(address.id)
        .set(address.toMap());
  }

  static Future<void> updateAddress(Address address) async {
    await _addressCollection()
        .doc(address.id)
        .update(address.toMap());
  }

  static Future<void> deleteAddress(String addressId) async {
    await _addressCollection()
        .doc(addressId)
        .delete();
  }

  static Stream<List<Address>> addresses() {
    return _addressCollection()
        .orderBy("createdAt", descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Address.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  static Future<void> setDefaultAddress(
      String addressId) async {
    final snapshot =
        await _addressCollection().get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        "isDefault": false,
      });
    }

    batch.update(
      _addressCollection().doc(addressId),
      {
        "isDefault": true,
      },
    );

    await batch.commit();
  }
}