import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';
import 'package:tsumiki_shared/ui.dart';

void main() {
  testWidgets('a card without a picture keeps its name and takes a tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StyleCard(
            label: 'Goatee',
            preview: 'missing.jpg',
            selected: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Goatee'), findsOneWidget);
    expect(find.byIcon(Icons.face), findsOneWidget);
    await tester.tap(find.text('Goatee'));
    expect(taps, 1);
  });

  testWidgets('quota sheet says when a render does not fit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuotaSheet(
            account: Account(credits: 1, freeRemaining: 2, freeLimit: 40),
            cost: 7,
          ),
        ),
      ),
    );
    expect(find.textContaining('kvóta nestačí'), findsOneWidget);
    expect(find.textContaining('2 z 40'), findsOneWidget);
  });
}
