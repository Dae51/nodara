import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/impact_progress_bar.dart';
import '../widgets/placeholder_view.dart';
import '../widgets/remote_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Mi Perfil', style: AppTextStyles.headlineSm),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: RemoteImage(
                            url: profile.avatarUrl,
                            width: 56,
                            height: 56,
                            icon: Icons.person,
                            borderRadius: BorderRadius.circular(56),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name,
                                  style: AppTextStyles.titleLg),
                              Text(
                                '${profile.career} · Nivel ${profile.level}',
                                style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text(
                          '${profile.completedHours} / ${profile.requiredHours} hrs',
                          style: AppTextStyles.titleSm
                              .copyWith(color: AppColors.primary),
                        ),
                        const Spacer(),
                        Text(
                          '${profile.progressPercent}% completado',
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ImpactProgressBar(value: profile.progress),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: PlaceholderView(
                icon: Icons.person_outline,
                title: 'Perfil',
                message:
                    'Acá vas a editar tus datos, intereses y preferencias de voluntariado.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
