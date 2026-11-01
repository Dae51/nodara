import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/widgets/section_header.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/explore/explore_provider.dart';
import 'package:nodara/theme/app_theme.dart';

/// Abre la hoja de filtros avanzados de Explorar.
///
/// Los filtros se aplican en vivo; "Aplicar" solo cierra la hoja.
Future<void> showExploreFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _ExploreFilterSheet(),
    );

class _ExploreFilterSheet extends StatelessWidget {
  const _ExploreFilterSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionHeader(title: 'Filtros'),
          const SizedBox(height: AppSpacing.md),

          const SectionHeader(title: 'Formato'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final formato in Formato.values)
                FilterChip(
                  label: Text(formato.label),
                  selected: provider.selectedFormatos.contains(formato),
                  onSelected: (_) => provider.toggleFormato(formato),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: 'Horas estimadas'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final franja in FranjaHoras.values)
                ChoiceChip(
                  label: Text(franja.label),
                  selected: provider.selectedHoras == franja,
                  onSelected: (selected) =>
                      provider.setHoras(selected ? franja : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: 'Departamento'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final departamento in kDepartamentos)
                ChoiceChip(
                  label: Text(departamento),
                  selected: provider.selectedDepartamento == departamento,
                  onSelected: (selected) =>
                      provider.setDepartamento(selected ? departamento : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: provider.clearFilters,
                  child: const Text('Limpiar filtros'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
