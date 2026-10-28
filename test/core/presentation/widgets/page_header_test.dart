import 'package:fat_fish_mobile/app/theme/app_theme.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('writes the eyebrow in uppercase and the title as h1', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFatFishTheme(),
        home: const PageHeader(
          eyebrow: 'Expediente',
          title: 'Lo que el casino sabe de ti',
          description: 'Busca tu expediente con tu ID.',
        ),
      ),
    );

    expect(find.text('EXPEDIENTE'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Lo que el casino sabe de ti'));
    expect(title.style?.fontSize, 40);
    expect(find.text('Busca tu expediente con tu ID.'), findsOneWidget);
  });
}
