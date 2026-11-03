import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/impact_progress_bar.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/accreditation/accreditation_dialog.dart';
import 'package:nodara/features/applicants/applicants_screen.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/organization/opportunity_form_screen.dart';
import 'package:nodara/features/organization/organization_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Pantalla principal de la organización: lista de convocatorias propias,
/// gestión de cupos ocupados, creación y edición de convocatorias.
class OrgHomeScreen extends StatelessWidget {
  const OrgHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(body: LoadingView());
    }

    return ChangeNotifierProvider(
      key: ValueKey(user.uid),
      create: (_) => OrganizationProvider(
        opportunities: dependencies.opportunities,
        orgId: user.uid,
      ),
      child: const _OrgHomeView(),
    );
  }
}

class _OrgHomeView extends StatelessWidget {
  const _OrgHomeView();

  void _abrirFormulario(BuildContext context, [Opportunity? opportunity]) {
    final provider = context.read<OrganizationProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: OpportunityFormScreen(opportunity: opportunity),
        ),
      ),
    );
  }

  void _verPostulantes(BuildContext context, String opportunityId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplicantsScreen(
          opportunityId: opportunityId,
          onAccredit: showAccreditationDialog,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nombreOrg = auth.user?.nombre ?? 'Mi Organización';
    final provider = context.watch<OrganizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel de organización · en construcción',
              style: AppTextStyles.labelSm,
            ),
            Text(nombreOrg, style: AppTextStyles.titleMd),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, provider)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva convocatoria'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrganizationProvider provider) {
    if (provider.isLoading) {
      return const LoadingView();
    }

    if (provider.error != null && provider.opportunities.isEmpty) {
      return Center(
        child: ErrorView(message: provider.error ?? 'Ocurrió un error'),
      );
    }

    if (provider.opportunities.isEmpty) {
      return Center(
        child: EmptyView(
          icon: Icons.campaign_outlined,
          message: 'Aún no has publicado convocatorias.\nCrea una nueva convocatoria para comenzar a recibir postulantes.',
          actionLabel: 'Crear convocatoria',
          onAction: () => _abrirFormulario(context),
        ),
      );
    }

    final oportunidades = provider.opportunities;
    final totalCupos = oportunidades.fold<int>(
      0,
      (acc, o) => acc + o.cuposTotal,
    );
    final totalOcupados = oportunidades.fold<int>(
      0,
      (acc, o) => acc + o.cuposOcupados,
    );

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: 88,
      ),
      itemCount: oportunidades.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              color: AppColors.surfaceContainerLow,
              elevated: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ResumenItem(
                    valor: oportunidades.length.toString(),
                    etiqueta: 'Convocatorias',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.outlineVariant,
                  ),
                  _ResumenItem(
                    valor: '$totalOcupados / $totalCupos',
                    etiqueta: 'Cupos ocupados',
                  ),
                ],
              ),
            ),
          );
        }

        final opp = oportunidades[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _OpportunityOrgCard(
            opportunity: opp,
            onEditar: () => _abrirFormulario(context, opp),
            onPostulantes: () => _verPostulantes(context, opp.id),
          ),
        );
      },
    );
  }
}

class _ResumenItem extends StatelessWidget {
  const _ResumenItem({required this.valor, required this.etiqueta});

  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor, style: AppTextStyles.titleLg),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _OpportunityOrgCard extends StatelessWidget {
  const _OpportunityOrgCard({
    required this.opportunity,
    required this.onEditar,
    required this.onPostulantes,
  });

  final Opportunity opportunity;
  final VoidCallback onEditar;
  final VoidCallback onPostulantes;

  @override
  Widget build(BuildContext context) {
    final opp = opportunity;
    final estaVigente = opp.estaVigente();
    final fechaCierre =
        '${opp.cierreInscripcion.day}/${opp.cierreInscripcion.month}/${opp.cierreInscripcion.year}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  opp.etiqueta,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onPrimaryFixed,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estaVigente
                      ? AppColors.surfaceContainerHigh
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  estaVigente ? 'Vigente' : 'Cerrada',
                  style: AppTextStyles.labelSm.copyWith(
                    color: estaVigente
                        ? AppColors.success
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(opp.titulo, style: AppTextStyles.titleMd),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  opp.ubicacion,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Cierre: $fechaCierre',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                '${opp.horasEstimadas} h',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${opp.cuposOcupados} de ${opp.cuposTotal} cupos ocupados',
                style: AppTextStyles.labelMd,
              ),
              Text(
                '${opp.cuposLibres} libres',
                style: AppTextStyles.bodySm.copyWith(
                  color: opp.hayCupos ? AppColors.primary : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ImpactProgressBar(value: opp.ocupacion),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onPostulantes,
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('Postulantes'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
