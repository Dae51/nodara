import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/profile/profile_provider.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key, required this.user});
  final AppUser user;
  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _form = GlobalKey<FormState>();
  late final _horas = TextEditingController(
    text: '${widget.user.horasRequeridas}',
  );
  late final _intereses = widget.user.intereses.toSet();
  @override
  void dispose() {
    _horas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if ((_form.currentState?.validate() ?? false) == false) return;
    final horas = int.tryParse(_horas.text.trim());
    if (horas == null) return;
    final success = await context.read<ProfileProvider>().guardarPerfil(
      horasRequeridas: horas,
      intereses: _intereses.toList(),
    );
    if (mounted == false) return;
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return PopScope(
      canPop: provider.isSaving == false,
      child: AlertDialog(
        title: const Text('Editar perfil'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _horas,
                    enabled: provider.isSaving == false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Horas requeridas',
                      helperText: 'Usa 0 si no tienes una meta de horas.',
                      helperMaxLines: 2,
                    ),
                    validator: (value) {
                      final horas = int.tryParse(value?.trim() ?? '');
                      return horas == null || horas < 0
                          ? 'Escribe un número entero igual o mayor que cero.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Tus intereses'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: Causa.values
                        .map(
                          (causa) => FilterChip(
                            label: Text(causa.label),
                            selected: _intereses.contains(causa),
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onSelected: provider.isSaving
                                ? null
                                : (selected) => setState(() {
                                    if (selected) {
                                      _intereses.add(causa);
                                    } else {
                                      _intereses.remove(causa);
                                    }
                                  }),
                          ),
                        )
                        .toList(),
                  ),
                  if (provider.error case final error?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Semantics(liveRegion: true, child: Text(error)),
                    ),
                  if (provider.isSaving) const LinearProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: provider.isSaving ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: provider.isSaving ? null : _guardar,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
