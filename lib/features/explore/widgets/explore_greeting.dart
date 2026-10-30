import 'package:flutter/material.dart';

import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

/// Saludo con avatar y nivel de impacto.
class ExploreGreeting extends StatelessWidget {
  const ExploreGreeting({
    super.key,
    required this.nombre,
    required this.avatarUrl,
    required this.nivel,
  });

  final String nombre;
  final String avatarUrl;
  final int nivel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '¡Hola, $nombre!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineMobile.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '¿Dónde querés dejar tu huella hoy?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _AvatarBadge(
            avatarUrl: avatarUrl,
            level: nivel,
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.avatarUrl, required this.level});

  final String avatarUrl;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: AppShadows.avatarGlow,
          ),
          child: RemoteImage(
            url: avatarUrl,
            width: 52,
            height: 52,
            icon: Icons.person,
            borderRadius: BorderRadius.circular(52),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium,
                    size: 11, color: Colors.white),
                const SizedBox(width: 2),
                Text(
                  'Nv. $level',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
