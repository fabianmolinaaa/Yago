import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/main.dart';
import 'package:yago/screens/auth/login_screen.dart';
import 'package:yago/screens/auth/register_screen.dart';
import 'package:yago/screens/home/create_post_screen.dart';
import 'package:yago/screens/home/edit_profile_screen.dart';
import 'package:yago/screens/home/home_screen.dart';
import 'package:yago/screens/home/profile_tab.dart';
import 'package:yago/screens/onboarding/onboarding_screen.dart';
import 'package:yago/widgets/common/widgets.dart';

void main() {
  testWidgets('OnboardingScreen renders minimalist screen with map tip, motto, and CTA buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const YagoApp(home: OnboardingScreen(showIntro: false)));

    // Verificar presencia del logo, lema editorial minimalista
    expect(find.byType(YagoLogo), findsOneWidget);
    expect(find.textContaining('Explora, Conecta'), findsOneWidget);

    // Verificar presencia de la imagen del mapa
    expect(find.byType(Image), findsWidgets);

    // Verificar botones de acción
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear una cuenta'), findsOneWidget);
  });

  testWidgets('OnboardingScreen presentation intro runs and transitions to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const YagoApp(home: OnboardingScreen(showIntro: true)));

    // Al inicio debe mostrarse el logo sin texto
    expect(find.byType(Image), findsWidgets);

    // Avanzamos el tiempo de animación hacia la aparición del texto "Yago"
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Yago'), findsWidgets);

    // Completar la animación de intro hacia el onboarding
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Debe mostrar la pantalla principal de onboarding
    expect(find.textContaining('Explora, Conecta'), findsOneWidget);
  });

  testWidgets('OnboardingScreen navigation to LoginScreen and back button works', (WidgetTester tester) async {
    await tester.pumpWidget(const YagoApp(home: OnboardingScreen(showIntro: false)));

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
    expect(find.textContaining('Explora, Conecta'), findsOneWidget);
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
        home: Column(
          children: [
            YagoStatusBadge(status: YagoPetStatus.lost),
            YagoStatusBadge(status: YagoPetStatus.mating),
          ],
        ),
      ),
    );

    expect(find.text('PERDIDA'), findsOneWidget);
    expect(find.text('APAREAMIENTO'), findsOneWidget);
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

  testWidgets('PetCard renders community post with Yago logo and Equipo Yago branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetCard(
            name: 'Rocky',
            details: 'Mestizo de Labrador · 2 años',
            locationAndTime: 'Costanera, Caleta Olivia · Hace 5 horas',
            imageUrl: 'assets/images/IMG_4178.JPG',
            status: YagoPetStatus.community,
            tags: const ['Pelaje negro'],
          ),
        ),
      ),
    );

    expect(find.text('Rocky'), findsOneWidget);
    expect(find.text('Equipo Yago'), findsOneWidget);
    expect(find.text('COMUNIDAD'), findsOneWidget);
    expect(find.byType(YagoLogoIcon), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('ComingSoonView renders title, badge and description', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ComingSoonView(
          title: 'Cámara con IA',
          description: 'Próximamente análisis inteligente de mascotas.',
          icon: Icons.center_focus_strong_rounded,
          badgeText: 'PRÓXIMAMENTE',
        ),
      ),
    );

    expect(find.text('Cámara con IA'), findsWidgets);
    expect(find.text('PRÓXIMAMENTE'), findsOneWidget);
    expect(find.text('Próximamente análisis inteligente de mascotas.'), findsOneWidget);
    expect(find.byIcon(Icons.center_focus_strong_rounded), findsOneWidget);
  });

  testWidgets('HomeScreen navigates between feed, reports, camera, chat, and profile', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Pestaña 0 activa inicialmente: Feed de publicaciones
    expect(find.text('Luna'), findsWidgets);

    // Navegar a Pestaña 1: Feed de Reportes (En construcción / Próximamente)
    await tester.tap(find.byTooltip('Reportes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Feed de Reportes'), findsWidgets);
    expect(find.text('PRÓXIMAMENTE'), findsOneWidget);

    // Navegar a Pestaña 2: Cámara con IA (En construcción / Próximamente)
    await tester.tap(find.byTooltip('Cámara con IA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Cámara con IA'), findsWidgets);

    // Navegar a Pestaña 3: Chat Directo (En construcción / Próximamente)
    await tester.tap(find.byTooltip('Chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Chat Directo'), findsWidgets);

    // Navegar a Pestaña 4: Perfil
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Compartir perfil'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
  });

  testWidgets('ProfileTab shows profile info and logout button is accessible', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileTab(),
        ),
      ),
    );

    expect(find.text('Compartir perfil'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Guardados'), findsOneWidget);

    // Tocar el menú de opciones del AppBar para acceder a Cerrar sesión
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    final logoutOptionFinder = find.text('Cerrar sesión');
    expect(logoutOptionFinder, findsOneWidget);
    await tester.tap(logoutOptionFinder);
    await tester.pumpAndSettle();

    // Comprobar que aparece el diálogo de confirmación
    expect(find.text('¿Estás seguro de que deseas salir de tu cuenta?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('CreatePostScreen renders category chips, content field and publish action', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreatePostScreen(),
      ),
    );

    expect(find.text('Crear Publicación'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
    expect(find.text('Descripción de la publicación'), findsOneWidget);
    expect(find.textContaining('Perdida'), findsWidgets);
    expect(find.textContaining('Apareamiento'), findsOneWidget);
    expect(find.textContaining('Consejo'), findsOneWidget);
    expect(find.textContaining('Reencuentro'), findsOneWidget);
    expect(find.text('Anécdota'), findsNothing);

    // Al seleccionar el chip de Apareamiento deben mostrarse los campos contextuales
    await tester.tap(find.textContaining('Apareamiento'));
    await tester.pumpAndSettle();

    expect(find.text('Búsqueda de pareja / Apareamiento'), findsOneWidget);
    expect(find.text('Nombre de la mascota'), findsOneWidget);
    expect(find.text('Raza'), findsOneWidget);
    expect(find.text('Sexo'), findsOneWidget);
    expect(find.text('Macho'), findsOneWidget);
    expect(find.text('Hembra'), findsOneWidget);
  });

  testWidgets('EditProfileScreen renders fields and allows saving changes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditProfileScreen(
          initialName: 'Fabián Molina',
          initialBio: 'Amante de los animales',
          initialLocation: 'Santa Cruz, Argentina',
          initialPhone: '+54 9 297 412-3456',
        ),
      ),
    );

    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
    expect(find.text('Cambiar foto de perfil'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Biografía'), findsOneWidget);
    expect(find.text('Ubicación'), findsOneWidget);
    expect(find.text('Teléfono de contacto'), findsOneWidget);

    // Verificar valores iniciales
    expect(find.text('Fabián Molina'), findsOneWidget);
    expect(find.text('Amante de los animales'), findsOneWidget);

    // Pulsar Guardar cambios
    final saveButtonFinder = find.text('Guardar cambios');
    await tester.ensureVisible(saveButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();
  });
}
