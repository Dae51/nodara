import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Small pill used for stat/reward badges and meta chips.
///
/// Defaults to the amber "volunteer hours" tint from the design system;
/// pass [background] / [foreground] to render the white mini-chips variant.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    this.icon,
    this.showDot = false,
    this.background,
    this.foreground,
    this.dotColor,
    this.bold = true,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  final String label;
  final IconData? icon;
  final bool showDot;
  final Color? background;
  final Color? foreground;
  final Color? dotColor;
  final bool bold;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppColors.onSurface;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: fg,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
