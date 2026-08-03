class PlacePrediction {
  final String placeId;
  final String description;

  const PlacePrediction({
    required this.placeId,
    required this.description,
  });

  factory PlacePrediction.fromJson(
    Map<String, dynamic> json,
  ) {
    final prediction = json["placePrediction"];

    return PlacePrediction(
      placeId: prediction["placeId"] ?? "",
      description:
          prediction["text"]?["text"] ?? "",
    );
  }
}