import 'dart:async';

import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The croupier's bubble: types [text] letter by letter with a blinking cursor and
/// hides a while after the last letter. A new [text] starts over. With reduced motion
/// the line appears whole and the cursor stays still.
class CroupierLine extends StatefulWidget {
  const CroupierLine({super.key, required this.text, required this.serial});

  final String text;

  /// Changes on every new line, so the same words can be said twice.
  final int serial;

  static const letter = Duration(milliseconds: 55);
  static const linger = Duration(seconds: 6);

  @override
  State<CroupierLine> createState() => _CroupierLineState();
}

class _CroupierLineState extends State<CroupierLine>
    with SingleTickerProviderStateMixin {
  late final _cursor = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _typing;
  Timer? _hiding;
  int _typed = 0;
  bool _shown = false;
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    final first = !_shown && _typing == null && _hiding == null;
    _still = still;
    if (first) {
      _say();
    } else {
      _blink();
    }
  }

  @override
  void didUpdateWidget(CroupierLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serial != widget.serial) _say();
  }

  /// The cursor blinks only while the bubble shows and motion is allowed.
  void _blink() {
    if (_still || !_shown) {
      _cursor.stop();
    } else if (!_cursor.isAnimating) {
      unawaited(_cursor.repeat());
    }
  }

  void _say() {
    _typing?.cancel();
    _hiding?.cancel();
    _shown = true;
    _blink();
    if (_still) {
      _typed = widget.text.length;
      _hiding = Timer(CroupierLine.linger, _hide);
      return;
    }
    _typed = 0;
    _typing = Timer.periodic(CroupierLine.letter, (timer) {
      if (_typed >= widget.text.length) {
        timer.cancel();
        _typing = null;
        _hiding = Timer(CroupierLine.linger, _hide);
        return;
      }
      setState(() => _typed++);
    });
  }

  void _hide() {
    if (!mounted) return;
    setState(() => _shown = false);
    _blink();
  }

  @override
  void dispose() {
    _typing?.cancel();
    _hiding?.cancel();
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _still ? Duration.zero : const Duration(milliseconds: 300);

    return Semantics(
      liveRegion: true,
      label: 'Crupier: ${widget.text}',
      excludeSemantics: true,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: duration,
          child: AnimatedSlide(
            offset: _shown ? Offset.zero : const Offset(0, -0.2),
            duration: duration,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xEB050809),
                border: Border.all(color: FatFishLamp.light.withAlpha(64)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    offset: Offset(0, 8),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'CRUPIER',
                    style: TextStyle(
                      fontFamily: FatFishFonts.label,
                      fontSize: 8,
                      letterSpacing: 1,
                      color: FatFishColors.gold400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: widget.text.substring(0, _typed),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: AnimatedBuilder(
                                animation: _cursor,
                                builder: (context, _) => Opacity(
                                  opacity: _still || _cursor.value < 0.5
                                      ? 1
                                      : 0,
                                  child: const SizedBox(
                                    width: 9,
                                    height: 18,
                                    child: ColoredBox(
                                      color: FatFishColors.gold400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontFamily: FatFishFonts.display,
                        fontSize: 22,
                        height: 1.1,
                        color: FatFishColors.cream100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
