import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/auth/auth_gate.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/donations/donations_provider.dart';
import 'package:nodara/features/explore/explore_provider.dart';
import 'package:nodara/features/notifications/notifications_provider.dart';
import 'package:nodara/firebase_options.dart';
import 'package:nodara/theme/app_theme.dart';

/// `flutter run --dart-define=NODARA_FAKE=true` corre la app sin Firebase
/// (todo en memoria). Cuentas de prueba: sofia@nodara.app / org@nodara.app
/// con cualquier contraseña de 6+ caracteres.
const _usarFake = bool.fromEnvironment('NODARA_FAKE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_usarFake) {
    runApp(NodaraApp(dependencies: AppDependencies.fake(startSignedIn: false)));
    return;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(NodaraApp(dependencies: AppDependencies.firebase()));
}

class NodaraApp extends StatelessWidget {
  const NodaraApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: dependencies),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(dependencies.auth),
        ),
        ChangeNotifierProvider(
          create: (_) => ExploreProvider(dependencies.opportunities),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationsProvider(
            dependencies.applications,
            dependencies.auth,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DonationsProvider(dependencies.donations),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(
            dependencies.notifications,
            dependencies.auth,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NODARA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
