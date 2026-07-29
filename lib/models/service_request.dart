class ServiceRequest {
  String categoryName;
  String subCategoryName;
  String issueDescription;
  bool isEmergency;

  String? address;
  DateTime? preferredDate;
  String? preferredTimeSlot;

  ServiceRequest({
    required this.categoryName,
    required this.subCategoryName,
    required this.issueDescription,
    required this.isEmergency,
    this.address,
    this.preferredDate,
    this.preferredTimeSlot,
  });
}