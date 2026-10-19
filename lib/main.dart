import 'package:flutter/material.dart';

import 'models/opportunity.dart';
import 'screens/home_shell.dart';
import 'screens/my_applications_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/opportunity_detail_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NodaraApp());
}

class NodaraApp extends StatefulWidget {
  const NodaraApp({super.key});

  @override
  State<NodaraApp> createState() => _NodaraAppState();
}

class _NodaraAppState extends State<NodaraApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case '/home':
        return MaterialPageRoute<void>(
          builder: (_) => const HomeShell(),
          settings: settings,
        );
      case '/detail':
        final opportunity = settings.arguments as Opportunity;
        return MaterialPageRoute<void>(
          builder: (_) => OpportunityDetailScreen(opportunity: opportunity),
          settings: settings,
        );
      case '/applications':
        return MaterialPageRoute<void>(
          builder: (_) => const MyApplicationsScreen(),
          settings: settings,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'NODARA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}
