import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/donation_point.dart';
import 'package:nodara/features/donations/donations_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Puntos de donación. Base para F2 (Josué): filtro por causa, selector
/// Voluntariados | Donar en Explorar y botón "Cómo llegar" con url_launcher
/// usando `DonationPoint.mapsUri`.
class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationsProvider>();
    final errorMessage = provider.error;
    final points = provider.filtered;

    if (provider.isLoading) return const LoadingView();
    if (errorMessage != null) {
      return ErrorView(message: errorMessage, onRetry: provider.retry);
    }
    if (points.isEmpty) {
      return const EmptyView(
        icon: Icons.volunteer_activism,
        message: 'No hay puntos de donación para esta causa.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: points.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _DonationPointCard(point: points[index]),
    );
  }
}

class _DonationPointCard extends StatelessWidget {
  const _DonationPointCard({required this.point});

  final DonationPoint point;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(point.causa.chipIcon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(point.nombre, style: AppTextStyles.titleMd)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Reciben: ${point.aceptan.join(', ')}',
            style: AppTextStyles.bodySm,
          ),
          Text(
            '${point.direccion} · ${point.horario}',
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
