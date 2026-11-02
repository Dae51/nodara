import 'package:flutter/material.dart';

import 'package:nodara/core/widgets/app_logo.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

class ApplicationsHeader extends StatelessWidget {
  const ApplicationsHeader({
    super.key,
    required this.avatarUrl,
    this.onNotifications,
  });

  final String avatarUrl;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const AppLogo(markSize: 36, showWordmark: false),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NODARA',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text('Mis Postulaciones', style: AppTextStyles.titleMd),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onNotifications != null)
            IconButton(
              tooltip: 'Notificaciones',
              onPressed: onNotifications,
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          RemoteImage(
            url: avatarUrl,
            width: 32,
            height: 32,
            icon: Icons.person,
            borderRadius: BorderRadius.circular(32),
          ),
        ],
      ),
    );
  }
}

class ApplicationsSubHeader extends StatelessWidget {
  const ApplicationsSubHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text('Mis Postulaciones', style: AppTextStyles.headlineSm),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
