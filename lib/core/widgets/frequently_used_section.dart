import 'package:flutter/material.dart';

class FrequentlyUsedSection extends StatelessWidget {
  const FrequentlyUsedSection({
    super.key,
    this.onServiceTap,
  });

  final Function(String)? onServiceTap;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "title": "Electrician",
        "icon": Icons.electrical_services_rounded,
        "color": Colors.amber,
      },
      {
        "title": "Plumber",
        "icon": Icons.plumbing_rounded,
        "color": Colors.blue,
      },
      {
        "title": "AC Repair",
        "icon": Icons.ac_unit_rounded,
        "color": Colors.lightBlue,
      },
      {
        "title": "Cleaning",
        "icon": Icons.cleaning_services_rounded,
        "color": Colors.green,
      },
      {
        "title": "Painting",
        "icon": Icons.format_paint_rounded,
        "color": Colors.deepOrange,
      },
      {
        "title": "Carpenter",
        "icon": Icons.carpenter_rounded,
        "color": Colors.brown,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Frequently Used",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 116,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = services[index];
              final color = item["color"] as Color;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onServiceTap?.call(item["title"]),
                child: Container(
                  width: 104,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE8EDF4),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(
                          item["icon"],
                          color: color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
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
