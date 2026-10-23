import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Page heading of the PWA: eyebrow label in uppercase, h1 and an optional muted line.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
  });

  final String eyebrow;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: textTheme.labelSmall),
        const SizedBox(height: FatFishSpacing.s2),
        Text(title, style: textTheme.headlineLarge),
        if (description case final description?) ...[
          const SizedBox(height: FatFishSpacing.s2),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(color: FatFishColors.fog400),
          ),
        ],
      ],
    );
  }
}
