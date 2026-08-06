import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/service_request.dart';
import 'finding_professionals_screen.dart';

class ReviewBookingScreen extends StatelessWidget {
  final ServiceRequest request;

  const ReviewBookingScreen({
    super.key,
    required this.request,
  });

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  String get formattedDate {
    if (request.preferredDate == null) {
      return "Not Selected";
    }

    return DateFormat(
      "dd MMM yyyy",
    ).format(request.preferredDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: const Text(
          "Review Booking",
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Please review your request before sending it to nearby professionals.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 28),_buildSectionTitle("Service"),

_buildCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        request.categoryName,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        request.subCategoryName,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),

      if (request.isEmergency) ...[

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 18,
              ),

              SizedBox(width: 8),

              Text(
                "Emergency Service",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),

      ],

    ],
  ),
),

_buildSectionTitle("Issue Description"),

_buildCard(
  child: Text(
    request.issueDescription.isEmpty
        ? "No description provided."
        : request.issueDescription,
    style: const TextStyle(
      fontSize: 16,
      height: 1.5,
    ),
  ),
),

_buildSectionTitle("Photos"),

_buildCard(
  child: request.photos.isEmpty
      ? const Text(
          "No photos attached.",
          style: TextStyle(
            color: Colors.grey,
          ),
        )
      : SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: request.photos.length,
            itemBuilder: (context, index) {

              return Padding(
                padding: const EdgeInsets.only(
                  right: 12,
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.file(
                    request.photos[index],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              );

            },
          ),
        ),
),

const SizedBox(height: 10),_buildSectionTitle("Service Address"),

_buildCard(
  child: Row(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Icon(
        Icons.location_on,
        color: Colors.deepPurple,
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Text(
          request.address == null ||
                  request.address!.isEmpty
              ? "No address selected"
              : request.address!,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),

    ],
  ),
),

_buildSectionTitle("Preferred Schedule"),

_buildCard(
  child: Row(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Icon(
        Icons.calendar_month,
        color: Colors.deepPurple,
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              request.preferredTimeSlot ??
                  "Not Selected",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

          ],
        ),
      ),

    ],
  ),
),

_buildSectionTitle("What Happens Next"),

_buildCard(
  child: Column(
    children: const [

      ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        title: Text(
          "Your request will be sent to nearby verified professionals.",
        ),
      ),

      ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        title: Text(
          "Professionals will review your request and send quotations.",
        ),
      ),

      ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        title: Text(
          "Compare prices, ratings and reviews before choosing one.",
        ),
      ),

      ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        title: Text(
          "No payment is required until you accept a quotation.",
        ),
      ),

    ],
  ),
),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          Colors.deepPurple,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
    ),
    onPressed: () {

      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FindingProfessionalsScreen(
      request: request,
    ),
  ),
);

    },
    child: const Text(
      "REQUEST QUOTES",
      style: TextStyle(
        fontSize: 17,
        color: Colors.white,
        fontWeight:
            FontWeight.bold,
      ),
    ),
  ),
),                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}