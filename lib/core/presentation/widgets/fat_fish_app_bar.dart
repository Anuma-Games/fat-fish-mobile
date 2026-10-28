import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Top bar of the PWA (.topbar): round logo and the section name in uppercase.
class FatFishAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FatFishAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          ClipOval(
            child: Image.asset('assets/images/logo.png', width: 32, height: 32),
          ),
          const SizedBox(width: FatFishSpacing.s3),
          Flexible(
            child: Text(title.toUpperCase(), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
