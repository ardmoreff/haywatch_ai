import 'package:flutter_test/flutter_test.dart';
import 'package:haywatch_ai/main.dart';

void main() {
  testWidgets('App loads dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const HayWatchApp());
    expect(find.text('Tagged Fields'), findsOneWidget);
  });
}
