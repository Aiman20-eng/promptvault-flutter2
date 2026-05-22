import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PlatformBadge extends StatelessWidget {
  final String platform;

  const PlatformBadge({super.key, required this.platform});

  Color _getPlatformColor() {
    switch (platform.toLowerCase()) {
      case 'chatgpt':
        return AppTheme.neonEmerald;
      case 'claude':
        return AppTheme.neonAmber;
      case 'midjourney':
        return AppTheme.neonViolet;
      case 'gemini':
        return AppTheme.neonCyan;
      default:
        return AppTheme.neonPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPlatformColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            platform,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
