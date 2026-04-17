// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiyat_takip_kripto/main.dart';

void main() {
  testWidgets('Crypto price tracker app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our app loads
    expect(find.text('Kripto Fiyat Takip'), findsOneWidget);
    
    // Wait for the app to initialize
    await tester.pumpAndSettle();
    
    // The app should show the crypto tracking interface
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
