import 'dart:io';

class ServiceRequest {
  String categoryName;
  String subCategoryName;
  String issueDescription;
  bool isEmergency;

  List<File> photos;
  File? video;

  String? address;
  DateTime? preferredDate;
  String? preferredTimeSlot;

  ServiceRequest({
    required this.categoryName,
    required this.subCategoryName,
    required this.issueDescription,
    required this.isEmergency,
    this.photos = const [],
    this.video,
    this.address,
    this.preferredDate,
    this.preferredTimeSlot,
  });
}