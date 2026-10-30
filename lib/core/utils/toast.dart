import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Muestra un aviso breve (SnackBar flotante) con ícono.
///
/// Reemplaza los `_toast` / `_showToast` que estaban duplicados en varias
/// pantallas.
void showAppToast(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
