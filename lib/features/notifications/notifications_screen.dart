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

/// Lista de avisos (reemplaza al tab "Mensajes", que no estaba en la ficha).
///
/// F4 (Josué): notificación local cuando llega un aviso nuevo y abrir
/// Postulaciones al tocarla.
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
      body = ErrorView(message: errorMessage);
    } else if (provider.items.isEmpty) {
      body = const EmptyView(
        icon: Icons.notifications_none,
        message: 'Aquí verás cuando una organización responda a tus postulaciones.',
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: provider.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final notification = provider.items[index];
          return _NotificationTile(
            notification: notification,
            onTap: () =>
                context.read<NotificationsProvider>().markAsRead(notification),
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
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaCorta(notification.creadaEn),
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.outline),
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
