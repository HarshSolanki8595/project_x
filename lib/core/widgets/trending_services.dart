import 'package:flutter/material.dart';

class TrendingServices extends StatelessWidget {
  const TrendingServices({
    super.key,
    this.onServiceTap,
  });

  final Function(String)? onServiceTap;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "title": "AC Service",
        "subtitle": "Beat the summer heat",
        "icon": Icons.ac_unit_rounded,
        "color": Colors.lightBlue,
      },
      {
        "title": "Waterproofing",
        "subtitle": "Monsoon ready homes",
        "icon": Icons.water_drop_rounded,
        "color": Colors.blue,
      },
      {
        "title": "Pest Control",
        "subtitle": "Protect your family",
        "icon": Icons.pest_control,
        "color": Colors.redAccent,
      },
      {
        "title": "Deep Cleaning",
        "subtitle": "Festival special",
        "icon": Icons.cleaning_services_rounded,
        "color": Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "🔥 Trending Services",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          height: 165,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = services[index];

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  onServiceTap?.call(item["title"]);
                },
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              (item["color"] as Color)
                                  .withOpacity(.15),
                          child: Icon(
                            item["icon"],
                            color: item["color"],
                            size: 30,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          item["title"],
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item["subtitle"],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [

                            const Text(
                              "Book Now",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 6),

                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}