import 'dart:math' as math;

import 'package:fat_fish_mobile/core/presentation/widgets/paper.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:flutter/material.dart';

/// The dossier the casino keeps on the player: a sheet of paper with a tab, a paper clip,
/// a "CONFIDENCIAL" stamp, the mugshot and the six statistics.
class DossierSheet extends StatelessWidget {
  const DossierSheet({
    super.key,
    required this.profile,
    required this.now,
    this.onChangePlayer,
  });

  /// Touch target of "Cambiar". It is taller than the tab next to it, so the space
  /// above the tab is part of the button; the page takes it out of its top margin.
  static const changeButtonHeight = 44.0;

  /// How much higher than the tab "Cambiar" reaches, beyond the 32 px link of the design.
  static const changeButtonOverhang = changeButtonHeight - 32;

  final PlayerProfile profile;

  /// Today, to write "Hoy" or "Ayer" as the last time.
  final DateTime now;

  /// "Cambiar": opens the search to pick another player.
  final VoidCallback? onChangePlayer;

  @override
  Widget build(BuildContext context) {
    final stats = profile.stats;
    final timePerMatch = formatTimePerMatch(
      seconds: stats.secondsPlayed,
      matches: stats.totalMatches,
    );

    return Semantics(
      container: true,
      label: 'Ficha del jugador',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SheetTab('EXPEDIENTE N.º ${profile.id}'),
              const Spacer(),
              if (onChangePlayer case final onChangePlayer?)
                _ChangeButton(onPressed: onChangePlayer),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              RuledPaper(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                borderRadius: const BorderRadius.only(
                  topRight: FatFishRadius.sheet,
                  bottomLeft: FatFishRadius.sheet,
                  bottomRight: FatFishRadius.sheet,
                ),
                shadow: FatFishShadows.sheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Identity(profile: profile, now: now),
                    const SizedBox(height: 20),
                    const ColoredBox(
                      color: FatFishColors.ink900,
                      child: SizedBox(height: 2),
                    ),
                    _StatsGrid(
                      cells: [
                        _PaperStat(
                          label: 'PARTIDAS',
                          value: formatNumber(stats.totalMatches),
                          note: 'Ganaste ${formatNumber(stats.matchesWon)}',
                        ),
                        _PaperStat(
                          label: 'TOTAL PERDIDO',
                          value: formatMoney(stats.moneyLost),
                          note:
                              'De ${formatMoney(stats.moneyInvested)} invertidos',
                          valueColor: FatFishColors.red,
                        ),
                        _PaperStat(
                          label: 'RACHA DE DERROTAS',
                          value: formatNumber(stats.longestLosingStreak),
                          note: 'Seguidas',
                        ),
                        _PaperStat(
                          label: 'TIEMPO EN LA MESA',
                          value: formatPlayTime(stats.secondsPlayed),
                          note: timePerMatch ?? 'Sin partidas',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 28,
                top: -14,
                child: ExcludeSemantics(
                  child: CustomPaint(
                    size: Size(16, 40),
                    painter: _PaperClipPainter(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetTab extends StatelessWidget {
  const _SheetTab(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      decoration: const BoxDecoration(
        color: FatFishColors.paper300,
        borderRadius: BorderRadius.vertical(top: FatFishRadius.card),
      ),
      child: Text(
        text,
        style: PaperText.typed(11).copyWith(letterSpacing: 1.5),
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  const _ChangeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: FatFishColors.gold400,
        // Exactly 44 px: the padded 48 px default pushed the sheet down.
        minimumSize: const Size(44, DossierSheet.changeButtonHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: FatFishSpacing.s1),
        textStyle: const TextStyle(
          fontFamily: FatFishFonts.body,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: const PixelIcon(
        PixelIcons.player,
        size: 12,
        color: FatFishColors.gold400,
      ),
      label: const Text('Cambiar'),
    );
  }
}

/// Mugshot, alias, stamp and the two dates of the player.
class _Identity extends StatelessWidget {
  const _Identity({required this.profile, required this.now});

  final PlayerProfile profile;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Mugshot(id: profile.id),
            const SizedBox(width: FatFishSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.alias,
                    style: PaperText.typed(26).copyWith(height: 1.1),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'LO QUE EL CASINO SABE DE TI',
                    style: PaperText.label,
                  ),
                  const SizedBox(height: FatFishSpacing.s3),
                  _Field(
                    label: 'ÚLTIMA VEZ',
                    value: describeLastSeen(profile.lastActivity, now: now),
                  ),
                  const SizedBox(height: FatFishSpacing.s2),
                  _Field(
                    label: 'EN LA MESA DESDE',
                    value: formatLongDate(profile.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Positioned(left: -10, top: -10, child: _ConfidentialStamp()),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PaperText.label),
          const SizedBox(height: 2),
          Text(value, style: PaperText.typed(15)),
        ],
      ),
    );
  }
}

/// Red rubber stamp, tilted as if it was pressed by hand. Decoration only.
class _ConfidentialStamp extends StatelessWidget {
  const _ConfidentialStamp();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: -12 * math.pi / 180,
        child: Opacity(
          opacity: 0.9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: FatFishColors.paper100.withValues(alpha: 0.85),
              border: Border.all(color: FatFishColors.red, width: 2),
            ),
            child: Text(
              'CONFIDENCIAL',
              style: PaperText.typed(
                11,
                color: FatFishColors.red,
              ).copyWith(letterSpacing: 2, height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pixel silhouette against the height chart of a police photo, with the player number.
class _Mugshot extends StatelessWidget {
  const _Mugshot({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 84,
        height: 104,
        decoration: BoxDecoration(
          border: Border.all(color: FatFishColors.ink900, width: 2),
        ),
        child: CustomPaint(
          painter: const _MugshotPainter(),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: FatFishSpacing.s2),
              child: Text(
                '#$id',
                style: PaperText.typed(10, color: FatFishColors.paper100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MugshotPainter extends CustomPainter {
  const _MugshotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = FatFishColors.paper200,
    );

    // Height chart: one line every 10 px.
    final line = Paint()..color = FatFishColors.ink900.withValues(alpha: 0.2);
    for (var y = 0.0; y < size.height; y += 10) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }

    // 70 × 86 silhouette, centered at the bottom: head, neck and shoulders.
    final ink = Paint()
      ..color = FatFishColors.ink900
      ..isAntiAlias = false;
    canvas.save();
    canvas.translate((size.width - 70) / 2, size.height - 86);
    for (final rect in const [
      Rect.fromLTWH(22, 12, 26, 30),
      Rect.fromLTWH(18, 16, 34, 22),
      Rect.fromLTWH(14, 50, 42, 4),
      Rect.fromLTWH(8, 54, 54, 32),
    ]) {
      canvas.drawRect(rect, ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MugshotPainter oldDelegate) => false;
}

/// Wire paper clip that holds the sheet, drawn over its top edge.
class _PaperClipPainter extends CustomPainter {
  const _PaperClipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(4, 30)
      ..lineTo(4, 8)
      ..arcToPoint(const Offset(12, 8), radius: const Radius.circular(4))
      ..lineTo(12, 32)
      ..arcToPoint(const Offset(0, 32), radius: const Radius.circular(6))
      ..lineTo(0, 12);
    canvas.drawPath(
      path,
      Paint()
        ..color = FatFishColors.silver
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_PaperClipPainter oldDelegate) => false;
}

/// Two columns; a line closes the first row.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    final rule = BorderSide(
      color: FatFishColors.ink900.withValues(alpha: 0.45),
      width: 2,
    );

    Widget row(List<Widget> pair, {required bool ruled}) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, cell) in pair.indexed) ...[
            if (index > 0) const SizedBox(width: FatFishSpacing.s4),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: ruled ? Border(bottom: rule) : null,
                ),
                child: cell,
              ),
            ),
          ],
        ],
      ),
    );

    return Column(
      children: [
        for (var i = 0; i < cells.length; i += 2)
          row(
            cells.sublist(i, math.min(i + 2, cells.length)),
            ruled: i + 2 < cells.length,
          ),
      ],
    );
  }
}

class _PaperStat extends StatelessWidget {
  const _PaperStat({
    required this.label,
    required this.value,
    required this.note,
    this.valueColor = FatFishColors.ink900,
  });

  final String label;
  final String value;
  final String note;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FatFishSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: PaperText.label),
            const SizedBox(height: FatFishSpacing.s1),
            // Big amounts shrink instead of wrapping on narrow phones.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: PaperText.typed(22, color: valueColor)),
            ),
            const SizedBox(height: 2),
            Text(note, style: PaperText.note),
          ],
        ),
      ),
    );
  }
}

/// Receipt torn from the register: of every $100 the player spent, how many the house
/// kept, in words and as 20 boxes of $5.
class HouseReceipt extends StatelessWidget {
  const HouseReceipt({super.key, required this.cut});

  /// 0 to 100.
  final int cut;

  static const _boxes = 20;

  @override
  Widget build(BuildContext context) {
    final filled = (cut / (100 / _boxes)).round();
    final body = PaperText.typed(15)
        .copyWith(fontWeight: FontWeight.w400, height: 1.4);
    final bold = body.copyWith(fontWeight: FontWeight.w700);

    final receipt = RuledPaper(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: body,
              children: [
                const TextSpan(text: 'De cada '),
                TextSpan(text: r'$100', style: bold),
                const TextSpan(text: ' que gastaste, la casa se quedó con '),
                TextSpan(
                  text: '\$$cut',
                  style: bold.copyWith(color: FatFishColors.red),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: FatFishSpacing.s3),
          Semantics(
            label: '$cut de cada 100 pesos apostados se perdieron',
            excludeSemantics: true,
            child: Row(
              children: [
                for (var i = 0; i < _boxes; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: i < filled
                          ? const BoxDecoration(color: FatFishColors.red)
                          : BoxDecoration(
                              border: Border.all(
                                color: FatFishColors.ink900.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FatFishSpacing.s3),
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PERDIDO',
                  style: PaperText.label.copyWith(color: FatFishColors.ink900),
                ),
                const Text('RECUPERADO', style: PaperText.label),
              ],
            ),
          ),
        ],
      ),
    );

    // The hard shadow follows the torn edge: a black copy of the shape, 4 px down and right.
    return Semantics(
      container: true,
      label: 'Lo que se quedó la casa',
      child: Stack(
        children: [
          Positioned.fill(
            left: 4,
            top: 4,
            right: -4,
            bottom: -4,
            child: const ClipPath(
              clipper: _TornEdgeClipper(),
              child: ColoredBox(color: Color(0xFF000000)),
            ),
          ),
          ClipPath(clipper: const _TornEdgeClipper(), child: receipt),
        ],
      ),
    );
  }
}

/// Straight top and sides, and a zigzag bottom of 24 teeth 6 px deep.
class _TornEdgeClipper extends CustomClipper<Path> {
  const _TornEdgeClipper();

  static const _teeth = 24;
  static const _depth = 6.0;

  @override
  Path getClip(Size size) {
    final step = size.width / (_teeth * 2);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - _depth);
    for (var i = _teeth * 2 - 1; i >= 0; i--) {
      final x = step * i;
      path.lineTo(x, i.isOdd ? size.height : size.height - _depth);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TornEdgeClipper oldClipper) => false;
}
