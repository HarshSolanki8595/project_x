import '../models/booking.dart';
import '../models/professional.dart';
import '../models/service_request.dart';

final List<Booking> dummyBookings = [
  Booking(
    bookingId: "NV100001",
    status: BookingStatus.awaitingAcceptance,
    createdAt: DateTime.now(),

    request: ServiceRequest(
      categoryName: "Home Repairs",
      subCategoryName: "Electrician",
      issueDescription: "Fan is not working.",
      isEmergency: false,
      address: "Andheri West, Mumbai",
      preferredDate: DateTime.now(),
      preferredTimeSlot: "Morning",
    ),

    professional: dummyProfessionals.first,
  ),

  Booking(
    bookingId: "NV100002",
    status: BookingStatus.completed,
    createdAt: DateTime.now(),

    request: ServiceRequest(
      categoryName: "Cleaning",
      subCategoryName: "Home Cleaning",
      issueDescription: "Deep cleaning.",
      isEmergency: false,
      address: "Powai, Mumbai",
      preferredDate: DateTime.now(),
      preferredTimeSlot: "Afternoon",
    ),

    professional: dummyProfessionals[1],
  ),

  Booking(
    bookingId: "NV100003",
    status: BookingStatus.cancelled,
    createdAt: DateTime.now(),

    request: ServiceRequest(
      categoryName: "Appliances",
      subCategoryName: "AC Repair",
      issueDescription: "Cooling issue.",
      isEmergency: false,
      address: "Bandra, Mumbai",
      preferredDate: DateTime.now(),
      preferredTimeSlot: "Evening",
    ),

    professional: dummyProfessionals[2],
  ),
];