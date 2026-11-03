import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/features/accreditation/accreditation_provider.dart';

/// Punto de entrada para ApplicantsScreen.onAccredit.
Future<bool?> showAccreditationDialog(
  BuildContext context,
  Application application,
) {
  final dependencies = context.read<AppDependencies>();
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => AccreditationProvider(
        applicationId: application.id,
        applications: dependencies.applications,
        auth: dependencies.auth,
      ),
      child: const AccreditationDialog(),
    ),
  );
}

class AccreditationDialog extends StatefulWidget {
  const AccreditationDialog({super.key});

  @override
  State<AccreditationDialog> createState() => _AccreditationDialogState();
}

class _AccreditationDialogState extends State<AccreditationDialog> {
  final _form = GlobalKey<FormState>();
  final _horas = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _horas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if ((_form.currentState?.validate() ?? false) == false) return;
    final horas = int.tryParse(_horas.text.trim());
    if (horas == null) return;
    final success = await context.read<AccreditationProvider>().acreditar(
      horas,
    );
    if (mounted == false) return;
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccreditationProvider>();
    final application = provider.application;
    if (_initialized == false && application != null) {
      _horas.text = '${application.horasEstimadas}';
      _initialized = true;
    }
    return PopScope(
      canPop: provider.isBusy == false,
      child: AlertDialog(
        title: const Text('Acreditar horas'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: provider.isLoading
                ? const LoadingView()
                : application == null
                ? ErrorView(
                    message: provider.error ?? 'No encontramos la postulación.',
                    onRetry: () =>
                        context.read<AccreditationProvider>().retry(),
                  )
                : Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(application.oportunidadTitulo),
                        const SizedBox(height: 8),
                        Text('Voluntario: ${application.userId}'),
                        const SizedBox(height: 16),
                        const Text(
                          'Confirma que la jornada finalizó y escribe las horas '
                          'realmente realizadas. Esta acción no se puede deshacer.',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _horas,
                          enabled:
                              provider.canAccredit && provider.isBusy == false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Horas acreditadas',
                          ),
                          validator: (value) {
                            final horas = int.tryParse(value?.trim() ?? '');
                            return horas == null || horas <= 0
                                ? 'Escribe un número entero mayor que cero.'
                                : null;
                          },
                        ),
                        if (provider.canAccredit == false)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'Esta postulación ya no permite acreditar horas.',
                            ),
                          ),
                        if (provider.error case final error?)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(error),
                            ),
                          ),
                        if (provider.isBusy) const LinearProgressIndicator(),
                      ],
                    ),
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: provider.isBusy
                ? null
                : () => Navigator.pop(context, false),
            style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: provider.canAccredit && provider.isBusy == false
                ? _guardar
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: Text(provider.isBusy ? 'Guardando…' : 'Confirmar horas'),
          ),
        ],
      ),
    );
  }
}
