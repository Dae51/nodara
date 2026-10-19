import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'avatar_stack.dart';
import 'remote_image.dart';

/// Explore-feed card for a volunteering opportunity.
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
    final state = AppScope.of(context);
    final isFavorite = state.isFavorite(opportunity.id);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              opportunity: opportunity,
              isFavorite: isFavorite,
              onFavorite: () => state.toggleFavorite(opportunity.id),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.cardTitle ?? opportunity.title,
                    style: AppTextStyles.titleLg.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MetaRow(
                    icon: Icons.account_balance,
                    text: opportunity.organization,
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(icon: Icons.pin_drop, text: opportunity.location),
                  const SizedBox(height: 6),
                  _HoursBadge(hours: opportunity.hours),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _Footer(opportunity: opportunity)),
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

class _Header extends StatelessWidget {
  const _Header({
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
            url: opportunity.imageUrl,
            icon: opportunity.category.chipIcon,
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opportunity.category.badgeIcon ?? Icons.category,
                    size: 14,
                    color: AppColors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    opportunity.badgeLabel,
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
            top: 12,
            right: 12,
            child: Material(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavorite,
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
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.onSurfaceVariant),
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

class _Footer extends StatelessWidget {
  const _Footer({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    switch (opportunity.cardFooter) {
      case OpportunityCardFooter.attendees:
        return AvatarStack(
          initials: const ['MJ', 'LA'],
          extra: '+6',
          size: 24,
        );
      case OpportunityCardFooter.spotsLeft:
        return Row(
          children: [
            const Icon(Icons.groups, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                opportunity.spotsNote ?? '${opportunity.spotsLeft} cupos restantes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        );
      case OpportunityCardFooter.startsSoon:
        return Row(
          children: [
            const Icon(Icons.hourglass_bottom,
                size: 16, color: AppColors.secondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                opportunity.spotsNote ?? opportunity.startInfo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        );
    }
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          minimumSize: const Size(0, 44),
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
      ),
    );
  }
}
