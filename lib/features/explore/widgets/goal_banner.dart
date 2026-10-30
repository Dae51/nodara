import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Banner de meta de horas (solo para quienes tienen meta).
class GoalBanner extends StatelessWidget {
  const GoalBanner({
    super.key,
    required this.porcentaje,
    required this.horasFaltantes,
    required this.onTap,
  });

  final int porcentaje;
  final int horasFaltantes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryFixed.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horasFaltantes == 0
                          ? '¡Meta de horas cumplida!'
                          : '¡Meta semestral al $porcentaje%!',
                      style: AppTextStyles.titleSm
                          .copyWith(color: AppColors.onPrimaryFixed),
                    ),
                    Text(
                      horasFaltantes == 0
                          ? 'Ya puedes descargar tu reporte de horas.'
                          : 'Sumá $horasFaltantes horas más para validar tu crédito social.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
