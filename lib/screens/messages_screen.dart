import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/placeholder_view.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Mensajes', style: AppTextStyles.headlineSm),
              ),
            ),
            const Expanded(
              child: PlaceholderView(
                icon: Icons.forum_outlined,
                title: 'Mensajes',
                message:
                    'Acá vas a chatear con coordinadores y equipos de voluntariado.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
