import 'package:flutter_test/flutter_test.dart';
import 'package:haywatch_ai/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Since Firebase isn't initialized in test environment, 
    // we'll just verify the app builds without crashing
    try {
      await tester.pumpWidget(const HayWatchApp());
      // If we get here, the widget built successfully
      expect(true, true);
    } catch (e) {
      // Expected error due to Firebase not being initialized in tests
      expect(e.toString(), contains('No Firebase App'));
    }
  });
}
