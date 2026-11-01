import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/data/models/donation_point.dart';
import 'package:nodara/features/donations/widgets/location_map_view.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Mapa interactivo a pantalla completa para un punto de donación.
///
/// Muestra la ubicación real (lat/lng) sobre OpenStreetMap con un marcador,
/// el nombre y la dirección del punto, y un acceso directo a Google Maps.
class DonationMapScreen extends StatelessWidget {
  const DonationMapScreen({super.key, required this.point});

  final DonationPoint point;

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(point.nombre, style: AppTextStyles.titleMd),
      ),
      body: Stack(
        children: [
          LocationMapView(lat: point.lat, lng: point.lng),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: AppCard(
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(point.nombre, style: AppTextStyles.titleSm),
                        Text(
                          '${point.direccion} · ${point.departamento}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () => _openExternalMaps(context),
                    child: const Text('Cómo llegar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
