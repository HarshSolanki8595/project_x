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

  Map<String, dynamic> toMap() {
    return {
      "categoryName": categoryName,
      "subCategoryName": subCategoryName,
      "issueDescription": issueDescription,
      "isEmergency": isEmergency,
      "address": address,
      "preferredDate":
          preferredDate?.millisecondsSinceEpoch,
      "preferredTimeSlot": preferredTimeSlot,

      // Firestore stores URLs later
      "photos": <String>[],

      "video": null,
    };
  }

  factory ServiceRequest.fromMap(
      Map<String, dynamic> map) {
    return ServiceRequest(
      categoryName: map["categoryName"] ?? "",
      subCategoryName:
          map["subCategoryName"] ?? "",
      issueDescription:
          map["issueDescription"] ?? "",
      isEmergency:
          map["isEmergency"] ?? false,
      address: map["address"],
      preferredDate:
          map["preferredDate"] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  map["preferredDate"],
                ),
      preferredTimeSlot:
          map["preferredTimeSlot"],

      // We'll populate these after Firebase Storage
      photos: [],

      video: null,
    );
  }
}