class Address {
  final String id;

  final String label;

  final String houseNo;
  final String building;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String landmark;

  final bool isDefault;

  final DateTime createdAt;

  const Address({
    required this.id,
    required this.label,
    required this.houseNo,
    required this.building,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    required this.landmark,
    required this.isDefault,
    required this.createdAt,
  });

  String get fullAddress {
    return [
      houseNo,
      building,
      street,
      area,
      city,
      state,
      pincode,
    ]
        .where((e) => e.trim().isNotEmpty)
        .join(", ");
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "label": label,
      "houseNo": houseNo,
      "building": building,
      "street": street,
      "area": area,
      "city": city,
      "state": state,
      "pincode": pincode,
      "landmark": landmark,
      "isDefault": isDefault,
      "createdAt": createdAt.millisecondsSinceEpoch,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map["id"] ?? "",
      label: map["label"] ?? "",

      houseNo: map["houseNo"] ?? "",
      building: map["building"] ?? "",
      street: map["street"] ?? "",
      area: map["area"] ?? "",
      city: map["city"] ?? "",
      state: map["state"] ?? "",
      pincode: map["pincode"] ?? "",
      landmark: map["landmark"] ?? "",

      isDefault: map["isDefault"] ?? false,

      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map["createdAt"] ?? 0,
      ),
    );
  }

  Address copyWith({
    String? id,
    String? label,
    String? houseNo,
    String? building,
    String? street,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      houseNo: houseNo ?? this.houseNo,
      building: building ?? this.building,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}