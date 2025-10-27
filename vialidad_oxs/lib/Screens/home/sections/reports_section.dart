import 'package:flutter/material.dart';

class ReportsSection extends StatelessWidget {
  const ReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportes',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 64,
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text('Módulo de Reportes', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Próximamente disponible',
                    style: textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
