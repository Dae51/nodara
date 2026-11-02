import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/opportunity_detail/opportunity_detail_screen.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Acciones disponibles según las transiciones del modelo.
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
    final provider = context.watch<ApplicationsProvider>();
    return Column(
      children: [
        _LightButton(
          icon: Icons.visibility_outlined,
          label: 'Ver detalle',
          wide: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OpportunityDetailScreen(
                opportunityId: application.opportunityId,
              ),
            ),
          ),
        ),
        if (application.estado.siguientes.contains(
          EstadoPostulacion.retirado,
        )) ...[
          const SizedBox(height: AppSpacing.sm),
          _WithdrawButton(
            onTap: provider.isWithdrawing(application.id) ? null : onWithdraw,
          ),
        ],
      ],
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.onTap});

  final VoidCallback? onTap;

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
    return wide ? SizedBox(width: double.infinity, child: button) : button;
  }
}
