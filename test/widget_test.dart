import 'package:flutter_test/flutter_test.dart';
import 'package:zerosetup/app.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutomationCoreApp());
    expect(find.text('Automation Core'), findsOneWidget);
  });
}
