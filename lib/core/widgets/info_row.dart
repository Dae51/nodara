import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Icon + text block used in the detail spec sheet and application cards.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.label,
    this.subtitle,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.surfaceContainerHighest,
    this.filled = true,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? label;
  final String? subtitle;
  final Color iconColor;
  final Color iconBackground;
  final bool filled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label case final labelText?)
                Text(
                  labelText,
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              Text(
                title,
                style: AppTextStyles.titleSm
                    .copyWith(color: AppColors.onSurface),
              ),
              if (subtitle case final subtitleText?) ...[
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );

    if (!filled) return content;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: content,
    );
  }
}
