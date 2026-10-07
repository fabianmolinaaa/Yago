import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/main.dart';
import 'package:yago/screens/auth/login_screen.dart';
import 'package:yago/screens/auth/register_screen.dart';
import 'package:yago/screens/home/create_post_screen.dart';
import 'package:yago/screens/home/create_report_screen.dart';
import 'package:yago/screens/home/edit_profile_screen.dart';
import 'package:yago/screens/home/home_screen.dart';
import 'package:yago/screens/home/feed_tab.dart';
import 'package:yago/screens/home/profile_tab.dart';
import 'package:yago/screens/home/reports_feed_tab.dart';
import 'package:yago/models/feed_post.dart';
import 'package:yago/models/pet.dart';
import 'package:yago/screens/onboarding/onboarding_screen.dart';
import 'package:yago/services/mock_data_service.dart';
import 'package:yago/widgets/common/widgets.dart';
import 'package:yago/screens/pet_detail/pet_detail_screen.dart';

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

  testWidgets('RegisterScreen renders form fields correctly and validates inputs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);

    // Intentar registrarse con campos vacíos activa la validación
    final registerButton = find.text('Registrarse');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
    expect(find.text('Por favor, ingresa tu nombre completo.'), findsOneWidget);
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

    // Navegar a Pestaña 1: Feed de Reportes (activo con vista mosaico de reportes)
    await tester.tap(find.byTooltip('Reportes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Reportes'), findsWidgets);

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

  testWidgets('ProfileTab does not show hardcoded demo data and shows clean empty states', (WidgetTester tester) async {
    MockDataService().clearUserProfileCache();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // No debe mostrar publicaciones ajenas de prueba (costanera o Luna)
    expect(find.textContaining('Paseando por la costanera'), findsNothing);
    expect(find.textContaining('¡Buscamos a Luna!'), findsNothing);

    // No debe mostrar la biografía hardcodeada antigua
    expect(find.textContaining('Amante de los animales y voluntario en la comunidad Yago'), findsNothing);

    // No debe mostrar fecha fija de febrero de 2024
    expect(find.text('Se unió en febrero de 2024'), findsNothing);

    // Debe mostrar la descripción vacía limpia y minimalista
    expect(find.text('Sin descripción.'), findsOneWidget);

    // En su lugar debe mostrar el estado vacío de publicaciones
    expect(find.text('Sin publicaciones aún'), findsOneWidget);

    // Navegar a Reportes y comprobar estado vacío sin reportes ajenos
    await tester.tap(find.text('Reportes'));
    await tester.pumpAndSettle();
    expect(find.text('Sin reportes activos'), findsOneWidget);
  });

  testWidgets('ProfileTab shows post options menu and triggers delete dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const ownPost = FeedPost(
      id: 'my-test-post-1',
      authorId: null,
      authorName: 'Usuario',
      content: 'Contenido de prueba para el menú de opciones',
      timeAgo: 'Recién publicado',
      createdAt: null,
    );
    await MockDataService().addCommunityPost(ownPost);
    await tester.pumpAndSettle();

    expect(find.text('Contenido de prueba para el menú de opciones'), findsOneWidget);

    // Buscar el botón de opciones (tres puntos) en la tarjeta
    final moreOptionsFinder = find.byIcon(Icons.more_horiz_rounded);
    expect(moreOptionsFinder, findsWidgets);

    // Tocar el botón de tres puntos de la tarjeta
    await tester.tap(moreOptionsFinder.first);
    await tester.pumpAndSettle();

    // Comprobar que el menú popup se despliega con las opciones requeridas
    expect(find.text('Copiar texto'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
    expect(find.text('Eliminar publicación'), findsOneWidget);

    // Tocar eliminar publicación
    await tester.tap(find.text('Eliminar publicación'));
    await tester.pumpAndSettle();

    // Comprobar que se muestra el diálogo de confirmación
    expect(find.text('¿Eliminar publicación?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    // Confirmar eliminación
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    // El post ya no debe estar
    expect(find.text('Contenido de prueba para el menú de opciones'), findsNothing);
  });

  group('YagoPetImage asset resolution and rendering', () {
    test('resolveAssetFallback maps storage URLs to bundled assets', () {
      expect(
        YagoPetImage.resolveAssetFallback(
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_caniche.jpg?alt=media&token=123',
        ),
        'assets/images/IMG_3508.JPG',
      );
      expect(
        YagoPetImage.resolveAssetFallback(
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Frocky_labrador.jpg?alt=media&token=123',
        ),
        'assets/images/IMG_4178.JPG',
      );
      expect(
        YagoPetImage.resolveAssetFallback(
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fsimba_golden.jpg?alt=media&token=123',
        ),
        'assets/images/IMG_5370.JPG',
      );
      expect(
        YagoPetImage.resolveAssetFallback(
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fmilo_gato.jpg?alt=media&token=123',
        ),
        'assets/images/IMG_2935.JPG',
      );
      expect(
        YagoPetImage.resolveAssetFallback(
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_reunida.jpg?alt=media&token=123',
        ),
        'assets/images/IMG_5667.JPG',
      );
      expect(
        YagoPetImage.resolveAssetFallback(
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_final_feliz.jpg?alt=media&token=123',
        ),
        'assets/images/IMG_5560.JPG',
      );
      expect(YagoPetImage.resolveAssetFallback(''), isNull);
      expect(YagoPetImage.resolveAssetFallback(null), isNull);
    });

    testWidgets('YagoPetImage renders local asset directly for seed storage URLs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: YagoPetImage(
              imageUrl:
                  'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_caniche.jpg?alt=media&token=c423ae85-7535-49ca-ac88-110119309b7f',
            ),
          ),
        ),
      );

      // Debe renderizar un widget Image cargando el asset local sin quedar en placeholder genérico
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsNothing);
    });

    testWidgets('YagoPetImage renders placeholder when URL is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: YagoPetImage(imageUrl: ''),
          ),
        ),
      );

      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
    });
  });

  testWidgets('Design System - YagoPostCategoryBadge renders category label and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              YagoPostCategoryBadge(category: 'Consejo'),
              YagoPostCategoryBadge(category: 'Reencuentro'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('CONSEJO'), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);
    expect(find.text('REENCUENTRO'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('FeedTab displays options menu with report and hide for other users posts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Comprobar que existen botones de opciones (...) en el feed
    final optionsButtons = find.byIcon(Icons.more_horiz_rounded);
    expect(optionsButtons, findsWidgets);

    // Tocar el primer botón de opciones (publicación de un tercero)
    await tester.tap(optionsButtons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Debe mostrar Opciones generales y de moderación
    expect(find.text('Copiar texto'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
    expect(find.text('Ocultar publicación'), findsOneWidget);
    expect(find.text('Reportar publicación'), findsOneWidget);

    // NUNCA debe mostrar 'Eliminar publicación' ni 'Eliminar reporte' para posts de otros usuarios
    expect(find.text('Eliminar publicación'), findsNothing);
    expect(find.text('Eliminar reporte'), findsNothing);
  });

  testWidgets('FeedTab community post header renders without horizontal overflow', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.text('Veterinaria San Roque'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Veterinaria San Roque'), findsOneWidget);
    expect(find.text('CONSEJO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FeedTab pull to refresh triggers smoothly without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Ejecutar gesto de deslizar hacia abajo para activar RefreshIndicator
    await tester.fling(find.byType(CustomScrollView), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // El feed debe mantenerse renderizado y estable
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('ReportsFeedTab displays exclusively lost and found reports in panoramic grid view', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsFeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar encabezado oficial y contador
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.byIcon(Icons.campaign_rounded), findsWidgets);

    // Debe mostrar tarjetas en mosaico rápido (ReportGridCard)
    expect(find.byType(ReportGridCard), findsWidgets);

    // Verificar presencia de reportes de pérdida y hallazgo existentes
    expect(find.text('Luna'), findsWidgets); // Reporte perdido
    expect(find.text('Thor'), findsWidgets); // Reporte encontrado
    expect(find.text('Perdida'), findsWidgets);
    expect(find.text('Encontrada'), findsWidgets);

    // NUNCA debe contener publicaciones comunitarias ni de apareamiento
    expect(find.text('Paseando un rato...'), findsNothing);
    expect(find.text('Buscamos compañera para cruza.'), findsNothing);
  });

  testWidgets('ReportsFeedTab displays Pinterest-style cards with more options bottom sheet', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsFeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Debe mostrar tarjetas en distribución Pinterest (ReportGridCard)
    expect(find.byType(ReportGridCard), findsWidgets);

    // Tocar el botón de tres puntos (...) en la primera tarjeta
    final moreOptions = find.byIcon(Icons.more_horiz_rounded);
    expect(moreOptions, findsWidgets);
    await tester.tap(moreOptions.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Debe desplegar el menú de opciones inferior
    expect(find.text('Ver zona en mapa'), findsOneWidget);
    expect(find.text('Ver ficha completa'), findsOneWidget);
    expect(find.text('Guardar reporte'), findsOneWidget);
  });

  testWidgets('ReportsFeedTab filters by species exclusively via header button and searches by text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsFeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Abrir modal de filtros exclusivamente desde el header
    await tester.tap(find.byTooltip('Filtrar reportes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Seleccionar filtro de Gatos
    await tester.tap(find.text('🐱 Gatos'));
    await tester.pump();

    // Aplicar filtros
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Solo debe verse Milo el gato
    expect(find.text('Milo (Nombre asignado)'), findsOneWidget);
    expect(find.text('Thor'), findsNothing);

    // Restablecer filtros desde el header
    await tester.tap(find.byTooltip('Filtrar reportes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Restablecer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Activar buscador de raza / zona
    await tester.tap(find.byTooltip('Buscar por raza o zona'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TextField), findsOneWidget);

    // Escribir 'Caniche'
    await tester.enterText(find.byType(TextField), 'Caniche');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Solo debe verse Luna la Caniche
    expect(find.text('Luna'), findsWidgets);
    expect(find.text('Thor'), findsNothing);
  });

  testWidgets('ContextualZoneModal displays neighborhood approximate zone radius and safety note', (WidgetTester tester) async {
    final testPet = MockDataService().getAllPets().firstWhere((p) => p.status == YagoPetStatus.lost);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ContextualZoneModal.show(ctx, testPet),
              child: const Text('Abrir Zona'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir Zona'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar mapa real, controles de mapa, radio aproximado y botón Abrir en Maps
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
    expect(find.textContaining('Radio estimado de 500m'), findsOneWidget);
    expect(find.textContaining('Por seguridad comunitaria, se muestra un radio contextual aproximado'), findsOneWidget);
    expect(find.text('Abrir en Maps'), findsOneWidget);
  });

  testWidgets('CreateReportScreen renders elegant switch, age field, aligned tag button, and detects location', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateReportScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verificar el selector compacto y limpio (Perdí mi mascota / Encontré una mascota)
    expect(find.text('Perdí mi mascota'), findsOneWidget);
    expect(find.text('Encontré una mascota'), findsOneWidget);

    // Cambiar a "Encontré una mascota"
    await tester.tap(find.text('Encontré una mascota'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 2. Verificar secciones principales y ausencia de encabezados duplicados
    expect(find.text('INFORMACIÓN DE LA MASCOTA'), findsOneWidget);
    expect(find.text('DÓNDE Y CUÁNDO'), findsOneWidget);
    // No deben existir encabezados redundantes en mayúsculas repetidos
    expect(find.text('DESCRIPCIÓN'), findsNothing);
    expect(find.text('CONTACTO'), findsNothing);

    // 3. Verificar labels consistentes y unificados
    expect(find.text('Nombre de la mascota'), findsOneWidget);
    expect(find.text('Ubicación'), findsOneWidget);

    // 4. Verificar campo de Edad neutral y opción "No conozco la edad"
    expect(find.text('Edad aproximada'), findsOneWidget);
    await tester.ensureVisible(find.text('No conozco la edad'));
    await tester.pumpAndSettle();
    expect(find.text('No conozco la edad'), findsOneWidget);
    await tester.tap(find.text('No conozco la edad'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 5. Verificar teléfonos múltiples con botón +
    expect(find.text('Teléfono o WhatsApp de contacto'), findsOneWidget);
    final phoneField = find.widgetWithText(TextField, '');
    expect(phoneField, findsWidgets);

    // 6. Verificar señas particulares con botón + integrado y sin sugerencias fijas
    expect(find.text('Señas particulares (chips, collar, manchas)'), findsOneWidget);
    expect(find.text('Sugerencias:'), findsNothing);

    // 7. Verificar detección de ubicación actual ("Usar mi ubicación")
    await tester.ensureVisible(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();
    expect(find.text('Usar mi ubicación'), findsOneWidget);

    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 8. Verificar botón unificado "Publicar reporte" y aclaración
    await tester.ensureVisible(find.byType(YagoButton));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Al publicar, otras personas podrán ver este reporte y contactarte.'), findsOneWidget);
    expect(find.widgetWithText(YagoButton, 'Publicar reporte'), findsOneWidget);
  });

  testWidgets('CreateReportScreen opens MapLocationPickerModal and picks a location on the map', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateReportScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Desplazarse hasta el campo de ubicación
    await tester.ensureVisible(find.text('Ubicar en el mapa').first);
    await tester.pumpAndSettle();

    // Tocar "Ubicar en el mapa"
    await tester.tap(find.text('Ubicar en el mapa').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar que el modal de selección de mapa se abre correctamente
    expect(find.text('Ubicar en el mapa'), findsWidgets);
    expect(find.text('Elige la zona donde ocurrió el extravío o hallazgo'), findsOneWidget);
    expect(find.text('Confirmar esta ubicación'), findsOneWidget);

    // Seleccionar una zona rápida de referencia en el mapa
    expect(find.text('Plaza Armenia, Palermo'), findsOneWidget);
    await tester.tap(find.text('Plaza Armenia, Palermo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Confirmar la ubicación seleccionada
    await tester.tap(find.text('Confirmar esta ubicación'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar que el campo Ubicación se actualizó con la zona elegida
    expect(find.text('Plaza Armenia, Palermo'), findsWidgets);
  });

  testWidgets('MapLocationPickerModal searches address, selects result, and updates map position', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateReportScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Abrir modal de mapa
    await tester.ensureVisible(find.text('Ubicar en el mapa').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ubicar en el mapa').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Buscar dirección en el buscador
    final searchInput = find.widgetWithText(TextField, 'Buscar plaza, barrio o calle...');
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'Santa Fe');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verificar que aparece el resultado de búsqueda
    expect(find.text('Santa Fe, CABA'), findsOneWidget);

    // Tocar el resultado de búsqueda
    await tester.tap(find.text('Santa Fe, CABA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verificar que el punto seleccionado en el mapa se actualizó a la dirección buscada
    expect(find.text('Santa Fe, CABA'), findsWidgets);

    // Confirmar
    await tester.tap(find.text('Confirmar esta ubicación'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // El campo Ubicación del reporte ahora contiene la dirección buscada
    expect(find.text('Santa Fe, CABA'), findsWidgets);
  });

  testWidgets('PetDetailScreen renders header with name on left and badge+time on right, adaptive icons, and no sighting button', (WidgetTester tester) async {
    final pet = Pet(
      id: 'test-pet-dog',
      name: 'Luna',
      breed: 'Caniche',
      species: 'Perro',
      gender: 'Hembra',
      age: '3 años',
      status: YagoPetStatus.lost,
      location: 'Palermo, CABA',
      timeAgo: 'Hace 2 horas',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Se extravió en Plaza Armenia.',
      imageUrl: 'assets/images/IMG_3508.JPG',
      tags: const ['Collar rosa', 'Con chip'],
      contactName: 'Camila Rodriguez',
      contactPhone: '+54 9 11 1234-5678',
      latitude: -34.5889,
      longitude: -58.4233,
      isUserOwner: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PetDetailScreen(pet: pet),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Nombre y raza a la izquierda, estado y horario
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('PERDIDA'), findsOneWidget);
    expect(find.text('Hace 2 horas'), findsOneWidget);

    // Atributos con iconos adaptados (Hembra -> female, Edad -> cake, Perro -> pets)
    expect(find.byIcon(Icons.female_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cake_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);

    // Título Descripción coincide con crear reporte
    expect(find.text('Descripción'), findsOneWidget);

    // Botón Aportar dato e Historia con final feliz NO deben estar presentes
    expect(find.text('Aportar dato'), findsNothing);
    expect(find.text('Historia con final feliz'), findsNothing);

    // Botón Contactar está presente
    expect(find.text('Contactar'), findsOneWidget);
  });

  testWidgets('PetDetailScreen renders cat with CatIcon and Macho icon', (WidgetTester tester) async {
    final pet = Pet(
      id: 'test-pet-cat',
      name: 'Milo',
      breed: 'Siamés',
      species: 'Gato',
      gender: 'Macho',
      age: '1 año',
      status: YagoPetStatus.found,
      location: 'Recoleta, CABA',
      timeAgo: 'Hace 1 hora',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Encontrado en un balcón.',
      imageUrl: 'assets/images/IMG_2935.JPG',
      tags: const ['Ojos azules'],
      contactName: 'Lucas Paz',
      contactPhone: '+54 9 11 9876-5432',
      latitude: -34.5889,
      longitude: -58.4233,
      isUserOwner: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PetDetailScreen(pet: pet),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Icono de gato específico y macho
    expect(find.byType(CatIcon), findsOneWidget);
    expect(find.byIcon(Icons.male_rounded), findsOneWidget);
  });

  testWidgets('PetDetailScreen opens ContextualZoneModal when tapping ultima ubicacion registrada', (WidgetTester tester) async {
    final pet = Pet(
      id: 'test-pet-map',
      name: 'Simba',
      breed: 'Golden Retriever',
      species: 'Perro',
      gender: 'Macho',
      age: '2 años',
      status: YagoPetStatus.lost,
      location: 'Belgrano, CABA',
      timeAgo: 'Hace 30 min',
      date: DateTime.now().subtract(const Duration(minutes: 30)),
      description: 'Visto cerca de Barrancas de Belgrano.',
      imageUrl: 'assets/images/IMG_4178.JPG',
      tags: const ['Collar azul'],
      contactName: 'Martina Gomez',
      contactPhone: '+54 9 11 5555-4444',
      latitude: -34.5614,
      longitude: -58.4563,
      isUserOwner: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PetDetailScreen(pet: pet),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Desplazar hasta la sección de ubicación y tocar el botón de mapa
    await tester.scrollUntilVisible(find.byIcon(Icons.map_outlined), 100);
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Se debe abrir el modal de zona en mapa ContextualZoneModal
    expect(find.byType(ContextualZoneModal), findsOneWidget);
    expect(find.textContaining('Radio estimado'), findsOneWidget);
    expect(find.text('Abrir en Maps'), findsOneWidget);
  });

  testWidgets('PetDetailScreen owner can mark as recovered with confirmation dialog and resolve case', (WidgetTester tester) async {
    final pet = Pet(
      id: 'test-pet-owner-recovered',
      name: 'Toby',
      breed: 'Beagle',
      species: 'Perro',
      gender: 'Macho',
      age: '4 años',
      status: YagoPetStatus.lost,
      location: 'Caballito, CABA',
      timeAgo: 'Hace 4 horas',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      description: 'Extraviado en Parque Rivadavia.',
      imageUrl: 'assets/images/IMG_5370.JPG',
      tags: const ['Orejas largas'],
      contactName: 'Usuario Yago',
      contactPhone: '+54 9 11 2222-3333',
      latitude: -34.6180,
      longitude: -58.4350,
      isUserOwner: true,
    );

    // Agregar a MockDataService para verificar resolución
    await MockDataService().addPet(pet);

    await tester.pumpWidget(
      MaterialApp(
        home: PetDetailScreen(pet: pet),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Desplazar hasta el botón de marcar como recuperada
    await tester.scrollUntilVisible(find.text('Marcar como recuperada'), 100);
    await tester.pump(const Duration(milliseconds: 200));

    // Debe mostrar el botón de marcar como recuperada
    expect(find.text('Marcar como recuperada'), findsOneWidget);

    // Tocar botón
    await tester.tap(find.text('Marcar como recuperada'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar que pregunta por seguridad si está seguro
    expect(find.text('¿Marcar como recuperada?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Sí, marcar como recuperada'), findsOneWidget);

    // Confirmar
    await tester.tap(find.text('Sí, marcar como recuperada'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Caso resuelto: feedback mostrado
    expect(find.textContaining('¡Caso resuelto!'), findsOneWidget);

    // Verificar que el estado en MockDataService ahora es reunited
    final updated = MockDataService().getAllPets().firstWhere((p) => p.id == 'test-pet-owner-recovered');
    expect(updated.status, equals(YagoPetStatus.reunited));
  });
}





