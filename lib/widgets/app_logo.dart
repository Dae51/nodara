import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'remote_image.dart';

/// The NODARA / EcháUnaMano brand lockup used in headers.
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B1C19),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: RemoteImage(
        url: MockAssets.logo,
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
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NODARA',
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'EcháUnaMano',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
