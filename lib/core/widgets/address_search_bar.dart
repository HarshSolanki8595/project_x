import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AddressSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const AddressSearchBar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              height: 54,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppTheme.primaryBlue,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Search address",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.mic_none,
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}