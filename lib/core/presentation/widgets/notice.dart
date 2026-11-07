import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Big icon over a centered message, for empty, missing and error states.
/// [action], usually a button, goes under the text.
class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.icon,
    required this.text,
    this.color = FatFishColors.fog400,
    this.action,
  });

  final PixelIcons icon;
  final String text;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FatFishSpacing.s8),
      child: Column(
        children: [
          PixelIcon(icon, size: 48, color: color),
          const SizedBox(height: FatFishSpacing.s4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: color),
          ),
          if (action case final action?) ...[
            const SizedBox(height: FatFishSpacing.s6),
            action,
          ],
        ],
      ),
    );
  }
}
