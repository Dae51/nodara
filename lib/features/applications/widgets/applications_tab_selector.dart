// Selector que MyApplicationsScreen usa para elegir qué grupo mostrar.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// R3 cambió la tercera pestaña a Cerradas y ajustó texto y contador sobre la base.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Pestañas; _Tab.

import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Emite índices 0, 1 o 2 al padre; recibe la selección y contadores actuales.
class ApplicationsTabSelector extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
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

  /// Devuelve las tres pestañas con sus contadores y callbacks por índice.
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
          // SECCIÓN: Pestañas
          // Cada onTap envía su índice a onChanged del padre; allí setState
          // cambia la selección. Este widget no filtra ni guarda postulaciones.
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
            label: 'Cerradas',
            count: closedCount,
            isSelected: selected == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

/// Dibuja una pestaña con contador; onTap avisa al padre al seleccionarla.
class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.count,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  /// Devuelve una pestaña animada que llama onTap cuando el usuario la toca.
  @override
  Widget build(BuildContext context) {
    // Expanded asigna a cada pestaña la misma parte del ancho disponible.
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
            // Ternario: fondo visible solo para la pestaña seleccionada.
            color: isSelected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          // Wrap permite poner contador y etiqueta en líneas distintas.
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              // El contador siempre se muestra, incluso cuando vale cero.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryFixed
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSm.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
