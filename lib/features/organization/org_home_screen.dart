import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/widgets/placeholder_view.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/theme/app_theme.dart';

/// Inicio de la organización (F3): mis convocatorias, crear convocatoria
/// y postulantes. Datos disponibles en `OpportunityRepository.watchByOrg`
/// y `ApplicationRepository.watchForOrg` / `cambiarEstado`.
///
/// Para probar con el Fake: iniciar sesión con `org@nodara.app`.
class OrgHomeScreen extends StatelessWidget {
  const OrgHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<AuthProvider>().user?.nombre ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(nombre, style: AppTextStyles.titleMd),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: const SafeArea(
        child: PlaceholderView(
          icon: Icons.apartment,
          title: 'Panel de organización',
          message:
              'Aquí podrás publicar convocatorias y revisar a tus postulantes.',
        ),
      ),
    );
  }
}
