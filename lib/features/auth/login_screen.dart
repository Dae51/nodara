import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/validators.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/auth/widgets/auth_header.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Inicio de sesión con correo y contraseña.
///
/// Si el login funciona no se navega a mano: [AuthGate] recibe el nuevo
/// usuario por el stream y cambia de pantalla solo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<AuthProvider>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
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
                      title: 'Inicia sesión',
                      subtitle: 'Sigue sumando horas y ayudando a tu comunidad.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _emailController,
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
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      validator: Validators.password,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
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
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AuthErrorBanner(message: error),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AuthSubmitButton(
                      label: 'Ingresar',
                      isBusy: auth.isBusy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta?',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: widget.onCreateAccount,
                          child: const Text('Crear cuenta'),
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
