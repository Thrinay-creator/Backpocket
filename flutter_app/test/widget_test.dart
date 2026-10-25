import 'package:flutter_test/flutter_test.dart';
import 'package:backpocket/main.dart';

void main() {
  testWidgets('Backpocket smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BackpocketApp());
    expect(find.text('Campus Lost & Found'), findsOneWidget);
  });
}
