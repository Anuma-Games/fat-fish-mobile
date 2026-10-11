import 'package:flutter/material.dart';

import 'app/home_screen.dart';
import 'app/theme.dart';

void main() {
  runApp(const FatFishApp());
}

class FatFishApp extends StatelessWidget {
  const FatFishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fat Fish',
      debugShowCheckedModeBanner: false,
      theme: buildFatFishTheme(),
      home: const HomeScreen(),
    );
  }
}
