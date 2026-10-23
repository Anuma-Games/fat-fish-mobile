import 'package:flutter/widgets.dart';

/// 12 × 12 pixel art icons, the same grids as `pixel-icon.ts` in the PWA ('#' is a filled pixel).
/// `ranking` and `player` exist only in the app.
enum PixelIcons {
  menu([
    '',
    '############',
    '############',
    '',
    '',
    '############',
    '############',
    '',
    '',
    '############',
    '############',
    '',
  ]),
  close([
    '##........##',
    '.##......##.',
    '..##....##..',
    '...##..##...',
    '....####....',
    '.....##.....',
    '....####....',
    '...##..##...',
    '..##....##..',
    '.##......##.',
    '##........##',
    '',
  ]),
  dossier([
    '',
    '#####.......',
    '#...########',
    '#..........#',
    '#..######..#',
    '#.#......#.#',
    '#.#..##..#.#',
    '#..######..#',
    '#..........#',
    '############',
    '',
    '',
  ]),
  feedback([
    '############',
    '#..........#',
    '#.########.#',
    '#..........#',
    '#.######...#',
    '#..........#',
    '############',
    '..##........',
    '..#.........',
    '',
    '',
    '',
  ]),
  search([
    '..#####.....',
    '.#.....#....',
    '#.......#...',
    '#.......#...',
    '#.......#...',
    '#.......#...',
    '.#.....#....',
    '..#####.#...',
    '........##..',
    '.........##.',
    '..........##',
    '',
  ]),
  offline([
    '#...........',
    '.#........##',
    '..#.......##',
    '...#...##.##',
    '....#..##.##',
    '.....#.##.##',
    '..##..###.##',
    '..##..##..##',
    '..##..##..##',
    '..##..##..##',
    '',
    '',
  ]),
  more([
    '',
    '',
    '##........##',
    '.##......##.',
    '..##....##..',
    '...##..##...',
    '....####....',
    '.....##.....',
    '',
    '',
    '',
    '',
  ]),
  send([
    '##..........',
    '####........',
    '######......',
    '########....',
    '##########..',
    '############',
    '##########..',
    '########....',
    '######......',
    '####........',
    '##..........',
    '',
  ]),
  check([
    '',
    '...........#',
    '..........##',
    '.........##.',
    '#.......##..',
    '##.....##...',
    '.##...##....',
    '..##.##.....',
    '...###......',
    '....#.......',
    '',
    '',
  ]),
  ranking([
    '.##########.',
    '##.######.##',
    '#..######..#',
    '#..######..#',
    '.#.######.#.',
    '..########..',
    '...######...',
    '....####....',
    '.....##.....',
    '.....##.....',
    '...######...',
    '..########..',
  ]),
  player([
    '....####....',
    '...######...',
    '...######...',
    '...######...',
    '....####....',
    '',
    '..########..',
    '.##########.',
    '############',
    '############',
    '############',
    '',
  ]);

  const PixelIcons(this.rows);

  final List<String> rows;
}

/// Draws a [PixelIcons] grid. Takes the color from the surrounding [IconTheme], like [Icon],
/// so NavigationBar paints it gold when selected. Sizes that are multiples of 12 stay crisp.
class PixelIcon extends StatelessWidget {
  const PixelIcon(this.icon, {super.key, this.size, this.color});

  final PixelIcons icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final side = size ?? iconTheme.size ?? 24;

    return SizedBox.square(
      dimension: side,
      child: CustomPaint(
        painter: _PixelPainter(
          icon.rows,
          color ?? iconTheme.color ?? const Color(0xFFF2E8CC),
        ),
      ),
    );
  }
}

class _PixelPainter extends CustomPainter {
  const _PixelPainter(this.rows, this.color);

  final List<String> rows;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 12;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;

    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        if (rows[y][x] == '#') {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rows != rows;
}
