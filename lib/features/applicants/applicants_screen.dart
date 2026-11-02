import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/features/applicants/applicants_provider.dart';

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
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final application = provider.items[index];
          final accredit = onAccredit;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voluntario: ${application.userId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(application.oportunidadTitulo),
                  Text(application.estado.label),
                  if (application.motivo case final String reason)
                    Text('Motivo: $reason'),
                  if (provider.canRespond(application))
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton(
                          onPressed:
                              provider.isBusy ||
                                  provider.opportunity?.hayCupos == false
                              ? null
                              : () => _respond(context, application, true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(100, 48),
                          ),
                          child: const Text('Aceptar'),
                        ),
                        OutlinedButton(
                          onPressed: provider.isBusy
                              ? null
                              : () => _respond(context, application, false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 48),
                          ),
                          child: const Text('Rechazar'),
                        ),
                      ],
                    ),
                  if (provider.hasPendingNotice(application.id))
                    TextButton(
                      onPressed: provider.isBusy
                          ? null
                          : () => context
                                .read<ApplicantsProvider>()
                                .retryNotice(application),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Reenviar aviso'),
                    ),
                  if (accredit != null &&
                      application.estado == EstadoPostulacion.enCurso)
                    OutlinedButton(
                      onPressed: provider.isBusy
                          ? null
                          : () => accredit(context, application),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Acreditar horas'),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Postulantes')),
      body: SafeArea(
        child: Column(
          children: [
            if (provider.opportunity case final opportunity?)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${opportunity.tituloTarjeta} · ${opportunity.cuposLibres} cupos disponibles',
                ),
              ),
            if (error != null && provider.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(liveRegion: true, child: Text(error)),
              ),
            if (provider.isBusy) const LinearProgressIndicator(),
            Expanded(child: body),
          ],
        ),
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
