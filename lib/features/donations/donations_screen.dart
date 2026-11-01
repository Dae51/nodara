import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/core/widgets/section_header.dart';
import 'package:nodara/data/models/donation_point.dart';
import 'package:nodara/features/donations/donation_map_screen.dart';
import 'package:nodara/features/donations/donations_provider.dart';
import 'package:nodara/features/donations/widgets/location_map_view.dart';
import 'package:nodara/features/explore/widgets/filter_chips_row.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Puntos de donación con filtro por causa y botón "Cómo llegar".
class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationsProvider>();
    final errorMessage = provider.error;
    final points = provider.filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        FilterChipsRow(
          selected: provider.selectedCausa,
          onSelected: provider.setCausa,
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(
            title: 'Puntos de donación',
            trailing: Text(
              '${points.length} disponibles',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(child: _buildBody(provider, errorMessage, points)),
      ],
    );
  }

  Widget _buildBody(
    DonationsProvider provider,
    String? errorMessage,
    List<DonationPoint> points,
  ) {
    if (provider.isLoading) return const LoadingView();
    if (errorMessage != null) {
      return ErrorView(message: errorMessage, onRetry: provider.retry);
    }
    if (points.isEmpty) {
      return EmptyView(
        icon: Icons.volunteer_activism,
        message: 'No hay puntos de donación para esta causa.',
        actionLabel: 'Limpiar filtros',
        onAction: () => provider.setCausa(null),
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

  void _openMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DonationMapScreen(point: point)),
    );
  }

  Future<void> _openExternalMaps(BuildContext context) async {
    final launched = await launchUrl(
      point.mapsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      showAppToast(context, 'No se pudo abrir Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _openMap(context),
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
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: LocationMapView(lat: point.lat, lng: point.lng),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMap(context),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver mapa'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openExternalMaps(context),
                  icon: const Icon(Icons.directions),
                  label: const Text('Cómo llegar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
