import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/date_format.dart';
import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/avatar_stack.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Tarjeta del feed para una oportunidad.
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
  });

  final Opportunity opportunity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<AuthProvider>().isFavorite(opportunity.id);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              opportunity: opportunity,
              isFavorite: isFavorite,
              onFavorite: () =>
                  context.read<AuthProvider>().toggleFavorite(opportunity.id),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.tituloTarjeta,
                    style: AppTextStyles.titleLg.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MetaRow(
                    icon: Icons.account_balance,
                    text: opportunity.orgNombre,
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(icon: Icons.pin_drop, text: opportunity.ubicacion),
                  const SizedBox(height: 6),
                  _HoursBadge(hours: opportunity.horasEstimadas),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _CardFooter(opportunity: opportunity)),
                      const SizedBox(width: 12),
                      _DetailsButton(onTap: onTap),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.opportunity,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Opportunity opportunity;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(
            url: opportunity.imagenUrl,
            icon: opportunity.causa.chipIcon,
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opportunity.causa.badgeIcon,
                    size: 14,
                    color: AppColors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    opportunity.etiqueta,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Tooltip(
              message: isFavorite ? 'Quitar de favoritos' : 'Guardar en favoritos',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavorite,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Material(
                      color: AppColors.surfaceContainerLowest
                          .withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _HoursBadge extends StatelessWidget {
  const _HoursBadge({required this.hours});

  final int hours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 18, color: AppColors.secondary),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            '$hours hrs acreditables',
            style: AppTextStyles.labelSm
                .copyWith(color: AppColors.onSecondaryContainer),
          ),
        ),
      ],
    );
  }
}

/// Pie de la tarjeta, derivado de los datos:
/// pocos cupos → "N cupos restantes"; jornada → fecha; resto → inscritos.
class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final fecha = opportunity.fechaInicio;
    if (opportunity.cuposLibres <= 5) {
      return _FooterText(
        icon: Icons.groups,
        text: '${opportunity.cuposLibres} cupos restantes',
        color: AppColors.primary,
      );
    }
    if (opportunity.formato == Formato.jornada && fecha != null) {
      return _FooterText(
        icon: Icons.hourglass_bottom,
        text: 'Inicia ${fechaCorta(fecha)}',
        color: AppColors.secondary,
      );
    }
    final mostrados = opportunity.avataresInscritos.take(2).toList();
    final restantes = opportunity.cuposOcupados - mostrados.length;
    return Align(
      alignment: Alignment.centerLeft,
      child: AvatarStack(
        images: mostrados,
        extra: restantes > 0 ? '+$restantes' : null,
        size: 24,
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  const _FooterText({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ver detalles',
            style: AppTextStyles.labelLg.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}
