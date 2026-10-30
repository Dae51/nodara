import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Estado "vacío": no hay registros para mostrar.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xl,
    ),
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (label != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    );
  }
}
