import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/toast.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/core/widgets/section_header.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/explore/explore_provider.dart';
import 'package:nodara/features/explore/widgets/civic_search_bar.dart';
import 'package:nodara/features/explore/widgets/explore_greeting.dart';
import 'package:nodara/features/explore/widgets/filter_chips_row.dart';
import 'package:nodara/features/explore/widgets/goal_banner.dart';
import 'package:nodara/features/explore/widgets/opportunity_card.dart';
import 'package:nodara/features/opportunity_detail/opportunity_detail_screen.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.onOpenApplications});

  final VoidCallback? onOpenApplications;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Opportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OpportunityDetailScreen(opportunityId: opportunity.id),
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ExploreProvider>().clearFilters();
  }

  void _showFilterInfo() {
    // F2 (Josué): reemplazar por la hoja de filtros (formato, horas,
    // departamento) con showModalBottomSheet.
    showAppToast(context, 'Filtros avanzados disponibles pronto', icon: Icons.tune);
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final applications = context.watch<ApplicationsProvider>();
    final user = context.watch<AuthProvider>().user;
    final opportunities = explore.filtered;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ExploreGreeting(
                nombre: user?.nombre ?? '',
                avatarUrl: user?.avatarUrl ?? '',
                nivel: applications.nivel,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: CivicSearchBar(
                  controller: _searchController,
                  onChanged: explore.setSearchQuery,
                  onFilterTap: _showFilterInfo,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverToBoxAdapter(
              child: FilterChipsRow(
                selected: explore.selectedCausa,
                onSelected: explore.setCausa,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: SectionHeader(
                  title: 'Oportunidades Destacadas',
                  trailing: Text(
                    '${opportunities.length} disponibles',
                    style:
                        AppTextStyles.labelSm.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            _OpportunitiesSliver(
              isLoading: explore.isLoading,
              error: explore.error,
              opportunities: opportunities,
              onRetry: explore.retry,
              onClearFilters: _clearFilters,
              onOpen: _openDetail,
            ),
            if (user != null && user.tieneMetaDeHoras)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: GoalBanner(
                    porcentaje: applications.progresoPorcentaje,
                    horasFaltantes: applications.horasFaltantes,
                    onTap: () => widget.onOpenApplications?.call(),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          ],
        ),
      ),
    );
  }
}

/// Lista del feed con sus 4 estados: cargando, error, vacío y datos.
/// Usa `SliverList.builder` (regla del curso: nada de `ListView(children:)`
/// con datos de una base de datos).
class _OpportunitiesSliver extends StatelessWidget {
  const _OpportunitiesSliver({
    required this.isLoading,
    required this.error,
    required this.opportunities,
    required this.onRetry,
    required this.onClearFilters,
    required this.onOpen,
  });

  final bool isLoading;
  final String? error;
  final List<Opportunity> opportunities;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;
  final ValueChanged<Opportunity> onOpen;

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
    if (opportunities.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyView(
          icon: Icons.search_off,
          message: 'No encontramos voluntariados para tu búsqueda.',
          actionLabel: 'Limpiar filtros',
          onAction: onClearFilters,
        ),
      );
    }
    return SliverList.builder(
      itemCount: opportunities.length,
      itemBuilder: (context, index) {
        final opportunity = opportunities[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: OpportunityCard(
            opportunity: opportunity,
            onTap: () => onOpen(opportunity),
          ),
        );
      },
    );
  }
}
