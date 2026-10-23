import 'package:fat_fish_mobile/app/theme.dart';
import 'package:flutter/material.dart';

/// Temporary body for screens whose ticket is not done yet.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            message,
            style: textTheme.bodyLarge?.copyWith(color: FatFishColors.fog),
          ),
        ],
      ),
    );
  }
}
