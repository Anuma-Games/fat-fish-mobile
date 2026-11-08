import 'package:fat_fish_mobile/core/presentation/widgets/dashed_border.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/retry_button.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Says the data on screen is the copy saved on the device, from [savedOn], and may be
/// out of date. [onRetry] asks the API again; its button spins until it ends.
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({
    super.key,
    required this.savedOn,
    required this.onRetry,
  });

  /// Date and time of the copy, already written for people: "3 de noviembre, 2026,
  /// a las 18:42".
  final String savedOn;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        decoration: const ShapeDecoration(
          color: FatFishColors.bg800,
          shape: DashedBorder(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PixelIcon(PixelIcons.offline, color: FatFishColors.gold400),
            const SizedBox(width: FatFishSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIN CONEXIÓN',
                    style: TextStyle(
                      fontFamily: FatFishFonts.label,
                      fontSize: 8,
                      letterSpacing: 1,
                      color: FatFishColors.gold400,
                    ),
                  ),
                  const SizedBox(height: FatFishSpacing.s1),
                  Text(
                    'Datos guardados el $savedOn. '
                    'Pueden estar desactualizados.',
                    style: const TextStyle(
                      fontFamily: FatFishFonts.body,
                      fontSize: 13,
                      height: 1.45,
                      color: FatFishColors.cream100,
                    ),
                  ),
                ],
              ),
            ),
            RetryButton(onRetry: onRetry),
          ],
        ),
      ),
    );
  }
}
