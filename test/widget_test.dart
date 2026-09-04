import 'package:flutter_test/flutter_test.dart';
import 'package:standmap/main.dart';
import 'package:standmap/widgets/common/widgets.dart';

void main() {
  testWidgets('Yago smoke test - shows login screen', (WidgetTester tester) async {
    // Construir la app y disparar un frame
    await tester.pumpWidget(const YagoApp());

    // Verificar que el título de Yago y el botón de inicio de sesión estén presentes
    expect(find.text('Yago'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('Design System - YagoButton renders correctly', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      YagoApp(
        home: YagoButton(
          text: 'Publicar mascota',
          onPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.text('Publicar mascota'), findsOneWidget);
    await tester.tap(find.text('Publicar mascota'));
    expect(pressed, isTrue);
  });

  testWidgets('Design System - YagoStatusBadge renders labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      const YagoApp(
        home: YagoStatusBadge(status: YagoPetStatus.lost),
      ),
    );

    expect(find.text('PERDIDA'), findsOneWidget);
  });
}
