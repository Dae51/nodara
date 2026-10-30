import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Estado "error": algo falló al cargar (red, permisos, etc.).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xl,
    ),
  });

  final String message;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            ),
          ],
        ],
      ),
    );
  }
}
