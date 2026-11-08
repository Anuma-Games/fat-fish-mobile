import 'dart:async';

import 'package:fat_fish_mobile/core/presentation/widgets/retry_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'spins while retrying, keeps its width and ignores a second tap',
    (tester) async {
      var calls = 0;
      final answer = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RetryButton(
              onRetry: () {
                calls++;
                return answer.future;
              },
            ),
          ),
        ),
      );
      final width = tester.getSize(find.byType(RetryButton)).width;

      await tester.tap(find.byType(RetryButton));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(RetryButton)).width, width);

      await tester.tap(find.byType(RetryButton));
      expect(calls, 1);

      answer.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    },
  );
}
