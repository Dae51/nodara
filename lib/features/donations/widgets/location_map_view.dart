import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:nodara/theme/app_colors.dart';

/// Mapa OpenStreetMap interactivo centrado en una coordenada real.
///
/// Se usa embebido en las tarjetas de donación y en el punto de encuentro
/// del detalle de una oportunidad.
class LocationMapView extends StatelessWidget {
  const LocationMapView({
    super.key,
    required this.lat,
    required this.lng,
    this.initialZoom = 15,
  });

  final double lat;
  final double lng;
  final double initialZoom;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, lng),
        initialZoom: initialZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.nodara',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(lat, lng),
              width: 48,
              height: 48,
              child: const Icon(
                Icons.location_pin,
                size: 44,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
