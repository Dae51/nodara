import 'package:flutter/material.dart';

import 'package:nodara/core/constants/remote_assets.dart';
import 'package:nodara/core/widgets/app_logo.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

const _pages = [
  _OnboardingPage(
    image: RemoteAssets.onboardingHero,
    title: 'Hacé la diferencia con tu comunidad',
    subtitle: 'Sumá horas de servicio social acreditadas, adquirí experiencia profesional práctica y creá un impacto auténtico en tu entorno universitario y barrial.',
  ),
  _OnboardingPage(
    image: RemoteAssets.tutoriasImage,
    title: 'Encontrá causas cerca de ti',
    subtitle: 'Explora voluntariados de ONGs y universidades, filtrando por causa, ubicación y horas acreditables para tu carrera.',
  ),
  _OnboardingPage(
    image: RemoteAssets.reforestacionImage,
    title: 'Sumá horas que dejan huella',
    subtitle: 'Cada jornada suma a tu récord de servicio social con certificados oficiales y respaldo institucional.',
  ),
];

/// Presentación inicial. Se muestra solo la primera vez (lo controla
/// [AuthGate] con `AppPreferences`).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  /// "Empezar ahora" → registro.
  final VoidCallback onStart;

  /// "Iniciar sesión" → login.
  final VoidCallback onLogin;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Pasa a la siguiente página con animación (pantallas 1 y 2).
  void _siguiente() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esUltima = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          // En navegador no se estira: mismo ancho máximo que login y registro.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _Header(onSkip: widget.onStart),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) =>
                          _OnboardingPageView(page: _pages[i]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Dots(count: _pages.length, index: _index),
                  const SizedBox(height: AppSpacing.lg),
                  // "Siguiente" en las primeras páginas; en la última, "Empezar ahora".
                  FilledButton(
                    onPressed: esUltima ? widget.onStart : _siguiente,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(esUltima ? 'Empezar ahora' : 'Siguiente'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Wrap y no Row: en pantallas angostas el botón baja de línea.
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta?',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onLogin,
                        child: Text(
                          'Iniciar sesión',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AppLogo(),
        Material(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onSkip,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                'Omitir',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SizedBox(
              width: double.infinity,
              child: RemoteImage(
                url: page.image,
                icon: Icons.volunteer_activism,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMobile.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == index
                  ? AppColors.secondaryContainer
                  : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
