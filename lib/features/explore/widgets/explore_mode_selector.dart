import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

/// Modo visible en la pestaña Explorar.
enum ExploreMode { voluntariados, donar }

/// Selector segmentado "Voluntariados | Donar", con el mismo lenguaje visual
/// de píldoras que los chips de causa.
class ExploreModeSelector extends StatelessWidget {
  const ExploreModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ExploreMode selected;
  final ValueChanged<ExploreMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.chip,
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Voluntariados',
            icon: Icons.groups,
            isSelected: selected == ExploreMode.voluntariados,
            onTap: () => onChanged(ExploreMode.voluntariados),
          ),
          _Segment(
            label: 'Donar',
            icon: Icons.volunteer_activism,
            isSelected: selected == ExploreMode.donar,
            onTap: () => onChanged(ExploreMode.donar),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isSelected
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
