import 'package:flutter/material.dart';

import 'package:nodara/core/constants/remote_assets.dart';
import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/core/widgets/section_header.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

class DetailAboutSection extends StatelessWidget {
  const DetailAboutSection({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Sobre el voluntariado'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          opportunity.descripcion,
          style: AppTextStyles.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'No se requiere experiencia docente previa: te capacitamos durante una sesión inductiva previa para dotarte de dinámicas pedagógicas lúdicas y materiales didácticos listos para usar.',
          style: AppTextStyles.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
        ),
      ],
    );
  }
}

class DetailRequirementsCard extends StatelessWidget {
  const DetailRequirementsCard({super.key, required this.requisitos});

  final List<String> requisitos;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Requisitos para postular',
            icon: Icons.checklist,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final requirement in requisitos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(requirement, style: AppTextStyles.bodyMd),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class DetailBenefitsCard extends StatelessWidget {
  const DetailBenefitsCard({super.key, required this.beneficios});

  final List<Benefit> beneficios;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Qué te otorgamos',
            icon: Icons.workspace_premium,
            accent: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final benefit in beneficios)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(iconFromKey(benefit.iconKey), size: 22, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(benefit.titulo, style: AppTextStyles.titleSm),
                          Text(
                            benefit.subtitulo,
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DetailMapCard extends StatelessWidget {
  const DetailMapCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.explore, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Punto de Encuentro',
                    style: AppTextStyles.titleMd
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              TextButton.icon(
                onPressed: () => showAppToast(
                  context,
                  'Abriendo ruta al punto de encuentro',
                  icon: Icons.map_outlined,
                ),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Ver ruta'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              height: 144,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const RemoteImage(
                    url: RemoteAssets.mapImage,
                    icon: Icons.map_outlined,
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            opportunity.direccion.isEmpty
                                ? opportunity.ubicacion
                                : opportunity.direccion,
                            style: AppTextStyles.labelSm,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailTestimonialCard extends StatelessWidget {
  const DetailTestimonialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RemoteImage(
                url: RemoteAssets.testimonialAvatar,
                width: 40,
                height: 40,
                icon: Icons.person,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mateo Benítez', style: AppTextStyles.titleSm),
                    Text(
                      'Estudiante de Ing. Civil · Voluntario 2024',
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.format_quote,
                  size: 32, color: Color(0x33093DB2)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"Fue la experiencia más gratificante del semestre. Ver la cara de alivio de los chicos cuando finalmente entendían una ecuación no tiene precio. Además, el trámite de las horas en la facultad fue automático."',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
