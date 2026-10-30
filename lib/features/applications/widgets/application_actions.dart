import 'package:flutter/material.dart';

import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Botones de la tarjeta según el estado de la postulación.
///
/// Los toasts marcados con TODO son acciones que aún no existen: en F2/F3
/// se implementan o se quitan (regla: nada de botones falsos en la demo).
class ApplicationActions extends StatelessWidget {
  const ApplicationActions({
    super.key,
    required this.application,
    required this.onWithdraw,
  });

  final Application application;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    switch (application.estado) {
      case EstadoPostulacion.aceptado:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _LightButton(
                    icon: Icons.badge,
                    label: 'Ver asistencia y QR',
                    // TODO(F3): implementar o quitar.
                    onTap: () => showAppToast(
                      context,
                      'Mostrando tu código QR de asistencia',
                      icon: Icons.qr_code,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SquareButton(
                  icon: Icons.chat,
                  tooltip: 'Contactar coordinador',
                  // TODO(F3): implementar o quitar.
                  onTap: () => showAppToast(
                    context,
                    'Abriendo chat con el coordinador',
                    icon: Icons.chat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _WithdrawButton(onTap: onWithdraw),
          ],
        );
      case EstadoPostulacion.pendiente:
        return Column(
          children: [
            _LightButton(
              icon: Icons.info_outline,
              label: 'Ver estado de solicitud',
              wide: true,
              onTap: () => showAppToast(
                context,
                'Tu solicitud está en revisión por la organización',
                icon: Icons.pending_actions,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _WithdrawButton(onTap: onWithdraw),
          ],
        );
      case EstadoPostulacion.completado:
        return Row(
          children: [
            Expanded(
              child: _PrimaryButton(
                icon: Icons.download,
                label: 'Descargar constancia oficial',
                // TODO(F5): generar el PDF desde Perfil.
                onTap: () => showAppToast(
                  context,
                  'La constancia se descarga desde tu Perfil',
                  icon: Icons.download_done,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _SquareButton(
              icon: Icons.share,
              tooltip: 'Compartir logro',
              // TODO(F2): implementar o quitar.
              onTap: () =>
                  showAppToast(context, 'Logro compartido', icon: Icons.share),
            ),
          ],
        );
      case EstadoPostulacion.rechazado:
      case EstadoPostulacion.retirado:
        return _LightButton(
          icon: Icons.visibility_outlined,
          label: 'Ver detalle',
          wide: true,
          // TODO(F3): abrir el detalle de la oportunidad.
          onTap: () => showAppToast(
            context,
            'Abriendo detalle del voluntariado',
            icon: Icons.visibility,
          ),
        );
    }
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
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

class _LightButton extends StatelessWidget {
  const _LightButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool wide;

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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return wide ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMd.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
