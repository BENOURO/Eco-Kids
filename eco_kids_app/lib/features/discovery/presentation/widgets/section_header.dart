import 'package:flutter/material.dart';
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAllPressed;
  final String? viewAllText;

  const SectionHeader({
    Key? key,
    required this.title,
    this.onViewAllPressed,
    this.viewAllText = 'View all',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (onViewAllPressed != null)
          TextButton(
            onPressed: onViewAllPressed,
            child: Text(
              viewAllText!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}