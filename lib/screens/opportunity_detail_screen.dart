import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/opportunity.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_logo.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/impact_progress_bar.dart';
import '../widgets/info_row.dart';
import '../widgets/remote_image.dart';
import '../widgets/section_header.dart';

class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  Opportunity get _opportunity => widget.opportunity;

  void _showToast(String message, {IconData icon = Icons.check_circle}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '¡Súmate a ${_opportunity.title} conmigo en EcháUnaMano! Valida ${_opportunity.hours} horas de servicio social.',
      ),
    );
    if (!mounted) return;
    _showToast('Enlace copiado al portapapeles', icon: Icons.link);
  }

  void _toggleBookmark() {
    final state = AppScope.of(context);
    state.toggleFavorite(_opportunity.id);
    _showToast(
      state.isFavorite(_opportunity.id)
          ? 'Guardado en tus oportunidades favoritas'
          : 'Eliminado de tus guardados',
      icon: state.isFavorite(_opportunity.id)
          ? Icons.bookmark_added
          : Icons.bookmark_remove,
    );
  }

  void _apply() {
    final state = AppScope.of(context);
    if (state.hasApplied(_opportunity)) {
      _showToast('Ya tenés una postulación activa en este programa',
          icon: Icons.info_outline);
      return;
    }
    state.apply(_opportunity);
    _showToast(
      '¡Listo! Revisá tu email para la inducción del 14 de Abril 🚀',
      icon: Icons.celebration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isFavorite = state.isFavorite(_opportunity.id);
    final hasApplied = state.hasApplied(_opportunity);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            const AppLogo(markSize: 32, showWordmark: false),
            const SizedBox(width: AppSpacing.sm),
            Text('Detalle De Causa', style: AppTextStyles.titleMd),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showToast('Más opciones próximamente',
                icon: Icons.more_horiz),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(
            opportunity: _opportunity,
            isFavorite: isFavorite,
            onShare: _share,
            onBookmark: _toggleBookmark,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleCard(opportunity: _opportunity),
                const SizedBox(height: AppSpacing.lg),
                _SpecSheet(opportunity: _opportunity),
                const SizedBox(height: AppSpacing.lg),
                _AboutSection(opportunity: _opportunity),
                const SizedBox(height: AppSpacing.lg),
                _RequirementsCard(requirements: _opportunity.requirements),
                const SizedBox(height: AppSpacing.lg),
                _BenefitsCard(benefits: _opportunity.benefits),
                const SizedBox(height: AppSpacing.lg),
                _MapCard(opportunity: _opportunity),
                const SizedBox(height: AppSpacing.lg),
                const _TestimonialCard(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ApplyBar(
        hours: _opportunity.hours,
        hasApplied: hasApplied,
        onApply: _apply,
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.opportunity,
    required this.isFavorite,
    required this.onShare,
    required this.onBookmark,
  });

  final Opportunity opportunity;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(
            url: opportunity.imageUrl,
            icon: opportunity.category.chipIcon,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC1B1C19), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _CircleAction(icon: Icons.share, onTap: onShare),
                const SizedBox(width: AppSpacing.sm),
                _CircleAction(
                  icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  onTap: onBookmark,
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt,
                      size: 16, color: AppColors.onSecondaryFixed),
                  const SizedBox(width: 4),
                  Text(
                    'Convocatoria Abierta · Cupos Limitados',
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.onSecondaryFixed),
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

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.onSurface),
        ),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opportunity.title,
            style: AppTextStyles.headlineMobile.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school,
                    size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            opportunity.organization,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleSm,
                          ),
                        ),
                        if (opportunity.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'ONG Aliada Universitaria',
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${opportunity.rating} ★ (${opportunity.reviews} reseñas)',
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecSheet extends StatelessWidget {
  const _SpecSheet({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.event_available,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Detalles de la Convocatoria',
                        style: AppTextStyles.titleSm),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Ciclo 2025-1',
                  style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InfoRow(
            icon: Icons.calendar_month,
            label: 'Días y horario',
            title: opportunity.schedule,
            subtitle: opportunity.startInfo,
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(
            icon: Icons.pin_drop,
            label: 'Modalidad y sede',
            title: opportunity.location,
            subtitle: opportunity.modality,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HoursHighlight(hours: opportunity.hours),
          const SizedBox(height: AppSpacing.sm),
          _SpotsBlock(opportunity: opportunity),
        ],
      ),
    );
  }
}

class _HoursHighlight extends StatelessWidget {
  const _HoursHighlight({required this.hours});

  final int hours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer,
                size: 18, color: AppColors.onSecondaryFixed),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Horas de servicio social',
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.onSurfaceVariant)),
                Text('$hours horas certificadas',
                    style: AppTextStyles.titleMd
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text('Válido UV',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.onSecondaryFixed)),
          ),
        ],
      ),
    );
  }
}

class _SpotsBlock extends StatelessWidget {
  const _SpotsBlock({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.group, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text('Cupos disponibles',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant)),
              const Spacer(),
              Text(
                '${opportunity.spotsLeft} de ${opportunity.spotsTotal} lugares libres',
                style: AppTextStyles.labelMd
                    .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ImpactProgressBar(value: opportunity.spotsTakenRatio, height: 8),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              AvatarStack(images: opportunity.attendees, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ya se sumaron ${opportunity.spotsTotal - opportunity.spotsLeft} compañeros',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Sobre el voluntariado'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          opportunity.description,
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

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.requirements});

  final List<String> requirements;

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
          for (final requirement in requirements)
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

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.benefits});

  final List<Benefit> benefits;

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
          for (final benefit in benefits)
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
                    Icon(benefit.icon, size: 22, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(benefit.title, style: AppTextStyles.titleSm),
                          Text(
                            benefit.subtitle,
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

class _MapCard extends StatelessWidget {
  const _MapCard({required this.opportunity});

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
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo ruta al punto de encuentro')),
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
                    url:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDqMpsyLzYnTcv6sw_5-7TzKVptBUAvA6nUv6rTZR2eOlsv6lEtbZAWKkMagbhVcc7OiJJ6_10UsDf4Slqa3a3Rky4dgErRA4yNQIFC2C_oLgBNMc4OKrSfobwC_lC3KnQ__0UArHRDIyJlbIPzINnJ88ZKPfYPQkAYXzc1LZ9zTe7KhTG_42sMYrPilYXHniWusHDvPblLlEwTECVsCq335fs44iIPFvNglnkx0jLSjYAcRz3-Svde7w',
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
                            opportunity.address.isEmpty
                                ? opportunity.location
                                : opportunity.address,
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

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard();

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
                url:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAODP0A19FjGMKsBCQk7W3YvavOm82tN2yt1g3kA7tEf5wNnkhwbg_9nybrZhgjpQ83puNdg-W0Vz4bJIK6Jp8YB0OoNOqjiqkh8ctO_pL2-jmG323kqeSUV_Qr8Q5gQk32FKqfArTo8ThlkbDm5yCBrWzdAQWzdlhUMXAxCisj5j2KfBqQ13K0kzHR1m9q88qVJvNoWW9J-dkeZzhSn0Xx4rzHr5NBj74ctnp2A6-g_7B_nRQlwO6wmg',
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

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({
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
        boxShadow: [
          BoxShadow(
            color: Color(0x141B254B),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
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
