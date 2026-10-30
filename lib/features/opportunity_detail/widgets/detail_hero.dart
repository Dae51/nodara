import 'package:flutter/material.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
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
            url: opportunity.imagenUrl,
            icon: opportunity.causa.chipIcon,
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
