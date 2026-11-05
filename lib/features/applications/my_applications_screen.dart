// Lista del voluntario, abierta por HomeShell o desde el detalle de convocatoria.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// R3 añadió confirmación, pestaña inicial, regreso y seguimiento del retiro sobre la
// base.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Retiro de postulación; Pestañas y horas; Estados de la interfaz.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/applications/widgets/application_card.dart';
import 'package:nodara/features/applications/widgets/applications_header.dart';
import 'package:nodara/features/applications/widgets/applications_tab_selector.dart';
import 'package:nodara/features/applications/widgets/motivational_banner.dart';
import 'package:nodara/features/applications/widgets/progress_dashboard_card.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Muestra las postulaciones del usuario y delega los cambios a ApplicationsProvider.
class MyApplicationsScreen extends StatefulWidget {
  /// initialTab: 0 Activas, 1 Completadas, 2 Cerradas (assert comprueba el rango).
  /// showBackButton habilita regreso; onOpenNotifications es opcional desde HomeShell.
  const MyApplicationsScreen({
    super.key,
    this.onOpenNotifications,
    this.initialTab = 0,
    this.showBackButton = false,
  }) : assert(initialTab >= 0 && initialTab <= 2);

  // final fija el campo; ? permite que el callback de avisos no exista.
  final VoidCallback? onOpenNotifications;
  final int initialTab;
  final bool showBackButton;

  /// Crea el estado que conserva pestaña y bloqueo del diálogo de retiro.
  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

/// Mantiene solo selección y diálogo; la lista compartida vive en el Provider.
class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  // late evalúa al primer uso, cuando widget ya permite leer la pestaña inicial.
  late int _tab = widget.initialTab;
  bool _confirmingWithdrawal = false;

  // SECCIÓN: Retiro de postulación
  /// Confirma el retiro de application; delega guardar y cambia pestaña solo con éxito.
  Future<void> _withdraw(Application application) async {
    // 1. read obtiene la lógica para esta acción sin suscribir este callback.
    final provider = context.read<ApplicationsProvider>();
    // No abre otro diálogo ni permite retirar mientras hay envío o estado inválido.
    if (_confirmingWithdrawal ||
        provider.isWithdrawing(application.id) ||
        !application.estado.siguientes.contains(EstadoPostulacion.retirado)) {
      return;
    }
    // setState notifica el cambio local; el Provider controla el bloqueo compartido.
    setState(() => _confirmingWithdrawal = true);
    // 2. await espera el diálogo: Volver devuelve false; Sí, retirarme devuelve
    // true mediante Navigator.pop. Cerrar fuera devuelve null y no retira.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Retirarme de la convocatoria'),
        content: Text(
          '¿Seguro que quieres retirarte de "${application.oportunidadTitulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(48, 48),
            ),
            child: const Text('Sí, retirarme'),
          ),
        ],
      ),
    );
    // 3. mounted comprueba que la pantalla sigue viva antes de tocar estado/context.
    if (!mounted) return;
    setState(() => _confirmingWithdrawal = false);
    if (confirmed != true) return;
    // 4. Espera el Repository/DataSource. Al volver comprueba mounted de nuevo.
    // El stream traerá el estado retirado; un error conserva la pestaña actual.
    final ok = await provider.retirar(application);
    if (!mounted) return;
    // 5. Solo éxito selecciona Cerradas. El ternario elige mensaje e icono.
    if (ok) setState(() => _tab = 2);
    showAppToast(
      context,
      ok
          ? 'Te retiraste de la convocatoria'
          : 'No pudimos procesar tu solicitud',
      icon: ok ? Icons.cancel_outlined : Icons.error_outline,
    );
  }

  /// Devuelve encabezado, progreso, pestañas y lista según el estado observado.
  @override
  Widget build(BuildContext context) {
    // watch escucha notifyListeners: cada lista nueva reconstruye esta vista.
    final provider = context.watch<ApplicationsProvider>();
    final user = context.watch<AuthProvider>().user;

    final activas = provider.activas;
    final completadas = provider.completadas;
    final cerradas = provider.cerradas;
    // SECCIÓN: Pestañas y horas
    // switch selecciona el grupo; _ cubre el tercer caso (Cerradas).
    final visible = switch (_tab) {
      0 => activas,
      1 => completadas,
      _ => cerradas,
    };

    return Scaffold(
      appBar: widget.showBackButton
          ? AppBar(title: const Text('Mis postulaciones'))
          : null,
      // SafeArea evita zonas del sistema arriba y a los lados; bottom:false
      // deja el borde inferior a la estructura de navegación que contiene la vista.
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              // Encabezado: ?. lee avatar solo si hay usuario; ?? usa texto vacío.
              // Avisos delega a HomeShell; al venir del detalle no hay callback.
              child: ApplicationsHeader(
                avatarUrl: user?.avatarUrl ?? '',
                onNotifications: widget.onOpenNotifications,
              ),
            ),
            SliverToBoxAdapter(
              child: ApplicationsSubHeader(count: activas.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            // Horas: se muestran solo con meta; los números llegan de getters.
            if (user != null && user.tieneMetaDeHoras)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: ProgressDashboardCard(
                    horasCompletadas: provider.horasCompletadas,
                    horasRequeridas: provider.horasRequeridas,
                    horasFaltantes: provider.horasFaltantes,
                    progreso: provider.progreso,
                    progresoPorcentaje: provider.progresoPorcentaje,
                    activas: activas.length,
                    acreditadas: completadas.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: ApplicationsTabSelector(
                  selected: _tab,
                  activeCount: activas.length,
                  completedCount: completadas.length,
                  closedCount: cerradas.length,
                  // Al pulsar una pestaña recibe 0/1/2 y setState cambia la lista.
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            _ApplicationsSliver(
              isLoading: provider.isLoading,
              error: provider.error,
              applications: visible,
              emptyMessage: _tab == 2
                  ? 'Todavía no tenés postulaciones cerradas.'
                  : 'No hay postulaciones en esta sección.',
              onRetry: provider.retry,
              // Cada tarjeta entrega su Application a la confirmación de retiro.
              onWithdraw: _withdraw,
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: MotivationalBanner(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de postulaciones con sus 4 estados (cargando, error, vacío, datos).
class _ApplicationsSliver extends StatelessWidget {
  /// Recibe carga/error/lista y callbacks: reintentar lectura o retirar un elemento.
  /// required exige proporcionar estos argumentos aunque error admita null.
  const _ApplicationsSliver({
    required this.isLoading,
    required this.error,
    required this.applications,
    required this.emptyMessage,
    required this.onRetry,
    required this.onWithdraw,
  });

  final bool isLoading;
  final String? error;
  final List<Application> applications;
  final String emptyMessage;
  final VoidCallback onRetry;
  final ValueChanged<Application> onWithdraw;

  /// Devuelve un sliver de estado o tarjetas; conecta cada retiro con su elemento.
  @override
  Widget build(BuildContext context) {
    // SECCIÓN: Estados de la interfaz
    // 1. Prioriza carga, luego error y finalmente vacío antes de dibujar tarjetas.
    final errorMessage = error;
    if (isLoading) {
      return const SliverToBoxAdapter(child: LoadingView());
    }
    if (errorMessage != null) {
      return SliverToBoxAdapter(
        child: ErrorView(message: errorMessage, onRetry: onRetry),
      );
    }
    if (applications.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: EmptyView(message: emptyMessage),
          ),
        ),
      );
    }
    // 2. SliverList.builder crea tarjetas a medida que se necesitan al desplazar.
    // SliverToBoxAdapter permite mezclar bloques normales en CustomScrollView.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ApplicationCard(
              application: application,
              // 3. El toque sube desde ApplicationActions hasta _withdraw del padre.
              onWithdraw: () => onWithdraw(application),
            ),
          );
        },
      ),
    );
  }
}
