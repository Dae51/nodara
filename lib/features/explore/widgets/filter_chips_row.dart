import 'package:flutter/material.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

/// Chips horizontales de causa. `null` representa "Todos".
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Causa? selected;
  final ValueChanged<Causa?> onSelected;

  static const List<Causa?> _options = [null, ...Causa.values];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final causa = _options[index];
          return _CausaChip(
            causa: causa,
            isSelected: causa == selected,
            onTap: () => onSelected(causa),
          );
        },
      ),
    );
  }
}

class _CausaChip extends StatelessWidget {
  const _CausaChip({
    required this.causa,
    required this.isSelected,
    required this.onTap,
  });

  final Causa? causa;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final current = causa;
    final label = current?.label ?? 'Todos';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: AppShadows.chip,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.onSecondaryContainer,
                  )
                else if (current != null)
                  Icon(current.chipIcon, size: 16, color: AppColors.primary),
                if (isSelected || current != null) const SizedBox(width: 6),
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
