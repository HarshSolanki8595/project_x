class Professional {
  final String id;
  final String name;
  final String image;
  final double rating;
  final int reviews;
  final bool verified;
  final int experience;
  final int jobsCompleted;
  final double distance;
  final String arrivalTime;
  final double quote;
  final String quoteDescription;

  const Professional({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.verified,
    required this.experience,
    required this.jobsCompleted,
    required this.distance,
    required this.arrivalTime,
    required this.quote,
    required this.quoteDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "rating": rating,
      "reviews": reviews,
      "verified": verified,
      "experience": experience,
      "jobsCompleted": jobsCompleted,
      "distance": distance,
      "arrivalTime": arrivalTime,
      "quote": quote,
      "quoteDescription": quoteDescription,
    };
  }

  factory Professional.fromMap(Map<String, dynamic> map) {
    return Professional(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      image: map["image"] ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
      reviews: map["reviews"] ?? 0,
      verified: map["verified"] ?? false,
      experience: map["experience"] ?? 0,
      jobsCompleted: map["jobsCompleted"] ?? 0,
      distance: (map["distance"] ?? 0).toDouble(),
      arrivalTime: map["arrivalTime"] ?? "",
      quote: (map["quote"] ?? 0).toDouble(),
      quoteDescription: map["quoteDescription"] ?? "",
    );
  }
}

/// Dummy Professionals
final List<Professional> dummyProfessionals = [
  Professional(
    id: '1',
    name: 'Rahul Electrical Services',
    image: 'assets/images/profile_placeholder.png',
    rating: 4.9,
    reviews: 1245,
    verified: true,
    experience: 8,
    jobsCompleted: 2180,
    distance: 2.3,
    arrivalTime: '30 mins',
    quote: 450,
    quoteDescription: 'Inspection + Minor Repairs',
  ),

  Professional(
    id: '2',
    name: 'Patel Home Repairs',
    image: 'assets/images/profile_placeholder.png',
    rating: 4.8,
    reviews: 986,
    verified: true,
    experience: 10,
    jobsCompleted: 1840,
    distance: 3.8,
    arrivalTime: '45 mins',
    quote: 520,
    quoteDescription: 'Complete Service Visit',
  ),

  Professional(
    id: '3',
    name: 'QuickFix Solutions',
    image: 'assets/images/profile_placeholder.png',
    rating: 4.7,
    reviews: 735,
    verified: true,
    experience: 6,
    jobsCompleted: 1365,
    distance: 1.9,
    arrivalTime: '25 mins',
    quote: 400,
    quoteDescription: 'Diagnosis + Repair',
  ),

  Professional(
    id: '4',
    name: 'Urban Expert Services',
    image: 'assets/images/profile_placeholder.png',
    rating: 4.9,
    reviews: 1568,
    verified: true,
    experience: 12,
    jobsCompleted: 2910,
    distance: 4.5,
    arrivalTime: '50 mins',
    quote: 650,
    quoteDescription: 'Premium Service Package',
  ),

  Professional(
    id: '5',
    name: 'Smart Home Technicians',
    image: 'assets/images/profile_placeholder.png',
    rating: 4.6,
    reviews: 652,
    verified: true,
    experience: 5,
    jobsCompleted: 980,
    distance: 2.7,
    arrivalTime: '35 mins',
    quote: 380,
    quoteDescription: 'Basic Inspection & Repair',
  ),
];