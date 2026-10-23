import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme.dart';

class FatFishApp extends StatefulWidget {
  const FatFishApp({super.key});

  @override
  State<FatFishApp> createState() => _FatFishAppState();
}

class _FatFishAppState extends State<FatFishApp> {
  // Created once per app, so hot reload and rebuilds keep the navigation state.
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fat Fish',
      debugShowCheckedModeBanner: false,
      theme: buildFatFishTheme(),
      routerConfig: _router,
    );
  }
}
