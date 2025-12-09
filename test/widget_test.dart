// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:game_2048/main.dart';

void main() {
  testWidgets('2048 game widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Game2048App());

    // Verify that the game title is displayed.
    expect(find.text('2048'), findsOneWidget);
    
    // Verify that the score display is present.
    expect(find.text('SCORE'), findsOneWidget);
    
    // Verify that the New Game button is present.
    expect(find.text('New Game'), findsOneWidget);
  });
}
