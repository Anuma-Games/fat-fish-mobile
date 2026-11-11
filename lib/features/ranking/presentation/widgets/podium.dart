import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:flutter/material.dart';

/// The first three places on pixel pedestals of gold, silver and bronze:
/// second on the left, first in the middle and third on the right.
class Podium extends StatelessWidget {
  const Podium({super.key, required this.top});

  /// Up to the first three entries, in order.
  final List<RankingEntry> top;

  @override
  Widget build(BuildContext context) {
    final steps = [
      if (top.length > 1)
        (entry: top[1], medal: FatFishMedal.silver, height: 84.0, avatar: 48.0),
      (entry: top[0], medal: FatFishMedal.gold, height: 110.0, avatar: 60.0),
      if (top.length > 2)
        (entry: top[2], medal: FatFishMedal.bronze, height: 68.0, avatar: 48.0),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (index, step) in steps.indexed) ...[
          if (index > 0) const SizedBox(width: FatFishSpacing.s2),
          Expanded(
            child: _Step(
              entry: step.entry,
              medal: step.medal,
              height: step.height,
              avatarSize: step.avatar,
            ),
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.entry,
    required this.medal,
    required this.height,
    required this.avatarSize,
  });

  final RankingEntry entry;
  final FatFishMedal medal;
  final double height;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Lugar ${entry.position}: ${entry.alias}, '
          '${formatNumber(entry.score)} puntos',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerAvatar(
            PlayerSummary(id: entry.playerId, alias: entry.alias),
            size: avatarSize,
          ),
          const SizedBox(height: FatFishSpacing.s1),
          Text(
            entry.alias,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: FatFishFonts.body,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FatFishColors.cream100,
            ),
          ),
          Text(
            formatNumber(entry.score),
            style: TextStyle(
              fontFamily: FatFishFonts.display,
              fontSize: 22,
              height: 1.1,
              color: medal.score,
            ),
          ),
          const SizedBox(height: FatFishSpacing.s1),
          CustomPaint(
            painter: _PedestalPainter(medal.shades),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Center(
                child: Text(
                  '${entry.position}',
                  style: const TextStyle(
                    fontFamily: FatFishFonts.label,
                    fontSize: 18,
                    height: 1,
                    color: FatFishColors.ink900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pixel art pedestal: corners cut in steps, a lit top and a shaded base, two dithered
/// bands, a light left edge and a dark right edge.
class _PedestalPainter extends CustomPainter {
  const _PedestalPainter(this.shades);

  /// Five shades, from the lit top to the shaded base.
  final List<Color> shades;

  static const _band = 8.0;
  static const _step = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    canvas.clipPath(
      Path()
        ..moveTo(_band, 0)
        ..lineTo(w - _band, 0)
        ..lineTo(w - _band, _step)
        ..lineTo(w - _step, _step)
        ..lineTo(w - _step, _band)
        ..lineTo(w, _band)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..lineTo(0, _band)
        ..lineTo(_step, _band)
        ..lineTo(_step, _step)
        ..lineTo(_band, _step)
        ..close(),
    );

    final paint = Paint()..isAntiAlias = false;
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, w, _band), paint..color = shades[0])
      ..drawRect(
        Rect.fromLTWH(0, _band, w, h - 2 * _band),
        paint..color = shades[2],
      )
      ..drawRect(
        Rect.fromLTWH(0, h - _band, w, _band),
        paint..color = shades[4],
      );

    // Dithered bands: in each 8 px tile, the top right and bottom left quarters.
    void dither(double top, Color color) {
      paint.color = color;
      for (var x = 0.0; x < w; x += _band) {
        canvas
          ..drawRect(Rect.fromLTWH(x + _step, top, _step, _step), paint)
          ..drawRect(Rect.fromLTWH(x, top + _step, _step, _step), paint);
      }
    }

    dither(_band, shades[1]);
    dither(h - 2 * _band, shades[3]);

    canvas
      ..drawRect(
        Rect.fromLTWH(0, 0, _step, h),
        paint..color = const Color(0x2EFFFFFF),
      )
      ..drawRect(
        Rect.fromLTWH(w - _step, 0, _step, h),
        paint..color = const Color(0x40000000),
      );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PedestalPainter oldDelegate) =>
      oldDelegate.shades != shades;
}
