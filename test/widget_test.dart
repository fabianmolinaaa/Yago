import 'package:flutter_test/flutter_test.dart';
import 'package:standmap/main.dart';

void main() {
  testWidgets('StandMap smoke test - shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StandMapApp());

    // Verify that the title and login button are present.
    expect(find.text('StandMap'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
