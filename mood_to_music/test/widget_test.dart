// Mood to Music App Widget Test
//
// Tests for the Mood to Music application

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_to_music/main.dart';

void main() {
  testWidgets('App starts with MoodSelectView', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('🎵 Mood to Music'), findsOneWidget);
    
    // Verify that the mood selection prompt is displayed
    expect(find.text('How are you feeling today?'), findsOneWidget);
    
    // Verify that at least some mood cards are present
    expect(find.text('Happy'), findsOneWidget);
    
    // Verify that Random Vibe button is present
    expect(find.text('Random Vibe'), findsOneWidget);
  });
}
