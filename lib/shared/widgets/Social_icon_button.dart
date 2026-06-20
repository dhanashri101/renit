import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isDark ? Colors.black12 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}