import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../models/student_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_search_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/remote_image.dart';
import '../widgets/section_header.dart';

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
    Navigator.of(context).pushNamed('/detail', arguments: opportunity);
  }

  void _showFilterInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros avanzados disponibles pronto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final opportunities = state.filteredOpportunities;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: [
            _Greeting(profile: state.profile),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: CivicSearchBar(
                controller: _searchController,
                onChanged: state.setSearchQuery,
                onFilterTap: _showFilterInfo,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilterChipsRow(
              selected: state.selectedCategory,
              onSelected: state.setCategory,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: SectionHeader(
                title: 'Oportunidades Destacadas',
                trailing: Text(
                  '${opportunities.length} disponibles',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
            if (opportunities.isEmpty)
              _EmptyState(query: state.searchQuery)
            else
              for (final opportunity in opportunities)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
                  child: OpportunityCard(
                    opportunity: opportunity,
                    onTap: () => _openDetail(opportunity),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _GoalBanner(
                onTap: () {
                  widget.onOpenApplications?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sumá 15 horas más para validar tu crédito social'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '¡Hola, ${profile.name}!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineMobile.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '¿Dónde querés dejar tu huella hoy?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _AvatarBadge(
            avatarUrl: profile.avatarUrl,
            level: profile.level,
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.avatarUrl, required this.level});

  final String avatarUrl;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x59FED346),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: RemoteImage(
            url: avatarUrl,
            width: 52,
            height: 52,
            icon: Icons.person,
            borderRadius: BorderRadius.circular(52),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium,
                    size: 11, color: Colors.white),
                const SizedBox(width: 2),
                Text(
                  'Nv. $level',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No encontramos voluntariados para tu búsqueda.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _GoalBanner extends StatelessWidget {
  const _GoalBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryFixed.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Meta semestral al 70%!',
                      style: AppTextStyles.titleSm
                          .copyWith(color: AppColors.onPrimaryFixed),
                    ),
                    Text(
                      'Sumá 15 horas más para validar tu crédito social.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
