import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/utils/validators.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/auth/widgets/auth_header.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Registro (R1: menos de 3 minutos, máximo 5 campos obligatorios).
///
/// Obligatorios: rol, nombre, correo, contraseña y tipo (los dos de
/// selección ya vienen marcados). Opcionales: horas requeridas e intereses.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _horasController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  RolUsuario _rol = RolUsuario.voluntario;
  TipoUsuario _tipo = TipoUsuario.estudiante;
  final Set<Causa> _intereses = {};
  bool _obscure = true;

  bool get _esVoluntario => _rol == RolUsuario.voluntario;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _horasController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();
    final pideHoras = _esVoluntario && _tipo == TipoUsuario.estudiante;
    await context.read<AuthProvider>().register(
          nombre: _nombreController.text,
          email: _emailController.text,
          password: _passwordController.text,
          tipo: _tipo,
          rol: _rol,
          intereses: _esVoluntario ? _intereses.toList() : const [],
          horasRequeridas:
              pideHoras ? int.tryParse(_horasController.text.trim()) ?? 0 : 0,
        );
  }

  void _toggleInteres(Causa causa, bool selected) {
    setState(() {
      if (selected) {
        _intereses.add(causa);
      } else {
        _intereses.remove(causa);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final error = auth.error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Crea tu cuenta',
                      subtitle: 'Toma menos de un minuto.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SegmentedButton<RolUsuario>(
                      segments: const [
                        ButtonSegment(
                          value: RolUsuario.voluntario,
                          icon: Icon(Icons.volunteer_activism),
                          label: Text('Voluntario'),
                        ),
                        ButtonSegment(
                          value: RolUsuario.organizacion,
                          icon: Icon(Icons.apartment),
                          label: Text('Organización'),
                        ),
                      ],
                      selected: {_rol},
                      onSelectionChanged: (seleccion) =>
                          setState(() => _rol = seleccion.first),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _nombreController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: Validators.nombre,
                      decoration: InputDecoration(
                        labelText: _esVoluntario
                            ? 'Nombre'
                            : 'Nombre de la organización',
                        prefixIcon: Icon(
                          _esVoluntario ? Icons.person_outline : Icons.apartment,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        helperText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (_esVoluntario) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text('¿Qué haces actualmente?',
                          style: AppTextStyles.titleSm),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final tipo in TipoUsuario.values)
                            ChoiceChip(
                              label: Text(tipo.label),
                              selected: _tipo == tipo,
                              onSelected: (_) => setState(() => _tipo = tipo),
                            ),
                        ],
                      ),
                      if (_tipo == TipoUsuario.estudiante) ...[
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _horasController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: Validators.horasOpcionales,
                          decoration: const InputDecoration(
                            labelText: 'Horas sociales que pide tu U (opcional)',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text('Causas que te interesan (opcional)',
                          style: AppTextStyles.titleSm),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final causa in Causa.values)
                            FilterChip(
                              avatar: Icon(causa.chipIcon, size: 18),
                              label: Text(causa.label),
                              selected: _intereses.contains(causa),
                              onSelected: (selected) =>
                                  _toggleInteres(causa, selected),
                            ),
                        ],
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AuthErrorBanner(message: error),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AuthSubmitButton(
                      label: 'Crear cuenta',
                      isBusy: auth.isBusy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta?',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: widget.onLogin,
                          child: const Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
