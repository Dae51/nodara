import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/impact_progress_bar.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/profile/edit_profile_dialog.dart';
import 'package:nodara/features/profile/profile_provider.dart';
import 'package:nodara/features/profile/validate_certificate_dialog.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// El provider local permite integrar R5 sin modificar main.dart.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) {
      final dependencies = context.read<AppDependencies>();
      return ProfileProvider(
        auth: dependencies.auth,
        certificates: dependencies.certificates,
      );
    },
    child: const _ProfileView(),
  );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _editar(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final user = provider.user;
    if (user == null) return;
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: EditProfileDialog(user: user),
      ),
    );
    if (context.mounted == false) return;
    if (saved == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
    }
  }

  Future<void> _descargar(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final applications = context.read<ApplicationsProvider>();
    if (applications.isLoading || applications.error != null) return;
    final report = await provider.generarReporte(applications.completadas);
    if (context.mounted == false || report == null) return;
    try {
      await Printing.sharePdf(
        bytes: report.bytes,
        filename: '${report.certificate.codigo}.pdf',
      );
      if (context.mounted == false) return;
    } catch (_) {
      if (context.mounted == false) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El reporte está emitido. Vuelve a pulsar Descargar reporte para guardarlo o compartirlo.',
          ),
        ),
      );
    }
  }

  Future<void> _salir(BuildContext context) async {
    try {
      await context.read<AuthProvider>().signOut();
      if (context.mounted == false) return;
    } catch (_) {
      if (context.mounted == false) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos cerrar la sesión. Reintenta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final impact = context.watch<ApplicationsProvider>();
    final user = profile.user;
    if (profile.initialized == false) {
      return const Scaffold(body: LoadingView());
    }
    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: ErrorView(
            message: profile.error ?? 'Inicia sesión para ver tu perfil.',
          ),
        ),
      );
    }
    final completed = impact.completadas;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mi Perfil',
                          style: AppTextStyles.headlineSm,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: profile.isSaving || profile.isGenerating
                            ? null
                            : () => _salir(context),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              RemoteImage(
                                url: user.avatarUrl,
                                width: 56,
                                height: 56,
                                icon: Icons.person,
                                borderRadius: BorderRadius.circular(56),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nombre,
                                      style: AppTextStyles.titleLg,
                                    ),
                                    Text(user.carrera ?? user.tipo.label),
                                    Text('Nivel ${impact.nivel}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (impact.isLoading)
                            const LinearProgressIndicator()
                          else if (impact.error == null) ...[
                            Text(
                              '${impact.horasCompletadas} horas acreditadas',
                              style: AppTextStyles.titleLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            if (user.tieneMetaDeHoras) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${impact.horasCompletadas} / ${impact.horasRequeridas} hrs',
                              ),
                              Text('${impact.progresoPorcentaje}% completado'),
                              const SizedBox(height: 8),
                              ImpactProgressBar(value: impact.progreso),
                            ],
                          ],
                          const SizedBox(height: 16),
                          Text('Intereses', style: AppTextStyles.titleSm),
                          const SizedBox(height: 8),
                          if (user.intereses.isEmpty)
                            const Text(
                              'Agrega tus intereses al editar el perfil.',
                            )
                          else
                            Wrap(
                              spacing: 8,
                              children: user.intereses
                                  .map(
                                    (causa) => Chip(label: Text(causa.label)),
                                  )
                                  .toList(),
                            ),
                          OutlinedButton.icon(
                            onPressed: profile.isSaving
                                ? null
                                : () => _editar(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar perfil'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Reporte de horas', style: AppTextStyles.titleLg),
                  const SizedBox(height: 8),
                  const Text(
                    'Incluye tus actividades completadas, horas acreditadas, código de validación y QR.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed:
                        profile.isGenerating ||
                            impact.isLoading ||
                            impact.error != null ||
                            impact.horasCompletadas <= 0
                        ? null
                        : () => _descargar(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(
                      profile.isGenerating
                          ? 'Generando reporte…'
                          : 'Descargar reporte',
                    ),
                  ),
                  if (profile.isGenerating) const LinearProgressIndicator(),
                  if (profile.error case final error?)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Semantics(liveRegion: true, child: Text(error)),
                    ),
                  if (profile.lastReport case final report?) ...[
                    const SizedBox(height: 8),
                    SelectableText('Código: ${report.certificate.codigo}'),
                    Text(
                      'Emisión del reporte: ${(report.elapsed.inMilliseconds / 1000).toStringAsFixed(2)} s',
                    ),
                  ],
                  TextButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => ValidateCertificateDialog(
                        repository: context
                            .read<AppDependencies>()
                            .certificates,
                      ),
                    ),
                    style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Validar certificado'),
                  ),
                  const SizedBox(height: 16),
                  Text('Actividades acreditadas', style: AppTextStyles.titleLg),
                  if (impact.isLoading)
                    const LoadingView()
                  else if (impact.error case final error?)
                    ErrorView(
                      message: error,
                      onRetry: () =>
                          context.read<ApplicationsProvider>().retry(),
                    )
                  else if (completed.isEmpty)
                    const EmptyView(
                      icon: Icons.volunteer_activism_outlined,
                      message: 'Todavía no tienes actividades acreditadas. Las horas aparecerán cuando la organización confirme tu participación.',
                    ),
                ],
              ),
            ),
            if (impact.isLoading == false && impact.error == null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: completed.length,
                  itemBuilder: (context, index) {
                    final item = completed[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.task_alt,
                          color: AppColors.primary,
                        ),
                        title: Text(item.oportunidadTitulo),
                        subtitle: Text(
                          '${item.orgNombre}\n${item.horasQueCuentan} horas acreditadas',
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
