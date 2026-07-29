import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../models/service_request.dart';

class ProfessionalsScreen extends StatelessWidget {
  final ServiceRequest request;

  const ProfessionalsScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Professionals"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyProfessionals.length,
        itemBuilder: (context, index) {
          final professional = dummyProfessionals[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildProfessionalCard(
              context,
              professional,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalCard(
  BuildContext context,
  Professional professional,
) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Profile Row
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(
                  Icons.person,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      professional.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    if (professional.verified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Rating
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              const SizedBox(width: 6),
              Text(
                "${professional.rating} (${professional.reviews} Reviews)",
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Experience
          Row(
            children: [
              const Icon(Icons.work_outline),
              const SizedBox(width: 8),
              Text("${professional.experience} Years Experience"),
            ],
          ),

          const SizedBox(height: 10),

          /// Jobs Completed
          Row(
            children: [
              const Icon(Icons.build_circle_outlined),
              const SizedBox(width: 8),
              Text("${professional.jobsCompleted} Jobs Completed"),
            ],
          ),

          const SizedBox(height: 10),

          /// Distance
          Row(
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 8),
              Text("${professional.distance} km Away"),
            ],
          ),

          const SizedBox(height: 10),

          /// Arrival
          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 8),
              Text("Can arrive in ${professional.arrivalTime}"),
            ],
          ),

          const Divider(height: 30),

          /// Quote
          Text(
            "Quote",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "₹${professional.quote.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            professional.quoteDescription,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          /// Buttons
          Row(
            children: [

              Expanded(
  child: OutlinedButton(
    onPressed: () {
      _showProfessionalProfile(
        context,
        professional,
      );
    },
    child: const Text("View Profile"),
  ),
),

              const SizedBox(width: 12),

              Expanded(
  child: ElevatedButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking ${professional.name}",
          ),
        ),
      );
    },
    child: const Text("Book Now"),
  ),
),
            ],
          ),
        ],
      ),
    ),
  );
}

void _showProfessionalProfile(
  BuildContext context,
  Professional professional,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 16),

            Text(
              professional.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "⭐ ${professional.rating} (${professional.reviews} Reviews)",
            ),

            Text(
              "${professional.experience} Years Experience",
            ),

            Text(
              "${professional.jobsCompleted} Jobs Completed",
            ),

            Text(
              "${professional.distance} km Away",
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

}