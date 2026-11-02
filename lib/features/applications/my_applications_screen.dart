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

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({
    super.key,
    this.onOpenNotifications,
    this.initialTab = 0,
    this.showBackButton = false,
  }) : assert(initialTab >= 0 && initialTab <= 2);

  final VoidCallback? onOpenNotifications;
  final int initialTab;
  final bool showBackButton;

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late int _tab = widget.initialTab;
  bool _confirmingWithdrawal = false;

  Future<void> _withdraw(Application application) async {
    final provider = context.read<ApplicationsProvider>();
    if (_confirmingWithdrawal ||
        provider.isWithdrawing(application.id) ||
        !application.estado.siguientes.contains(EstadoPostulacion.retirado)) {
      return;
    }
    setState(() => _confirmingWithdrawal = true);
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
    if (!mounted) return;
    setState(() => _confirmingWithdrawal = false);
    if (confirmed != true) return;
    final ok = await provider.retirar(application);
    if (!mounted) return;
    if (ok) setState(() => _tab = 2);
    showAppToast(
      context,
      ok
          ? 'Te retiraste de la convocatoria'
          : 'No pudimos procesar tu solicitud',
      icon: ok ? Icons.cancel_outlined : Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationsProvider>();
    final user = context.watch<AuthProvider>().user;

    final activas = provider.activas;
    final completadas = provider.completadas;
    final cerradas = provider.cerradas;
    final visible = switch (_tab) {
      0 => activas,
      1 => completadas,
      _ => cerradas,
    };

    return Scaffold(
      appBar: widget.showBackButton
          ? AppBar(title: const Text('Mis postulaciones'))
          : null,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ApplicationsHeader(
                avatarUrl: user?.avatarUrl ?? '',
                onNotifications: widget.onOpenNotifications,
              ),
            ),
            SliverToBoxAdapter(
              child: ApplicationsSubHeader(count: activas.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
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

  @override
  Widget build(BuildContext context) {
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
              onWithdraw: () => onWithdraw(application),
            ),
          );
        },
      ),
    );
  }
}
