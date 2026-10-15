import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/main.dart';

void main() {
  testWidgets('App renders splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that TokTok app loads on SplashScreen.
    expect(find.text('TokTok'), findsOneWidget);
    expect(find.text('powered by katana'), findsOneWidget);
  });
}
