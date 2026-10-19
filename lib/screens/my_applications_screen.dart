import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/application.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/remote_image.dart';
import '../widgets/stat_pill.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  int _tab = 0;

  void _toast(String message, {IconData icon = Icons.check_circle}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel(Application application) async {
    final state = AppScope.of(context);
    final name =
        application.opportunity.cardTitle ?? application.opportunity.title;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar postulación'),
        content: Text(
          '¿Seguro que querés cancelar tu postulación a "$name"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    state.cancelApplication(application);
    _toast('Postulación cancelada', icon: Icons.cancel_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final profile = state.profile;

    final tab0 = state.applications
        .where((a) =>
            a.status == ApplicationStatus.selected ||
            a.status == ApplicationStatus.pending)
        .toList();
    final tab1 = state.applications
        .where((a) => a.status == ApplicationStatus.completed)
        .toList();
    final tab2 = state.applications
        .where((a) => a.status == ApplicationStatus.history)
        .toList();

    final visible = switch (_tab) {
      0 => tab0,
      1 => tab1,
      _ => tab2,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: [
            _Header(
              avatarUrl: profile.avatarUrl,
              onNotifications: () =>
                  _toast('No tenés notificaciones nuevas', icon: Icons.notifications_none),
            ),
            _SubHeader(
              count: tab0.length,
              onFilter: () => _toast('Filtros de postulaciones próximamente', icon: Icons.tune),
              onHelp: () => _toast('Guía de acreditación de horas', icon: Icons.help_outline),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  _DashboardCard(state: state),
                  const SizedBox(height: AppSpacing.lg),
                  _TabSelector(
                    selected: _tab,
                    activeCount: tab0.length,
                    completedCount: tab1.length,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (visible.isEmpty)
                    _EmptyTab(tab: _tab)
                  else
                    for (final application in visible)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ApplicationCard(
                          application: application,
                          onToast: _toast,
                          onCancel: () => _cancel(application),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.sm),
                  const _MotivationalBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.avatarUrl, required this.onNotifications});

  final String avatarUrl;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Row(
            children: [
              const AppLogo(markSize: 36, showWordmark: false),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NODARA',
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.primary)),
                  Text('Mis Postulaciones', style: AppTextStyles.titleMd),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none,
                color: AppColors.onSurfaceVariant),
          ),
          RemoteImage(
            url: avatarUrl,
            width: 32,
            height: 32,
            icon: Icons.person,
            borderRadius: BorderRadius.circular(32),
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader({
    required this.count,
    required this.onFilter,
    required this.onHelp,
  });

  final int count;
  final VoidCallback onFilter;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text('Mis Postulaciones', style: AppTextStyles.headlineSm),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text('$count',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.primary)),
          ),
          const Spacer(),
          IconButton(
            onPressed: onFilter,
            icon: const Icon(Icons.tune,
                size: 20, color: AppColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline,
                size: 20, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.workspace_premium,
              size: 72,
              color: AppColors.onSecondaryContainer.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'PROGRESO UNIVERSITARIO',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSecondaryContainer,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school,
                            size: 14, color: AppColors.onSecondaryFixed),
                        const SizedBox(width: 4),
                        Text('Servicio Social',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.onSecondaryFixed)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${profile.completedHours}',
                    style: AppTextStyles.displayLg
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '/ ${profile.requiredHours}',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('horas',
                      style: AppTextStyles.titleSm
                          .copyWith(color: AppColors.onSecondaryContainer)),
                ],
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  text: 'Horas de Servicio Social Acumuladas ',
                  children: [
                    TextSpan(
                      text:
                          '(${profile.progressPercent}% del requisito completado)',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.onSecondaryContainer),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  height: 10,
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: profile.progress == 0 ? 0.001 : profile.progress,
                      child: Container(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const StatPill(
                    label: '3 Proyectos activos',
                    showDot: true,
                    background: AppColors.surfaceContainerLowest,
                    foreground: AppColors.onSurface,
                    bold: false,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  const StatPill(
                    label: '2 Acreditados',
                    icon: Icons.verified,
                    background: AppColors.surfaceContainerLowest,
                    foreground: AppColors.onSurface,
                    bold: false,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  StatPill(
                    label: 'Faltan ${profile.remainingHours} hrs',
                    background:
                        AppColors.onSecondaryContainer.withValues(alpha: 0.1),
                    foreground: AppColors.onSecondaryContainer,
                    bold: false,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.selected,
    required this.activeCount,
    required this.completedCount,
    required this.onChanged,
  });

  final int selected;
  final int activeCount;
  final int completedCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Activas',
            count: activeCount,
            isSelected: selected == 0,
            onTap: () => onChanged(0),
          ),
          _Tab(
            label: 'Completadas',
            count: completedCount,
            isSelected: selected == 1,
            onTap: () => onChanged(1),
          ),
          _Tab(
            label: 'Historial',
            isSelected: selected == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text('$count',
                      style: AppTextStyles.labelSm.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.tab});

  final int tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: AppColors.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tab == 2
                ? 'Todavía no tenés postulaciones en tu historial.'
                : 'No hay postulaciones en esta sección.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onToast,
    required this.onCancel,
  });

  final Application application;
  final void Function(String message, {IconData icon}) onToast;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B254B),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x0A3157CB),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _StatusBadge(status: application.status)),
              const SizedBox(width: AppSpacing.sm),
              _RewardPill(application: application),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RemoteImage(
                url: applicationThumbnail(application.opportunity.id),
                width: 56,
                height: 56,
                icon: application.opportunity.category.chipIcon,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.opportunity.cardTitle ??
                          application.opportunity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMd,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          application.status == ApplicationStatus.pending
                              ? Icons.nature_people
                              : application.status == ApplicationStatus.completed
                                  ? Icons.volunteer_activism
                                  : Icons.apartment,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            application.opportunity.organization,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoBox(application: application),
          const SizedBox(height: AppSpacing.sm),
          _Actions(
            application: application,
            onToast: onToast,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg) = switch (status) {
      ApplicationStatus.selected => (
          'Seleccionado / En curso',
          Icons.autorenew,
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
        ),
      ApplicationStatus.pending => (
          'Pendiente de aprobación',
          Icons.hourglass_top,
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
        ),
      ApplicationStatus.completed => (
          'Finalizado y Acreditado',
          Icons.check_circle,
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary,
        ),
      ApplicationStatus.history => (
          'Historial',
          Icons.history,
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm
                  .copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    final completed = application.status == ApplicationStatus.completed;
    final pending = application.status == ApplicationStatus.pending;
    return StatPill(
      label: application.hoursLabel ?? '+${application.hours} hrs',
      background: completed
          ? AppColors.secondaryContainer
          : pending
              ? AppColors.surfaceContainer
              : AppColors.primaryFixed,
      foreground: completed
          ? AppColors.onSecondaryContainer
          : pending
              ? AppColors.onSurfaceVariant
              : AppColors.primary,
      bold: completed || !pending,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    final completed = application.status == ApplicationStatus.completed;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            application.infoIcon,
            size: 20,
            color: completed
                ? AppColors.primary
                : application.status == ApplicationStatus.pending
                    ? AppColors.secondary
                    : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.infoTitle,
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.onSurface)),
                Text(
                  application.infoSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (completed)
            const Icon(Icons.workspace_premium,
                size: 20, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.application,
    required this.onToast,
    required this.onCancel,
  });

  final Application application;
  final void Function(String message, {IconData icon}) onToast;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    switch (application.status) {
      case ApplicationStatus.selected:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _LightButton(
                    icon: Icons.badge,
                    label: 'Ver asistencia y QR',
                    onTap: () => onToast('Mostrando tu código QR de asistencia',
                        icon: Icons.qr_code),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SquareButton(
                  icon: Icons.chat,
                  onTap: () => onToast('Abriendo chat con el coordinador',
                      icon: Icons.chat),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _CancelButton(onTap: onCancel),
          ],
        );
      case ApplicationStatus.pending:
        return Column(
          children: [
            _LightButton(
              icon: Icons.info_outline,
              label: 'Ver estado de solicitud',
              wide: true,
              onTap: () => onToast(
                  'Tu solicitud está en revisión (Turno 4 de 12)',
                  icon: Icons.pending_actions),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CancelButton(onTap: onCancel),
          ],
        );
      case ApplicationStatus.completed:
        return Row(
          children: [
            Expanded(
              child: _PrimaryButton(
                icon: Icons.download,
                label: 'Descargar constancia oficial',
                onTap: () => onToast('Constancia descargada',
                    icon: Icons.download_done),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _SquareButton(
              icon: Icons.share,
              onTap: () =>
                  onToast('Logro compartido', icon: Icons.share),
            ),
          ],
        );
      case ApplicationStatus.history:
        return _LightButton(
          icon: Icons.visibility_outlined,
          label: 'Ver detalle',
          wide: true,
          onTap: () => onToast('Abriendo detalle del voluntariado',
              icon: Icons.visibility),
        );
    }
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        icon: const Icon(Icons.cancel_outlined, size: 18),
        label: Text(
          'Cancelar postulación',
          style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _LightButton extends StatelessWidget {
  const _LightButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return wide ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _MotivationalBanner extends StatelessWidget {
  const _MotivationalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt,
                size: 20, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Vas a mitad de camino!',
                    style: AppTextStyles.labelMd),
                Text(
                  'Completá tus horas antes del 30 de Junio para validar tu certificado de fin de curso.',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
