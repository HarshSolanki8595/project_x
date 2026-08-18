import 'package:flutter/material.dart';

import '../../data/service_categories.dart';
import '../../models/category.dart';
import '../service_request_screen.dart';

class SubcategoryScreen extends StatelessWidget {
  final String categoryName;

  const SubcategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("Received category: '$categoryName'");

for (final c in ServiceCategories.all) {
  debugPrint("Available category: '${c.name}'");
}

final Category? category =
    ServiceCategories.getCategoryByName(categoryName);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(categoryName),
      ),

      body: category == null
          ? const Center(
              child: Text(
                "Category not found",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: category.subCategories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 14),
              itemBuilder: (context, index) {
  final subCategory = category.subCategories[index];

  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceRequestScreen(
            categoryName: category.name,
            subCategoryName: subCategory.name,
            subCategoryId: subCategory.id,
            categoryId: category.id,
          ),
        ),
      );
    },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              category.color.withValues(alpha: .15),
                          child: Icon(
                            subCategory.icon,
                            color: category.color,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                subCategory.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                subCategory.description,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}