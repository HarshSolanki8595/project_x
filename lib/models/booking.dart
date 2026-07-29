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
}