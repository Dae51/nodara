import 'package:flutter/material.dart';

import 'package:nodara/core/constants/remote_assets.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';
import 'package:nodara/core/widgets/remote_image.dart';

/// Logo de NODARA usado en los encabezados.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.markSize = 40, this.showWordmark = true});

  final double markSize;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: markSize,
      height: markSize,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.logo,
      ),
      child: RemoteImage(
        url: RemoteAssets.logo,
        icon: Icons.volunteer_activism,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: AppSpacing.sm),
        Text(
          'NODARA',
          style: AppTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
