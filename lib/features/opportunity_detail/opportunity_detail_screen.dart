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

/// Detalle de una oportunidad. Recibe solo el `id` y lee el dato del
/// [ExploreProvider], así siempre muestra la versión más reciente.
class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _confirming = false;

  void _openApplications() {
    final applications = context.read<ApplicationsProvider>();
    var tab = 0;
    for (final application in applications.applications) {
      if (application.opportunityId == widget.opportunityId &&
          !application.estado.esActiva) {
        tab = application.estado.cuentaHoras ? 1 : 2;
        break;
      }
      if (application.opportunityId == widget.opportunityId) break;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MyApplicationsScreen(initialTab: tab, showBackButton: true),
      ),
    );
  }

  Future<void> _share(Opportunity opportunity) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '¡Súmate a ${opportunity.titulo} conmigo en NODARA! Valida ${opportunity.horasEstimadas} horas de servicio social.',
      ),
    );
    if (!mounted) return;
    showAppToast(context, 'Texto copiado al portapapeles', icon: Icons.link);
  }

  Future<void> _toggleBookmark(Opportunity opportunity) async {
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

  Future<void> _apply(Opportunity opportunity) async {
    final applications = context.read<ApplicationsProvider>();
    if (_confirming || !applications.canApply(opportunity.id)) return;
    setState(() => _confirming = true);
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
    setState(() => _confirming = false);
    if (confirmed != true) return;
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

  @override
  Widget build(BuildContext context) {
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

    final isFavorite = context.watch<AuthProvider>().isFavorite(opportunity.id);
    final applications = context.watch<ApplicationsProvider>();
    final hasApplied = applications.hasApplied(opportunity.id);
    VoidCallback? onApply;
    if (!_confirming) {
      if (hasApplied) {
        onApply = _openApplications;
      } else if (applications.canApply(opportunity.id)) {
        onApply = () => _apply(opportunity);
      }
    }

    return Scaffold(
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
            Expanded(
              child: Text('Detalle De Causa', style: AppTextStyles.titleMd),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
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
