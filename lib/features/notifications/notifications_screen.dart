import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/utils/date_format.dart';
import 'package:nodara/core/widgets/empty_view.dart';
import 'package:nodara/core/widgets/error_view.dart';
import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/data/models/app_notification.dart';
import 'package:nodara/features/notifications/notifications_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Avisos privados del usuario y su estado de lectura.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final errorMessage = provider.error;

    final Widget body;
    if (provider.isLoading) {
      body = const LoadingView();
    } else if (errorMessage != null) {
      body = ErrorView(
        message: errorMessage,
        onRetry: () => context.read<NotificationsProvider>().retry(),
      );
    } else if (provider.items.isEmpty) {
      body = const EmptyView(
        icon: Icons.notifications_none,
        message:
            'Aquí verás cuando una organización responda a tus postulaciones.',
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final notification = provider.items[index];
          return _NotificationTile(
            notification: notification,
            onTap: () async {
              final success = await context
                  .read<NotificationsProvider>()
                  .markAsRead(notification);
              if (context.mounted == false) return;
              if (success == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo marcar como leído. Reintenta.'),
                  ),
                );
              }
            },
          );
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Avisos', style: AppTextStyles.headlineSm),
            ),
            if (provider.localError case final String message)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(message),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.leida
          ? AppColors.surfaceContainerLowest
          : AppColors.primaryFixed.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.leida
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.titulo, style: AppTextStyles.titleSm),
                    const SizedBox(height: 2),
                    Text(
                      notification.cuerpo,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaCorta(notification.creadaEn),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.leida)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm, top: 4),
                  child: Text(
                    'Nuevo',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
