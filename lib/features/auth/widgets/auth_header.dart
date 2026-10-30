import 'package:flutter/material.dart';

import 'package:nodara/core/widgets/app_logo.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Logo + título + subtítulo de las pantallas de login y registro.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: AppTextStyles.headlineMobile),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style:
              AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Mensaje de error del formulario (no depende solo del color: lleva ícono).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón principal que muestra un indicador mientras se procesa.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
