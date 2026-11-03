import 'package:flutter/material.dart';
import 'package:nodara/core/utils/date_format.dart';
import 'package:nodara/data/models/certificate.dart';
import 'package:nodara/data/repositories/certificate_repository.dart';

class ValidateCertificateDialog extends StatefulWidget {
  const ValidateCertificateDialog({super.key, required this.repository});
  final CertificateRepository repository;
  @override
  State<ValidateCertificateDialog> createState() =>
      _ValidateCertificateDialogState();
}

class _ValidateCertificateDialogState extends State<ValidateCertificateDialog> {
  final _form = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  bool _busy = false;
  bool _searched = false;
  Certificate? _certificate;
  String? _error;
  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    if ((_form.currentState?.validate() ?? false) == false || _busy) return;
    setState(() {
      _busy = true;
      _searched = false;
      _certificate = null;
      _error = null;
    });
    try {
      final certificate = await widget.repository.validar(_codigo.text);
      if (mounted == false) return;
      setState(() {
        _certificate = certificate;
        _searched = true;
      });
    } catch (_) {
      if (mounted == false) return;
      setState(
        () => _error =
            'No pudimos consultar el código. Revisa la conexión y reintenta.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final certificate = _certificate;
    return AlertDialog(
      title: const Text('Validar certificado'),
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
                  controller: _codigo,
                  enabled: _busy == false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Código NOD-XXXX-XXXX',
                  ),
                  onChanged: (_) => setState(() {
                    _certificate = null;
                    _searched = false;
                    _error = null;
                  }),
                  validator: (value) =>
                      RegExp(r'^NOD-[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$')
                          .hasMatch(value?.trim().toUpperCase() ?? '')
                      ? null
                      : 'Usa el código con formato NOD-XXXX-XXXX.',
                ),
                const SizedBox(height: 16),
                if (_busy) const LinearProgressIndicator(),
                if (_error case final error?)
                  Semantics(liveRegion: true, child: Text(error)),
                if (_searched && certificate == null)
                  const Text('No encontramos un certificado con ese código.'),
                if (certificate != null) ...[
                  const Text('Certificado encontrado'),
                  Text(certificate.nombre),
                  Text('${certificate.totalHoras} horas acreditadas'),
                  Text('Emitido el ${fechaLarga(certificate.emitidoEn)}'),
                  SelectableText(certificate.codigo),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          onPressed: _busy ? null : _validar,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          child: const Text('Validar'),
        ),
      ],
    );
  }
}
