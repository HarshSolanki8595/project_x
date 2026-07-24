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
        "icon": Icons.plumbing,
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
        "icon": Icons.format_paint,
        "color": Colors.deepOrange,
      },
      {
        "title": "Carpenter",
        "icon": Icons.carpenter,
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          height: 118,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = services[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  onServiceTap?.call(item["title"]);
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            (item["color"] as Color).withOpacity(.15),
                        child: Icon(
                          item["icon"],
                          color: item["color"],
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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