import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/widgets/impact_progress_bar.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/core/widgets/placeholder_view.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Perfil del voluntario. F5 (Rogelio): editar datos, descargar reporte
/// PDF y cerrar sesión.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final impact = context.watch<ApplicationsProvider>();

    if (user == null) {
      return const Scaffold(body: LoadingView());
    }

    final subtitulo = [
      user.carrera ?? user.tipo.label,
      'Nivel ${impact.nivel}',
    ].join(' · ');

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
                            url: user.avatarUrl,
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
                              Text(user.nombre, style: AppTextStyles.titleLg),
                              Text(
                                subtitulo,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (user.tieneMetaDeHoras) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Text(
                            '${impact.horasCompletadas} / ${impact.horasRequeridas} hrs',
                            style: AppTextStyles.titleSm
                                .copyWith(color: AppColors.primary),
                          ),
                          const Spacer(),
                          Text(
                            '${impact.progresoPorcentaje}% completado',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ImpactProgressBar(value: impact.progreso),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: OutlinedButton.icon(
                onPressed: () => context.read<AuthProvider>().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
            const Expanded(
              child: PlaceholderView(
                icon: Icons.person_outline,
                title: 'Perfil',
                message:
                    'Aquí podrás editar tus datos, intereses y descargar tu reporte de horas.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
