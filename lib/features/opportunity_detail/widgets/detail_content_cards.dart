// Contenido del detalle: descripción, requisitos, beneficios, mapa y testimonio.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nodara/core/constants/remote_assets.dart';
import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/core/widgets/section_header.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/donations/widgets/location_map_view.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Muestra la descripción recibida y un párrafo fijo heredado del diseño base.
class DetailAboutSection extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const DetailAboutSection({super.key, required this.opportunity});

  final Opportunity opportunity;

  /// Devuelve la descripción de opportunity junto al párrafo fijo de capacitación.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECCIÓN: Descripción
        // El primer párrafo viene del modelo; el segundo es texto fijo de la base.
        const SectionHeader(title: 'Sobre el voluntariado'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          opportunity.descripcion,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'No se requiere experiencia docente previa: te capacitamos durante una sesión inductiva previa para dotarte de dinámicas pedagógicas lúdicas y materiales didácticos listos para usar.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Convierte requisitos en filas informativas; no valida al usuario.
class DetailRequirementsCard extends StatelessWidget {
  const DetailRequirementsCard({super.key, required this.requisitos});

  final List<String> requisitos;

  /// Devuelve una tarjeta con una fila por cada requisito recibido.
  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Requisitos para postular',
            icon: Icons.checklist,
          ),
          const SizedBox(height: AppSpacing.md),
          // SECCIÓN: Requisitos
          // Este for agrega una fila por texto; final fija el valor de cada vuelta.
          for (final requirement in requisitos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Expanded da al requisito el espacio restante junto al check.
                  Expanded(
                    child: Text(requirement, style: AppTextStyles.bodyMd),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Presenta beneficios y traduce iconKey con iconFromKey del equipo.
class DetailBenefitsCard extends StatelessWidget {
  const DetailBenefitsCard({super.key, required this.beneficios});

  final List<Benefit> beneficios;

  /// Devuelve una tarjeta con icono y textos de cada beneficio recibido.
  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Qué te otorgamos',
            icon: Icons.workspace_premium,
            accent: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          // SECCIÓN: Beneficios
          // Cada beneficio trae iconKey, título y subtítulo desde el modelo.
          for (final benefit in beneficios)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      iconFromKey(benefit.iconKey),
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(benefit.titulo, style: AppTextStyles.titleSm),
                          Text(
                            benefit.subtitulo,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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

/// Muestra coordenadas en LocationMapView y permite abrir Google Maps.
class DetailMapCard extends StatelessWidget {
  const DetailMapCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  // SECCIÓN: Ruta al punto de encuentro
  /// Construye una URL con las coordenadas y delega abrirla a url_launcher.
  /// Recibe context para avisar si devuelve false; el Future no devuelve datos.
  Future<void> _openRoute(BuildContext context) async {
    // 1. Usa lat/lng de esta convocatoria para buscar el punto en Google Maps.
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${opportunity.lat},${opportunity.lng}',
    );
    // 2. await espera la respuesta al abrir una aplicación externa.
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    // 3. Avisa solo si no se abrió y context sigue montado tras la espera.
    if (!launched && context.mounted) {
      showAppToast(context, 'No se pudo abrir Google Maps');
    }
  }

  /// Devuelve dirección, mapa compartido y botón que llama a _openRoute.
  @override
  Widget build(BuildContext context) {
    // Ternario: usa ubicación como alternativa cuando no se recibió dirección.
    final direccion = opportunity.direccion.isEmpty
        ? opportunity.ubicacion
        : opportunity.direccion;

    return AppCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Punto de Encuentro',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                // El toque en Ver ruta inicia la apertura externa de coordenadas.
                onPressed: () => _openRoute(context),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Ver ruta'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              // El mapa embebido es un componente compartido del módulo Donaciones.
              child: LocationMapView(
                lat: opportunity.lat,
                lng: opportunity.lng,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(child: Text(direccion, style: AppTextStyles.labelSm)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Presenta un testimonio fijo de la base, sin consulta al Repository.
class DetailTestimonialCard extends StatelessWidget {
  /// Crea este componente visual sin datos externos.
  const DetailTestimonialCard({super.key});

  /// Devuelve avatar, nombre y testimonio fijos de la base.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // SECCIÓN: Testimonio
              // Avatar y texto son fijos; no son una reseña leída desde Firestore.
              const RemoteImage(
                url: RemoteAssets.testimonialAvatar,
                width: 40,
                height: 40,
                icon: Icons.person,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mateo Benítez', style: AppTextStyles.titleSm),
                    Text(
                      'Estudiante de Ing. Civil · Voluntario 2024',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.format_quote,
                size: 32,
                color: Color(0x33093DB2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"Fue la experiencia más gratificante del semestre. Ver la cara de alivio de los chicos cuando finalmente entendían una ecuación no tiene precio. Además, el trámite de las horas en la facultad fue automático."',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
