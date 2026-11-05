// Muestra una convocatoria desde ExploreProvider; la abren Explorar y Ver detalle.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// R3 añadió confirmación, reintento y navegación a Mis postulaciones sobre la pantalla
// base.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Estados de la interfaz; Confirmación de postulación; Navegación; Favoritos y
// compartir.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/app_logo.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/features/applications/my_applications_screen.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/explore/explore_provider.dart';
import 'package:nodara/features/opportunity_detail/widgets/apply_bar.dart';
import 'package:nodara/features/opportunity_detail/widgets/detail_content_cards.dart';
import 'package:nodara/features/opportunity_detail/widgets/detail_hero.dart';
import 'package:nodara/features/opportunity_detail/widgets/detail_info_cards.dart';
import 'package:nodara/theme/app_theme.dart';

/// Recibe un ID y consulta la lista vigente de ExploreProvider.
/// Si ya no está en esa lista, muestra no disponible; no consulta por ID a Firebase.
class OpportunityDetailScreen extends StatefulWidget {
  /// required exige opportunityId; final conserva ese ID en esta instancia.
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  /// Crea el estado local que controla si el diálogo está abierto.
  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

/// Coordina confirmaciones y navegación; delega datos y escrituras a los providers.
class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _confirming = false;

  // SECCIÓN: Navegación a Mis postulaciones
  /// Abre la lista con la pestaña de la primera coincidencia y permite regresar.
  void _openApplications() {
    // read obtiene el Provider sin observar cambios; se usa al ejecutar la acción.
    // final impide reasignar esta referencia local.
    final applications = context.read<ApplicationsProvider>();
    // 1. Activas = 0; el ternario elige Completadas = 1 o Cerradas = 2.
    var tab = 0;
    for (final application in applications.applications) {
      if (application.opportunityId != widget.opportunityId) continue;
      if (!application.estado.esActiva) {
        tab = application.estado.cuentaHoras ? 1 : 2;
      }
      break;
    }
    // 2. push agrega una pantalla a la pila; Volver recupera este detalle.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MyApplicationsScreen(initialTab: tab, showBackButton: true),
      ),
    );
  }

  // SECCIÓN: Favoritos y compartir
  /// Copia un texto de opportunity al portapapeles y avisa al terminar; no retorna
  /// datos.
  Future<void> _share(Opportunity opportunity) async {
    // await espera al portapapeles; mounted evita usar una pantalla ya cerrada.
    await Clipboard.setData(
      ClipboardData(
        text:
            '¡Súmate a ${opportunity.titulo} conmigo en NODARA! Valida ${opportunity.horasEstimadas} horas de servicio social.',
      ),
    );
    // Si se cerró la pantalla durante la espera, ya no debe mostrar avisos.
    if (!mounted) return;
    showAppToast(context, 'Texto copiado al portapapeles', icon: Icons.link);
  }

  /// Delega el favorito a AuthProvider y usa su bool para elegir el mensaje.
  Future<void> _toggleBookmark(Opportunity opportunity) async {
    // Espera el cambio del favorito; comprueba mounted antes de usar context.
    final added = await context.read<AuthProvider>().toggleFavorite(
      opportunity.id,
    );
    if (!mounted) return;
    showAppToast(
      context,
      added
          ? 'Guardado en tus oportunidades favoritas'
          : 'Eliminado de tus guardados',
      icon: added ? Icons.bookmark_added : Icons.bookmark_remove,
    );
  }

  // SECCIÓN: Confirmación de postulación
  /// Pide confirmar opportunity y delega el envío al Provider; muestra su resultado.
  Future<void> _apply(Opportunity opportunity) async {
    final applications = context.read<ApplicationsProvider>();
    // 1. Evita dos diálogos. El Provider también bloquea escrituras repetidas.
    if (_confirming || !applications.canApply(opportunity.id)) return;
    // setState reconstruye esta pantalla al cambiar el bloqueo local del diálogo.
    setState(() => _confirming = true);
    // 2. await espera la respuesta. Cancelar devuelve false, Confirmar true
    // y cerrar tocando fuera devuelve null; solo true autoriza guardar.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar postulación'),
        content: Text('¿Quieres postularte a "${opportunity.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    // 3. Tras comprobar mounted, libera el diálogo; el bloqueo de envío
    // pertenece al Provider y dura hasta recibir el stream o fallar la escritura.
    setState(() => _confirming = false);
    if (confirmed != true) return;
    // 4. Espera el guardado. mounted vuelve a comprobarse porque el usuario
    // pudo salir mientras esperaba; solo entonces se muestra el mensaje.
    final ok = await applications.postular(opportunity);
    if (!mounted) return;
    showAppToast(
      context,
      ok
          ? 'Postulación enviada a la organización.'
          : 'No pudimos enviar tu postulación. Intenta de nuevo.',
      icon: ok ? Icons.celebration : Icons.error_outline,
    );
  }

  /// Construye el detalle o su estado de carga/error/vacío con providers observados.
  @override
  Widget build(BuildContext context) {
    // SECCIÓN: Estados de la interfaz
    // watch reconstruye build cuando el Provider llama notifyListeners.
    // 1. Resuelve carga, error con reintento y convocatoria no disponible.
    final explore = context.watch<ExploreProvider>();
    if (explore.isLoading) {
      return Scaffold(appBar: AppBar(), body: const LoadingView());
    }
    final error = explore.error;
    if (error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: error,
          // Reintentar vuelve a suscribirse; setState refleja la carga inicial.
          onRetry: () {
            context.read<ExploreProvider>().retry();
            setState(() {});
          },
        ),
      );
    }
    final opportunity = explore.byId(widget.opportunityId);
    if (opportunity == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(
          icon: Icons.event_busy,
          message: 'Esta convocatoria ya no está disponible.',
        ),
      );
    }

    // 2. Observa favoritos y postulaciones para actualizar iconos y barra inferior.
    final isFavorite = context.watch<AuthProvider>().isFavorite(opportunity.id);
    final applications = context.watch<ApplicationsProvider>();
    final hasApplied = applications.hasApplied(opportunity.id);
    // ? permite null: sin callback el botón queda deshabilitado.
    // 3. Con postulación navega; sin ella abre confirmación si puede enviar.
    VoidCallback? onApply;
    if (!_confirming) {
      if (hasApplied) {
        onApply = _openApplications;
      } else if (applications.canApply(opportunity.id)) {
        onApply = () => _apply(opportunity);
      }
    }

    return Scaffold(
      // SECCIÓN: Encabezado y regreso
      // Volver usa maybePop: regresa si existe una ruta anterior.
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            const AppLogo(markSize: 32, showWordmark: false),
            const SizedBox(width: AppSpacing.sm),
            // Expanded da al título el espacio restante junto al logo.
            Expanded(
              child: Text('Detalle De Causa', style: AppTextStyles.titleMd),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // SECCIÓN: Imagen y acciones
          // Estos callbacks se ejecutan al tocar los botones de DetailHero.
          DetailHero(
            opportunity: opportunity,
            isFavorite: isFavorite,
            onShare: () => _share(opportunity),
            onBookmark: () => _toggleBookmark(opportunity),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECCIÓN: Información de convocatoria
                // Orden visual: título, horario/horas, descripción, requisitos,
                // beneficios, mapa y testimonio fijo de la base.
                DetailTitleCard(opportunity: opportunity),
                const SizedBox(height: AppSpacing.lg),
                DetailSpecSheet(opportunity: opportunity),
                const SizedBox(height: AppSpacing.lg),
                DetailAboutSection(opportunity: opportunity),
                const SizedBox(height: AppSpacing.lg),
                DetailRequirementsCard(requisitos: opportunity.requisitos),
                const SizedBox(height: AppSpacing.lg),
                DetailBenefitsCard(beneficios: opportunity.beneficios),
                const SizedBox(height: AppSpacing.lg),
                DetailMapCard(opportunity: opportunity),
                const SizedBox(height: AppSpacing.lg),
                const DetailTestimonialCard(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
      // SECCIÓN: Barra de postulación
      // Error de postulaciones tiene su propio reintento. SafeArea separa
      // el mensaje de las zonas del sistema; ?? usa texto vacío si falta error.
      bottomNavigationBar: applications.error != null
          ? SafeArea(
              child: ErrorView(
                message: applications.error ?? '',
                onRetry: () => context.read<ApplicationsProvider>().retry(),
              ),
            )
          : ApplyBar(
              hours: opportunity.horasEstimadas,
              hasApplied: hasApplied,
              isBusy:
                  applications.isLoading ||
                  applications.isSubmitting(opportunity.id),
              onApply: onApply,
            ),
    );
  }
}
