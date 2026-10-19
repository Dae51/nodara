import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'remote_image.dart';

/// Overlapping circular avatars joined by an optional "+N" counter, matching
/// the "Volunteer Match Avatar Stack" custom component.
///
/// Provide either [images] (photo URLs) or [initials] (letter chips).
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    this.images = const [],
    this.initials = const [],
    this.extra,
    this.size = 24,
    this.ringColor = AppColors.surfaceContainerLowest,
  });

  final List<String> images;
  final List<String> initials;
  final String? extra;
  final double size;
  final Color ringColor;

  static const _initialColors = [
    (AppColors.primaryFixed, AppColors.onPrimaryFixed),
    (AppColors.secondaryFixed, AppColors.onSecondaryFixed),
    (AppColors.tertiaryFixed, AppColors.onTertiaryFixed),
  ];

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < images.length; i++) {
      children.add(_ring(
        RemoteImage(url: images[i], borderRadius: BorderRadius.circular(size)),
      ));
    }

    for (var i = 0; i < initials.length; i++) {
      final (bg, fg) = _initialColors[i % _initialColors.length];
      children.add(_ring(Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: bg,
        child: Text(
          initials[i],
          style: AppTextStyles.labelSm.copyWith(
            color: fg,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      )));
    }

    if (extra != null) {
      children.add(_ring(Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: AppColors.tertiaryFixed,
        child: Text(
          extra!,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onTertiaryFixed,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      )));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    final step = size - 8;
    final width = size + step * (children.length - 1);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < children.length; i++)
            Positioned(
              left: i * step,
              child: children[i],
            ),
        ],
      ),
    );
  }

  Widget _ring(Widget child) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}
