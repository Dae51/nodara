import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Pestañas Activas / Completadas / Historial (rechazadas y retiradas).
class ApplicationsTabSelector extends StatelessWidget {
  const ApplicationsTabSelector({
    super.key,
    required this.selected,
    required this.activeCount,
    required this.completedCount,
    required this.closedCount,
    required this.onChanged,
  });

  final int selected;
  final int activeCount;
  final int completedCount;
  final int closedCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Activas',
            count: activeCount,
            isSelected: selected == 0,
            onTap: () => onChanged(0),
          ),
          _Tab(
            label: 'Completadas',
            count: completedCount,
            isSelected: selected == 1,
            onTap: () => onChanged(1),
          ),
          _Tab(
            label: 'Historial',
            count: closedCount,
            isSelected: selected == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text('$count',
                      style: AppTextStyles.labelSm.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
