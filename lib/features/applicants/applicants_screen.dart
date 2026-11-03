import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/features/applicants/applicants_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// José puede abrir esta pantalla pasando el ID de su convocatoria.
class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({
    super.key,
    required this.opportunityId,
    this.onAccredit,
  });
  final String opportunityId;
  final void Function(BuildContext context, Application application)?
  onAccredit;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) {
      final dependencies = context.read<AppDependencies>();
      return ApplicantsProvider(
        opportunityId: opportunityId,
        applications: dependencies.applications,
        opportunities: dependencies.opportunities,
        notifications: dependencies.notifications,
        auth: dependencies.auth,
      );
    },
    child: _ApplicantsView(onAccredit: onAccredit),
  );
}

class _ApplicantsView extends StatelessWidget {
  const _ApplicantsView({this.onAccredit});
  final void Function(BuildContext context, Application application)?
  onAccredit;

  Future<void> _respond(
    BuildContext context,
    Application application,
    bool accept,
  ) async {
    final provider = context.read<ApplicantsProvider>();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ResponseDialog(accept: accept),
    );
    if (context.mounted == false || reason == null) return;
    final success = await provider.responder(
      application,
      aceptar: accept,
      motivo: accept ? null : reason,
    );
    if (context.mounted == false) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuesta guardada y aviso enviado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicantsProvider>();
    final error = provider.error;
    final Widget body;
    if (provider.isLoading) {
      body = const LoadingView();
    } else if (error != null && provider.items.isEmpty) {
      body = ErrorView(
        message: error,
        onRetry: () => context.read<ApplicantsProvider>().retry(),
      );
    } else if (provider.opportunity == null) {
      body = const EmptyView(
        icon: Icons.event_busy,
        message: 'No encontramos esta convocatoria en tu organización.',
      );
    } else if (provider.items.isEmpty) {
      body = const EmptyView(
        icon: Icons.people_outline,
        message: 'Esta convocatoria todavía no tiene postulantes.',
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final application = provider.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ApplicantCard(
              application: application,
              canRespond: provider.canRespond(application),
              hasPendingNotice: provider.hasPendingNotice(application.id),
              isBusy: provider.isBusy,
              hayCupos: provider.opportunity?.hayCupos ?? false,
              onAccept: () => _respond(context, application, true),
              onReject: () => _respond(context, application, false),
              onRetryNotice: () =>
                  context.read<ApplicantsProvider>().retryNotice(application),
              onAccredit: onAccredit,
            ),
          );
        },
      );
    }
    final opportunity = provider.opportunity;
    return Scaffold(
      appBar: AppBar(title: Text('Postulantes', style: AppTextStyles.titleMd)),
      body: SafeArea(
        child: Column(
          children: [
            if (opportunity != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: _OpportunitySummary(
                  titulo: opportunity.tituloTarjeta,
                  cuposLibres: opportunity.cuposLibres,
                ),
              ),
            if (error != null && provider.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    error,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            if (provider.isBusy) const LinearProgressIndicator(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Encabezado con la convocatoria y los cupos que quedan.
class _OpportunitySummary extends StatelessWidget {
  const _OpportunitySummary({required this.titulo, required this.cuposLibres});

  final String titulo;
  final int cuposLibres;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryFixed,
      elevated: false,
      child: Row(
        children: [
          const Icon(Icons.campaign, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              titulo,
              style: AppTextStyles.titleSm.copyWith(
                color: AppColors.onPrimaryFixed,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$cuposLibres cupos',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de un postulante con sus acciones según el estado.
class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.application,
    required this.canRespond,
    required this.hasPendingNotice,
    required this.isBusy,
    required this.hayCupos,
    required this.onAccept,
    required this.onReject,
    required this.onRetryNotice,
    this.onAccredit,
  });

  final Application application;
  final bool canRespond;
  final bool hasPendingNotice;
  final bool isBusy;
  final bool hayCupos;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onRetryNotice;
  final void Function(BuildContext context, Application application)?
  onAccredit;

  @override
  Widget build(BuildContext context) {
    final motivo = application.motivo;
    final accredit = onAccredit;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryFixed,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voluntario: ${application.userId}',
                      style: AppTextStyles.titleSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      application.oportunidadTitulo,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _EstadoPill(estado: application.estado),
          if (motivo != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Motivo: $motivo',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          if (canRespond) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy || hayCupos == false ? null : onAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
          ],
          if (hasPendingNotice)
            TextButton.icon(
              onPressed: isBusy ? null : onRetryNotice,
              style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
              icon: const Icon(Icons.refresh),
              label: const Text('Reenviar aviso'),
            ),
          if (accredit != null &&
              application.estado == EstadoPostulacion.enCurso) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: isBusy ? null : () => accredit(context, application),
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Acreditar horas'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pastilla de estado: el estado se comunica con ícono + texto, no solo
/// con color (accesibilidad vista en clase).
class _EstadoPill extends StatelessWidget {
  const _EstadoPill({required this.estado});

  final EstadoPostulacion estado;

  @override
  Widget build(BuildContext context) {
    IconData icono = Icons.hourglass_top;
    Color fondo = AppColors.surfaceContainerHigh;
    Color texto = AppColors.onSurfaceVariant;

    switch (estado) {
      case EstadoPostulacion.aceptado:
      case EstadoPostulacion.confirmado:
      case EstadoPostulacion.enCurso:
        icono = Icons.autorenew;
        fondo = AppColors.secondaryContainer;
        texto = AppColors.onSecondaryContainer;
      case EstadoPostulacion.completado:
        icono = Icons.check_circle;
        fondo = AppColors.primaryFixed;
        texto = AppColors.primary;
      case EstadoPostulacion.rechazado:
      case EstadoPostulacion.noShow:
      case EstadoPostulacion.cancelado:
        icono = Icons.cancel;
        fondo = AppColors.error.withValues(alpha: 0.1);
        texto = AppColors.error;
      case EstadoPostulacion.retirado:
        icono = Icons.history;
      case EstadoPostulacion.pendiente:
      case EstadoPostulacion.enRevision:
      case EstadoPostulacion.entrevista:
      case EstadoPostulacion.listaEspera:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: texto),
          const SizedBox(width: 4),
          Text(
            estado.label,
            style: AppTextStyles.labelSm.copyWith(
              color: texto,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseDialog extends StatefulWidget {
  const _ResponseDialog({required this.accept});
  final bool accept;
  @override
  State<_ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<_ResponseDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.accept ? '¿Aceptar postulación?' : 'Rechazar postulación',
    ),
    content: widget.accept
        ? const Text('Se ocupará un cupo y se enviará un aviso al voluntario.')
        : Form(
            key: _form,
            child: TextFormField(
              controller: _reason,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Escribe un motivo.'
                  : null,
            ),
          ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (widget.accept || (_form.currentState?.validate() ?? false)) {
            Navigator.pop(context, widget.accept ? '' : _reason.text.trim());
          }
        },
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        child: Text(widget.accept ? 'Aceptar' : 'Rechazar'),
      ),
    ],
  );
}
