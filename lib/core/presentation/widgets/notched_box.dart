import 'package:flutter/widgets.dart';

/// Square box with its four corners cut in a pixel step, like the badges of the kit: a
/// 1 px [border] around a [color] fill.
class NotchedBox extends StatelessWidget {
  const NotchedBox({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.border,
    this.child,
  });

  final double width;
  final double height;
  final Color color;
  final Color border;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _NotchClipper(),
      child: Container(
        width: width,
        height: height,
        color: border,
        padding: const EdgeInsets.all(1),
        child: ClipPath(
          clipper: const _NotchClipper(),
          child: Container(
            color: color,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NotchClipper extends CustomClipper<Path> {
  const _NotchClipper();

  static const _cut = 4.0;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    const c = _cut;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(w - c, 0)
      ..lineTo(w - c, c)
      ..lineTo(w, c)
      ..lineTo(w, h - c)
      ..lineTo(w - c, h - c)
      ..lineTo(w - c, h)
      ..lineTo(c, h)
      ..lineTo(c, h - c)
      ..lineTo(0, h - c)
      ..lineTo(0, c)
      ..lineTo(c, c)
      ..close();
  }

  @override
  bool shouldReclip(_NotchClipper oldClipper) => false;
}
