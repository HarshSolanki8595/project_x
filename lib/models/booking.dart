import 'professional.dart';
import 'service_request.dart';

enum BookingStatus {
  awaitingAcceptance,
  accepted,
  onTheWay,
  inProgress,
  completed,
  cancelled,
}

class Booking {
  final String bookingId;
  final ServiceRequest request;
  final Professional professional;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.bookingId,
    required this.request,
    required this.professional,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "bookingId": bookingId,
      "request": request.toMap(),
      "professional": professional.toMap(),
      "status": status.name,
      "createdAt": createdAt.millisecondsSinceEpoch,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookingId: map["bookingId"] ?? "",
      request: ServiceRequest.fromMap(
        Map<String, dynamic>.from(map["request"] ?? {}),
      ),
      professional: Professional.fromMap(
        Map<String, dynamic>.from(map["professional"] ?? {}),
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map["status"],
        orElse: () => BookingStatus.awaitingAcceptance,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map["createdAt"] ?? 0,
      ),
    );
  }
}