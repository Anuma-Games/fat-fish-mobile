import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Top bar of the design: dark strip with the section name in uppercase, and a back
/// arrow when the screen was opened over another. No logo: the brand lives on the table.
class FatFishAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FatFishAppBar({super.key, required this.title});

  static const height = 64.0;

  /// Margins of a page whose content scrolls under the bar (`extendBodyBehindAppBar`):
  /// 20 px under the bar, 16 at the sides and 32 at the bottom.
  static EdgeInsets pageInsets(BuildContext context) => EdgeInsets.fromLTRB(
    FatFishSpacing.s4,
    // With extendBodyBehindAppBar the top padding already counts the bar.
    MediaQuery.paddingOf(context).top + 20,
    FatFishSpacing.s4,
    FatFishSpacing.s8,
  );

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

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
