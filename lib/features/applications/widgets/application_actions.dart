// Botones de ApplicationCard: abrir el detalle o solicitar el retiro.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// R3 conectó navegación y retiro permitido; quitó acciones simuladas de la base.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Ver detalle; Retiro permitido; _WithdrawButton; _LightButton.

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/opportunity_detail/opportunity_detail_screen.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Ofrece acciones según el modelo; delega confirmar el retiro a la pantalla.
class ApplicationActions extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const ApplicationActions({
    super.key,
    required this.application,
    required this.onWithdraw,
  });

  final Application application;
  final VoidCallback onWithdraw;

  /// Devuelve Ver detalle y, si el estado lo permite, el botón de retiro.
  @override
  Widget build(BuildContext context) {
    // watch escucha notifyListeners para deshabilitar el retiro en curso.
    // final conserva la referencia al Provider durante este build.
    final provider = context.watch<ApplicationsProvider>();
    return Column(
      children: [
        // SECCIÓN: Ver detalle
        // Al tocar, push abre una ruta y pasa solo el ID de convocatoria.
        _LightButton(
          icon: Icons.visibility_outlined,
          label: 'Ver detalle',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OpportunityDetailScreen(
                opportunityId: application.opportunityId,
              ),
            ),
          ),
        ),
        // SECCIÓN: Retiro permitido
        // siguientes es un getter del modelo; enCurso no incluye retirado.
        // ... agrega estos widgets a la lista únicamente cuando se permite.
        if (application.estado.siguientes.contains(
          EstadoPostulacion.retirado,
        )) ...[
          const SizedBox(height: AppSpacing.sm),
          _WithdrawButton(
            // Ternario: null bloquea; onWithdraw sube a _withdraw de la pantalla.
            onTap: provider.isWithdrawing(application.id) ? null : onWithdraw,
          ),
        ],
      ],
    );
  }
}

/// Presenta Retirarme; onTap nulo deshabilita el botón durante el retiro.
class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.onTap});

  // ? permite null: OutlinedButton lo interpreta como botón deshabilitado.
  final VoidCallback? onTap;

  /// Devuelve el botón de retiro, habilitado solo si onTap no es null.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        icon: const Icon(Icons.cancel_outlined, size: 18),
        label: Text(
          'Retirarme',
          style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

/// Botón de detalle con icono y etiqueta que ocupa todo el ancho disponible.
class _LightButton extends StatelessWidget {
  const _LightButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Devuelve el botón de ancho completo con etiqueta adaptable.
  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              // Flexible ajusta la etiqueta al espacio que deja el icono.
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return SizedBox(width: double.infinity, child: button);
  }
}
