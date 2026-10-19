import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// "Impact Progress Bar": pill track, primary bar that turns amber at 100%.
class ImpactProgressBar extends StatelessWidget {
  const ImpactProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.background,
  });

  /// Progress in the 0..1 range.
  final double value;
  final double height;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: height,
        color: background ?? AppColors.surfaceContainerHighest,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clamped == 0 ? 0.001 : clamped,
          child: Container(
            decoration: BoxDecoration(
              color: clamped >= 1 ? AppColors.secondaryContainer : null,
              gradient: clamped >= 1
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
