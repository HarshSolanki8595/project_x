import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/booking.dart';
import '../../models/professional.dart';
import '../../models/service_request.dart';

class BookingService {
  BookingService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static Future<String> createBooking({
    required ServiceRequest request,
    required Professional professional,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    try {
      final bookingRef = _firestore
          .collection("users")
          .doc(user.uid)
          .collection("bookings")
          .doc();

      final booking = Booking(
        bookingId: bookingRef.id,
        request: request,
        professional: professional,
        status: BookingStatus.awaitingAcceptance,
        createdAt: DateTime.now(),
      );

      print("========== BOOKING ==========");
      print("Booking ID : ${booking.bookingId}");
      print("User ID    : ${user.uid}");
      print("Data       : ${booking.toMap()}");

      await bookingRef.set(
        booking.toMap(),
      );

      print("✅ Booking saved successfully.");

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("notifications")
          .add({
        "title": "Booking Confirmed",
        "message": "Your booking has been placed successfully.",
        "bookingId": booking.bookingId,
        "isRead": false,
        "createdAt": Timestamp.now(),
      });

      print("✅ Notification created.");

      return booking.bookingId;
    } catch (e, stackTrace) {
      print("========== BOOKING ERROR ==========");
      print(e);
      print(stackTrace);

      rethrow;
    }
  }
}