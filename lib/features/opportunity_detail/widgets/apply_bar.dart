import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

class ApplyBar extends StatelessWidget {
  const ApplyBar({
    super.key,
    required this.hours,
    required this.hasApplied,
    required this.onApply,
  });

  final int hours;
  final bool hasApplied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: AppShadows.bottomBar,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reconocimiento',
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  Row(
                    children: [
                      Text('$hours hrs',
                          style: AppTextStyles.titleLg
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: hasApplied
                        ? AppColors.tertiary
                        : AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasApplied ? Icons.task_alt : Icons.how_to_reg,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          hasApplied ? '¡Ya estás postulado!' : 'Postularme ahora',
                          style: AppTextStyles.labelLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!hasApplied) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text('1 paso',
                              style: AppTextStyles.labelSm
                                  .copyWith(color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
