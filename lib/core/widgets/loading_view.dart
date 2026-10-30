import 'package:flutter/material.dart';

import 'package:nodara/theme/app_theme.dart';

/// Estado "cargando" de cualquier vista con datos asíncronos.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
