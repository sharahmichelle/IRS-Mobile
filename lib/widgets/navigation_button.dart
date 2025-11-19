// widgets/graphs_screen/navigation_button.dart
import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color primaryColor;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: primaryColor),
        padding: EdgeInsets.zero,
      ),
    );
  }
}