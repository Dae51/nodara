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

  Future<void> _recuperarContrasena() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(initialEmail: _emailController.text),
    );
    if (email == null || !mounted) return; // canceló o se cerró la pantalla
    final auth = context.read<AuthProvider>();
    final enviado = await auth.sendPasswordReset(email: email);
    if (!mounted || !enviado) return; // si falló, el banner muestra el error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si la cuenta existe, te enviamos un correo para restablecer tu contraseña.',
        ),
      ),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _recuperarContrasena,
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
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

/// Diálogo que pide el correo para enviar el enlace de recuperación.
/// Devuelve el correo (ya validado) al cerrarse, o `null` si se cancela.
class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escribe tu correo y te enviaremos un enlace para restablecer tu contraseña.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _enviar(),
              validator: Validators.email,
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviar,
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
