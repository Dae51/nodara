import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales (no sensibles) del dispositivo.
abstract class AppPreferences {
  Future<bool> onboardingVisto();

  Future<void> marcarOnboardingVisto();
}

/// Implementación real con `shared_preferences` (vista en clase).
class SharedAppPreferences implements AppPreferences {
  static const _onboardingKey = 'onboarding_visto';

  @override
  Future<bool> onboardingVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> marcarOnboardingVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}

/// Implementación en memoria para tests y modo Fake.
class InMemoryAppPreferences implements AppPreferences {
  InMemoryAppPreferences({this.visto = false});

  /// Si el onboarding ya se mostró en esta sesión de pruebas.
  bool visto;

  @override
  Future<bool> onboardingVisto() async => visto;

  @override
  Future<void> marcarOnboardingVisto() async => visto = true;
}
