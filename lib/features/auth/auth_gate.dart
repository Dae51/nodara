import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/preferences/app_preferences.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/auth/login_screen.dart';
import 'package:nodara/features/auth/onboarding_screen.dart';
import 'package:nodara/features/auth/register_screen.dart';
import 'package:nodara/features/home/home_shell.dart';
import 'package:nodara/features/organization/org_home_screen.dart';

enum _AuthStep { onboarding, login, register }

/// Raíz de la app: decide qué mostrar según la sesión (visto en clase:
/// `StreamBuilder` sobre `authStateChanges`, sin navegación manual).
///
/// - Sin sesión → onboarding (solo la primera vez) → login / registro.
/// - Voluntario → [HomeShell]. Organización → [OrgHomeScreen].
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AppPreferences _preferences;

  /// Se crea una sola vez en initState (no dentro de build) para no abrir
  /// una suscripción nueva en cada reconstrucción.
  late final Stream<AppUser?> _authStream;

  /// `null` mientras se lee si el onboarding ya se vio.
  _AuthStep? _step;

  @override
  void initState() {
    super.initState();
    final dependencies = context.read<AppDependencies>();
    _preferences = dependencies.preferences;
    _authStream = dependencies.auth.authStateChanges();
    _loadInitialStep();
  }

  Future<void> _loadInitialStep() async {
    final visto = await _preferences.onboardingVisto();
    if (!mounted) return;
    setState(() => _step = visto ? _AuthStep.login : _AuthStep.onboarding);
  }

  Future<void> _finishOnboarding(_AuthStep next) async {
    await _preferences.marcarOnboardingVisto();
    if (!mounted) return;
    setState(() => _step = next);
  }

  void _goTo(_AuthStep step) {
    context.read<AuthProvider>().clearError();
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingView());
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: ErrorView(message: 'No pudimos verificar tu sesión.'),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return user.esOrganizacion
              ? const OrgHomeScreen()
              : const HomeShell();
        }

        if (_step == _AuthStep.onboarding) {
          return OnboardingScreen(
            onStart: () => _finishOnboarding(_AuthStep.register),
            onLogin: () => _finishOnboarding(_AuthStep.login),
          );
        } else if (_step == _AuthStep.login) {
          return LoginScreen(
            onCreateAccount: () => _goTo(_AuthStep.register),
          );
        } else if (_step == _AuthStep.register) {
          return RegisterScreen(
            onLogin: () => _goTo(_AuthStep.login),
          );
        }
        // Todavía se está leyendo si el onboarding ya se vio.
        return const Scaffold(body: LoadingView());
      },
    );
  }
}
