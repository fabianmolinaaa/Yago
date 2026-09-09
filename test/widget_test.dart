import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/main.dart';
import 'package:yago/screens/auth/login_screen.dart';
import 'package:yago/screens/auth/register_screen.dart';
import 'package:yago/screens/onboarding/onboarding_screen.dart';
import 'package:yago/widgets/common/widgets.dart';

void main() {
  testWidgets('OnboardingScreen renders header, tips carousel, and CTA buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const YagoApp(home: OnboardingScreen()));

    // Verificar presencia del logo, lema editorial centrado
    expect(find.byType(YagoLogo), findsOneWidget);
    expect(find.text('Explora · Conecta · Reencuentra'), findsOneWidget);

    // Verificar primer tip del carrusel
    expect(find.textContaining('Reportá en segundos'), findsOneWidget);

    // Verificar botones de acción
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear una cuenta'), findsOneWidget);
  });

  testWidgets('OnboardingScreen carousel swipe displays subsequent tips', (WidgetTester tester) async {
    await tester.pumpWidget(const YagoApp(home: OnboardingScreen()));

    expect(find.textContaining('Reportá en segundos'), findsOneWidget);

    // Deslizar el carrusel hacia la izquierda
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Debe mostrarse el segundo tip (Tu mapa en tiempo real)
    expect(find.textContaining('Tu mapa'), findsOneWidget);
  });

  testWidgets('OnboardingScreen navigation to LoginScreen and back button works', (WidgetTester tester) async {
    await tester.pumpWidget(const YagoApp(home: OnboardingScreen()));

    // Tocar botón de iniciar sesión
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    // Debe mostrar la pantalla de LoginScreen
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);

    // Tocar el botón de volver en LoginScreen
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Debe regresar a OnboardingScreen
    expect(find.byType(YagoLogo), findsOneWidget);
    expect(find.textContaining('Reportá en segundos'), findsOneWidget);
  });

  testWidgets('Yago smoke test - shows login screen directly', (WidgetTester tester) async {
    // Construir la app y disparar un frame
    await tester.pumpWidget(const YagoApp(home: LoginScreen()));

    // Verificar que el logo de Yago y el botón de inicio de sesión estén presentes
    expect(find.byType(YagoLogo), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
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

  testWidgets('RegisterScreen renders form fields correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
  });

  testWidgets('PetCard renders pet information and contact action', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetCard(
            name: 'Luna',
            details: 'Lhasa Apso · Hembra · 3 años',
            locationAndTime: 'Palermo, CABA · Hace 2 horas',
            imageUrl: 'https://example.com/pet.jpg',
            status: YagoPetStatus.lost,
            tags: const ['Collar rojo', 'Con chip'],
          ),
        ),
      ),
    );

    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Lhasa Apso · Hembra · 3 años'), findsOneWidget);
    expect(find.text('Palermo, CABA'), findsOneWidget);
    expect(find.text('Hace 2 horas'), findsOneWidget);
    expect(find.text('PERDIDA'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
    expect(find.byType(AnimatedPawIcon), findsOneWidget);
  });
}
