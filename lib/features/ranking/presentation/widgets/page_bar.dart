import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Arrows and the numbers of the pages. [current] and [onPage] count from 0;
/// the buttons show them from 1.
class PageBar extends StatelessWidget {
  const PageBar({
    super.key,
    required this.current,
    required this.total,
    required this.onPage,
  });

  final int current;
  final int total;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Páginas del ranking',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Arrow(
            icon: PixelIcons.back,
            tooltip: 'Página anterior',
            onPressed: current > 0 ? () => onPage(current - 1) : null,
          ),
          for (var page = 0; page < total; page++) ...[
            const SizedBox(width: 6),
            _Number(
              page: page,
              selected: page == current,
              onPressed: () => onPage(page),
            ),
          ],
          const SizedBox(width: 6),
          _Arrow(
            icon: PixelIcons.chevron,
            tooltip: 'Página siguiente',
            onPressed: current < total - 1 ? () => onPage(current + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.tooltip, this.onPressed});

  final PixelIcons icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          fixedSize: const Size(44, 44),
          minimumSize: const Size(44, 44),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: PixelIcon(
          icon,
          size: 12,
          color: enabled ? FatFishColors.cream100 : FatFishColors.line,
        ),
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({
    required this.page,
    required this.selected,
    required this.onPressed,
  });

  final int page;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      label: 'Página ${page + 1}',
      excludeSemantics: true,
      button: true,
      child: OutlinedButton(
        onPressed: selected ? null : onPressed,
        style:
            OutlinedButton.styleFrom(
              fixedSize: const Size(40, 44),
              minimumSize: const Size(40, 44),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              // The current page is drawn on, not disabled-looking.
              disabledBackgroundColor: FatFishColors.felt700,
              disabledForegroundColor: FatFishColors.cream100,
              foregroundColor: FatFishColors.fog400,
              textStyle: const TextStyle(
                fontFamily: FatFishFonts.label,
                fontSize: 9,
              ),
            ).copyWith(
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: selected ? FatFishColors.gold400 : FatFishColors.line,
                  width: 2,
                ),
              ),
            ),
        child: Text('${page + 1}'),
      ),
    );
  }
}
