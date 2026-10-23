import 'package:fat_fish_mobile/core/presentation/widgets/page_header.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Temporary body for screens whose ticket is not done yet.
class ComingSoon extends StatelessWidget {
  const ComingSoon({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
  });

  final String eyebrow;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FatFishInsets.page,
      child: PageHeader(eyebrow: eyebrow, title: title, description: message),
    );
  }
}
