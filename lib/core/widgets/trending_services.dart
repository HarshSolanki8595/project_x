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
        "icon": Icons.pest_control_rounded,
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
            "Trending Services",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (context, index) {
              final item = services[index];
              final color = item["color"] as Color;

              return InkWell(
                borderRadius: BorderRadius.circular(21),
                onTap: () => onServiceTap?.call(item["title"]),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: const Color(0xFFEEF3FF),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(
                          item["icon"],
                          color: color,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item["title"],
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["subtitle"],
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 13),
                      const Row(
                        children: [
                          Text(
                            "Book Now",
                            style: TextStyle(
                              color: Color(0xFF1557FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF1557FF),
                            size: 17,
                          ),
                        ],
                      ),
                    ],
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
