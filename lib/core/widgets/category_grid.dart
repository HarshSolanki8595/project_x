import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    this.onCategoryTap,
  });

  final Function(String)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        "title": "Electrical",
        "icon": Icons.electrical_services_rounded,
        "color": Colors.amber,
      },
      {
        "title": "Plumbing",
        "icon": Icons.plumbing,
        "color": Colors.blue,
      },
      {
        "title": "Appliances",
        "icon": Icons.kitchen_rounded,
        "color": Colors.deepPurple,
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
        "title": "Carpentry",
        "icon": Icons.carpenter,
        "color": Colors.brown,
      },
      {
        "title": "Pest Control",
        "icon": Icons.pest_control,
        "color": Colors.redAccent,
      },
      {
        "title": "Home Repair",
        "icon": Icons.home_repair_service,
        "color": Colors.indigo,
      },
      {
        "title": "Automobile",
        "icon": Icons.directions_car_filled_rounded,
        "color": Colors.teal,
      },
      {
        "title": "Moving",
        "icon": Icons.local_shipping_rounded,
        "color": Colors.orange,
      },
      {
        "title": "Beauty",
        "icon": Icons.face_retouching_natural,
        "color": Colors.pink,
      },
      {
        "title": "More",
        "icon": Icons.grid_view_rounded,
        "color": Colors.grey,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Browse Categories",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: .90,
            ),
            itemBuilder: (context, index) {
              final item = categories[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  onCategoryTap?.call(item["title"]);
                },
                child: Container(
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
                        radius: 26,
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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