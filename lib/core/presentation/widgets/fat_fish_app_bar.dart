import 'package:fat_fish_mobile/core/presentation/bars_visibility.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Top bar of the design: dark strip with the section name in uppercase, and a back
/// arrow when the screen was opened over another. No logo: the brand lives on the table.
class FatFishAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FatFishAppBar({super.key, required this.title});

  static const height = 64.0;

  /// Margins of a page whose content scrolls under the bars (`extendBodyBehindAppBar`
  /// here and `extendBody` in AppShell): 20 px under the top bar, 16 at the sides and
  /// 28 over the bottom bar or the bottom edge.
  static EdgeInsets pageInsets(BuildContext context) {
    // Both paddings already count the bars over the content.
    final padding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      FatFishSpacing.s4,
      padding.top + 20,
      FatFishSpacing.s4,
      padding.bottom + 28,
    );
  }

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    // Slides up out of sight while the tab scrolls down (BarsVisibility).
    return AnimatedSlide(
      offset: BarsVisibility.of(context) ? Offset.zero : const Offset(0, -1),
      duration: motionDuration(context, FatFishMotion.base),
      curve: FatFishMotion.curve,
      child: _bar(context, canPop: canPop),
    );
  }

  Widget _bar(BuildContext context, {required bool canPop}) {
    return AppBar(
      automaticallyImplyLeading: false,
      // The arrow sits 4 px from the edge, so its 44 px target lines up with the 16 px margin.
      titleSpacing: canPop ? FatFishSpacing.s1 : FatFishSpacing.s4,
      title: Row(
        children: [
          if (canPop)
            IconButton(
              tooltip: 'Volver',
              onPressed: () => Navigator.maybePop(context),
              icon: const PixelIcon(
                PixelIcons.back,
                color: FatFishColors.cream100,
              ),
            ),
          Flexible(
            child: Text(title.toUpperCase(), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
