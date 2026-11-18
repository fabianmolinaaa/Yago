import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/main.dart';
import 'package:yago/screens/auth/login_screen.dart';
import 'package:yago/screens/auth/register_screen.dart';
import 'package:yago/screens/home/ai_camera_screen.dart';
import 'package:yago/screens/home/create_post_screen.dart';
import 'package:yago/screens/home/create_report_screen.dart';
import 'package:yago/screens/home/direct_chat_screen.dart';
import 'package:yago/screens/home/direct_chats_tab.dart';
import 'package:yago/screens/home/edit_profile_screen.dart';
import 'package:yago/screens/home/home_screen.dart';
import 'package:yago/screens/home/feed_tab.dart';
import 'package:yago/screens/home/profile_tab.dart';
import 'package:yago/screens/home/reports_feed_tab.dart';
import 'package:yago/models/feed_post.dart';
import 'package:yago/models/pet.dart';
import 'package:yago/screens/onboarding/onboarding_screen.dart';
import 'package:yago/services/ai_vision_service.dart';
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
            locationAndTime: 'Costanera, Caleta Olivia · Hace 2 horas',
            imageUrl: 'https://example.com/pet.jpg',
            status: YagoPetStatus.lost,
            tags: const ['Collar rojo', 'Con chip'],
          ),
        ),
      ),
    );

    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Lhasa Apso · Hembra · 3 años'), findsOneWidget);
    expect(find.text('Costanera, Caleta Olivia'), findsOneWidget);
    expect(find.text('Hace 2 horas'), findsOneWidget);
    expect(find.text('PERDIDA'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
    expect(find.byType(AnimatedPawIcon), findsNothing);
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

  testWidgets('PetCard starts with 0 likes by default, increments on tap, and fires onLikeTap', (WidgetTester tester) async {
    bool likeTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetCard(
            name: 'Luna',
            details: 'Lhasa Apso · Hembra · 3 años',
            locationAndTime: 'Costanera, Caleta Olivia · Hace 2 horas',
            imageUrl: 'https://example.com/pet.jpg',
            status: YagoPetStatus.lost,
            onLikeTap: () {
              likeTapped = true;
            },
          ),
        ),
      ),
    );

    // Initial likes count is 0 (no hardcoded 142)
    expect(find.text('0'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    // Tap like button
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pump();

    // Now has 1 like, icon turns filled, callback triggered
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(likeTapped, isTrue);

    // Tap again to unlike
    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
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

    // Navegar a Pestaña 2: Cámara con IA (Escáner en vivo a pantalla completa estilo QR Mercado Pago)
    await tester.tap(find.byTooltip('Cámara con IA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Cámara con IA'), findsWidgets);
    expect(find.text('Tomar foto'), findsOneWidget);
    expect(find.text('Cargar de galería'), findsOneWidget);

    // Cerrar el escáner de cámara para volver a la barra de navegación
    await tester.tap(find.byTooltip('Cerrar cámara'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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
    expect(find.text('Agrega una descripción...'), findsOneWidget);
    expect(find.text('Agregar Fotos'), findsOneWidget);
    expect(find.text('Agregar Etiqueta'), findsOneWidget);

    // Perdida y Encontrada ya no están en Crear Publicación (exclusivos de Crear Reporte)
    expect(find.textContaining('Perdida'), findsNothing);
    expect(find.textContaining('Encontrada'), findsNothing);

    // Las 5 etiquetas comunitarias deben estar presentes
    expect(find.textContaining('Consejo'), findsOneWidget);
    expect(find.textContaining('Reencuentro'), findsOneWidget);
    expect(find.textContaining('Apareamiento'), findsOneWidget);
    expect(find.textContaining('Aviso'), findsOneWidget);
    expect(find.textContaining('Salud'), findsOneWidget);

    // Al seleccionar la etiqueta de Apareamiento deben mostrarse el indicador de etiqueta y los campos contextuales
    await tester.tap(find.textContaining('Apareamiento'));
    await tester.pumpAndSettle();

    expect(find.text('Etiqueta seleccionada: Apareamiento'), findsOneWidget);
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

    // Navegar a Guardados y comprobar estado vacío inicial
    await tester.tap(find.text('Guardados'));
    await tester.pumpAndSettle();
    expect(find.text('No tienes elementos guardados'), findsOneWidget);
  });

  testWidgets('ProfileTab Guardados displays saved reports and posts and allows unbookmarking', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mock = MockDataService();
    mock.toggleBookmark('pet-1'); // Guardamos a Luna

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cambiar a la pestaña Guardados
      await tester.tap(find.text('Guardados'));
      await tester.pumpAndSettle();

      // Debe mostrar a Luna en guardados
      expect(find.text('Luna'), findsOneWidget);

      // Tocar el botón de bookmark para quitarlo
      final bookmarkBtn = find.byIcon(Icons.bookmark_rounded);
      expect(bookmarkBtn, findsWidgets);
      await tester.ensureVisible(bookmarkBtn.first);
      await tester.pumpAndSettle();
      await tester.tap(bookmarkBtn.first);
      await tester.pumpAndSettle();

      // Ya no debe estar guardado
      expect(find.text('Luna'), findsNothing);
      expect(find.text('No tienes elementos guardados'), findsOneWidget);
    } finally {
      if (mock.isBookmarked('pet-1')) {
        mock.toggleBookmark('pet-1');
      }
    }
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
    await tester.ensureVisible(moreOptions.first);
    await tester.pump();
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

    // Verificar que no exista el filtro de "Ciudad o localidad" dentro del modal de filtros
    expect(find.text('Ciudad o localidad'), findsNothing);

    // Seleccionar filtro de Gatos con icono elegante
    await tester.tap(find.text('Gatos'));
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

    // Filtrar por raza 'Caniche' desde el modal de filtros
    await tester.tap(find.byTooltip('Filtrar reportes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Caniche').first);
    await tester.pump();
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Solo debe verse Luna la caniche
    expect(find.text('Luna'), findsWidgets);
    expect(find.text('Thor'), findsNothing);

    // Restablecer filtros nuevamente
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

  testWidgets('ReportsFeedTab filters reports by city Marketplace-style (HU-S2-06)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsFeedTab(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Debe mostrar por defecto la barra de ubicación con Caleta Olivia
    expect(find.text('Caleta Olivia'), findsWidgets);
    expect(find.text('Ver todas'), findsOneWidget);

    // 2. Reportes locales de Caleta Olivia visibles por defecto
    expect(find.text('Luna'), findsWidgets);
    expect(find.text('Thor'), findsWidgets);

    // 3. Tocar el pill de ubicación para abrir el modal selector de ciudad
    await tester.tap(find.text('Caleta Olivia').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar contenido del modal selector de ciudad
    expect(find.text('Ubicación de reportes'), findsOneWidget);
    expect(find.text('Usar mi ubicación actual'), findsOneWidget);
    expect(find.text('Todas las ciudades'), findsWidgets);

    // 4. Buscar una ciudad sin reportes para verificar estado vacío
    final citySearchField = find.widgetWithText(TextField, 'Buscar ciudad o localidad...');
    expect(citySearchField, findsOneWidget);
    await tester.enterText(citySearchField, 'Trelew');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verificar que aparezca el encabezado de sugerencias dinámicas y la sugerencia de Trelew (Chubut)
    expect(find.text('Sugerencias para "Trelew"'), findsOneWidget);
    final trelewTile = find.widgetWithText(ListTile, 'Trelew');
    expect(trelewTile, findsOneWidget);
    await tester.tap(trelewTile);
    await tester.pumpAndSettle();

    // Debe mostrar estado vacío específico de la ciudad
    expect(find.text('No hay reportes en Trelew'), findsOneWidget);
    expect(find.text('Ver todas las ciudades'), findsOneWidget);

    // 5. Tocar "Ver todas las ciudades" para restaurar la vista completa
    await tester.tap(find.text('Ver todas las ciudades'));
    await tester.pumpAndSettle();

    // Debe volver a mostrar todos los reportes y el pill cambia a "Todas las ciudades"
    expect(find.text('Todas las ciudades'), findsWidgets);
    expect(find.text('Luna'), findsWidgets);
    expect(find.text('Thor'), findsWidgets);
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

    // 5. Verificar teléfonos múltiples con botón + y label "Teléfono"
    expect(find.text('Teléfono'), findsOneWidget);
    expect(find.text('Teléfono o WhatsApp de contacto'), findsNothing);
    final phoneField = find.widgetWithText(TextField, '');
    expect(phoneField, findsWidgets);

    // 6. Verificar señas particulares con botón + integrado y sin sugerencias fijas
    expect(find.text('Señas particulares (chips, collar, manchas)'), findsOneWidget);
    expect(find.text('Sugerencias:'), findsNothing);

    // 7. Verificar detección de ubicación actual mediante el botón a la derecha de la entrada (sin labels inferiores)
    expect(find.text('Usar mi ubicación'), findsNothing);
    expect(find.text('Ubicar en el mapa'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Usar mi ubicación'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Usar mi ubicación'), findsOneWidget);
    expect(find.byTooltip('Ubicar en el mapa'), findsOneWidget);

    await tester.tap(find.byTooltip('Usar mi ubicación'));
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

    // Desplazarse hasta el botón de ubicar en el mapa a la derecha del campo de ubicación
    await tester.ensureVisible(find.byTooltip('Ubicar en el mapa'));
    await tester.pumpAndSettle();

    // Tocar "Ubicar en el mapa"
    await tester.tap(find.byTooltip('Ubicar en el mapa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar que el modal de selección de mapa se abre correctamente y sin chips de sugerencias debajo del buscador
    expect(find.text('Ubicar en el mapa'), findsWidgets);
    expect(find.text('Elige la zona donde ocurrió el extravío o hallazgo'), findsOneWidget);
    expect(find.text('Confirmar esta ubicación'), findsOneWidget);
    expect(find.text('El Gorosito (Centro)'), findsNothing);

    // Confirmar la ubicación seleccionada
    await tester.tap(find.text('Confirmar esta ubicación'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar que el campo Ubicación se actualizó con la ubicación del mapa
    expect(find.text('Costanera, Caleta Olivia'), findsWidgets);
  });

  testWidgets('MapLocationPickerModal searches address, selects result, and updates map position', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateReportScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Abrir modal de mapa desde el botón a la derecha de la entrada de ubicación
    await tester.ensureVisible(find.byTooltip('Ubicar en el mapa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ubicar en el mapa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Buscar dirección en el buscador
    final searchInput = find.widgetWithText(TextField, 'Buscar plaza, barrio o calle...');
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'Santa Fe');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verificar que aparece el resultado de búsqueda
    expect(find.text('Santa Fe, Caleta Olivia'), findsOneWidget);

    // Tocar el resultado de búsqueda
    await tester.tap(find.text('Santa Fe, Caleta Olivia'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verificar que el punto seleccionado en el mapa se actualizó a la dirección buscada
    expect(find.text('Santa Fe, Caleta Olivia'), findsWidgets);

    // Confirmar
    await tester.tap(find.text('Confirmar esta ubicación'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // El campo Ubicación del reporte ahora contiene la dirección buscada
    expect(find.text('Santa Fe, Caleta Olivia'), findsWidgets);
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
      location: 'Centro, El Gorosito, Caleta Olivia',
      timeAgo: 'Hace 2 horas',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Se extravió cerca de El Gorosito.',
      imageUrl: 'assets/images/IMG_3508.JPG',
      tags: const ['Collar rosa', 'Con chip'],
      contactName: 'Camila Rodriguez',
      contactPhone: '+54 9 297 1234-5678',
      latitude: -46.4385,
      longitude: -67.5278,
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
      location: 'Barrio Miramar, Caleta Olivia',
      timeAgo: 'Hace 1 hora',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Encontrado en un balcón.',
      imageUrl: 'assets/images/IMG_2935.JPG',
      tags: const ['Ojos azules'],
      contactName: 'Lucas Paz',
      contactPhone: '+54 9 297 9876-5432',
      latitude: -46.4478,
      longitude: -67.5150,
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
      location: 'Barrio Parque, Caleta Olivia',
      timeAgo: 'Hace 30 min',
      date: DateTime.now().subtract(const Duration(minutes: 30)),
      description: 'Visto cerca de Barrio Parque.',
      imageUrl: 'assets/images/IMG_4178.JPG',
      tags: const ['Collar azul'],
      contactName: 'Martina Gomez',
      contactPhone: '+54 9 297 5555-4444',
      latitude: -46.4425,
      longitude: -67.5245,
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
      location: 'Barrio Gregores, Caleta Olivia',
      timeAgo: 'Hace 4 horas',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      description: 'Extraviado en Barrio Gregores.',
      imageUrl: 'assets/images/IMG_5370.JPG',
      tags: const ['Orejas largas'],
      contactName: 'Usuario Yago',
      contactPhone: '+54 9 297 2222-3333',
      latitude: -46.4452,
      longitude: -67.5348,
      isUserOwner: true,
    );

    // Agregar a MockDataService para verificar resolución
    await MockDataService().addPet(pet);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
                ),
                child: const Text('Abrir ficha'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Abrir ficha'));
    await tester.pumpAndSettle();

    // Desplazar hasta el botón de marcar como recuperada
    await tester.scrollUntilVisible(find.text('Marcar como recuperada'), 100);
    await tester.pump(const Duration(milliseconds: 200));

    // Debe mostrar el botón de marcar como recuperada y NO mostrar el botón Contactar (es su propio reporte)
    expect(find.text('Marcar como recuperada'), findsOneWidget);
    expect(find.text('Contactar'), findsNothing);

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
    await tester.pumpAndSettle();

    // Debe cerrar la ficha y devolver a la pantalla anterior
    expect(find.byType(PetDetailScreen), findsNothing);
    expect(find.text('Abrir ficha'), findsOneWidget);

    // Caso resuelto: feedback mostrado
    expect(find.textContaining('¡Caso resuelto!'), findsOneWidget);

    // Verificar que el estado en MockDataService ahora es reunited
    final updated = MockDataService().getAllPets().firstWhere((p) => p.id == 'test-pet-owner-recovered');
    expect(updated.status, equals(YagoPetStatus.reunited));
  });

  testWidgets('AiCameraScreen extracts physical traits, compares against active DB, and shows similarity percentage & comparative photos (HU-S3-01 to HU-S3-04)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AiCameraScreen(),
      ),
    );
    await tester.pump();

    // 1. Verificar controles de captura a pantalla completa y ausencia de sugerencias/encuadre (HU-S3-01 / HU-S3-02)
    expect(find.text('Cámara con IA'), findsOneWidget);
    expect(find.text('Tomar foto'), findsOneWidget);
    expect(find.text('Cargar de galería'), findsOneWidget);
    expect(find.text('Caniche blanco'), findsNothing);
    expect(find.text('Gato bicolor'), findsNothing);

    // 2. Pulsar el obturador "Tomar foto" para disparar el análisis con IA
    await tester.tap(find.text('Tomar foto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Verificar rasgos físicos extraídos por el modelo de IA (HU-S3-02)
    expect(find.text('RASGOS FÍSICOS EXTRAÍDOS POR IA'), findsOneWidget);
    expect(find.text('Perro'), findsWidgets);
    expect(find.text('Caniche'), findsWidgets);
    expect(find.text('Blanco'), findsWidgets);
    expect(find.text('Moño rosa'), findsWidgets);

    // 4. Verificar comparación automática y visualización de porcentaje de similitud y fotos comparativas (HU-S3-03 / HU-S3-04)
    expect(find.text('COINCIDENCIAS EN BASE DE DATOS'), findsOneWidget);
    expect(find.textContaining('% de similitud'), findsWidgets);
    expect(find.text('Foto analizada'), findsWidgets);
    expect(find.text('Reporte: Luna'), findsOneWidget);
    expect(find.text('PERDIDA'), findsWidgets);
    expect(find.text('Abrir chat directo'), findsWidgets);
  });

  testWidgets('AiCameraScreen opens DirectChatScreen with report owner and sends instant sighting alert (HU-S3-05)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AiCameraScreen(
          initialPreset: AiVisionService.samplePresets[1],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Reporte: Milo (Nombre asignado)'), findsOneWidget);
    expect(find.text('ENCONTRADA'), findsWidgets);

    // Desplazar hasta el botón "Abrir chat directo" y pulsarlo
    final chatBtn = find.text('Abrir chat directo').first;
    await tester.ensureVisible(chatBtn);
    await tester.pumpAndSettle();
    await tester.tap(chatBtn);
    await tester.pumpAndSettle();

    // Debe abrir DirectChatScreen con Lucía Fernández y contexto de Milo
    expect(find.byType(DirectChatScreen), findsOneWidget);
    expect(find.text('Lucía Fernández'), findsOneWidget);
    expect(find.text('Reportante de mascota encontrada'), findsOneWidget);
    expect(find.textContaining('% IA'), findsOneWidget);

    // Enviar un mensaje directo en el chat
    final inputFinder = find.byType(TextField);
    expect(inputFinder, findsOneWidget);
    await tester.enterText(inputFinder, '¡Hola Lucía! Creo que Milo es mi gato.');
    await tester.tap(find.byTooltip('Enviar mensaje'));
    await tester.pumpAndSettle();

    // El mensaje enviado debe mostrarse en la conversación
    expect(find.text('¡Hola Lucía! Creo que Milo es mi gato.'), findsOneWidget);
  });

  testWidgets('AiCameraScreen allows generating a new found pet report reusing photo and traits when no matches are found (HU-S3-06)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AiCameraScreen(
          initialPreset: AiVisionService.samplePresets.last,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar extracción de especie Otro y estado sin coincidencias
    expect(find.text('Otro'), findsWidgets);
    expect(find.text('Conejo doméstico'), findsWidgets);
    expect(find.text('0 coincidencias'), findsOneWidget);
    expect(find.text('No se detectaron coincidencias'), findsOneWidget);

    // Tocar botón "Generar reporte de mascota encontrada"
    final generateBtn = find.text('Generar reporte de mascota encontrada');
    await tester.ensureVisible(generateBtn);
    await tester.pumpAndSettle();
    await tester.tap(generateBtn);
    await tester.pumpAndSettle();

    // Debe abrir CreateReportScreen con la foto y los rasgos precargados desde IA
    expect(find.byType(CreateReportScreen), findsOneWidget);
    expect(
      find.text('Foto y rasgos físicos reutilizados desde Cámara con IA para ahorrar tiempo.'),
      findsOneWidget,
    );
    expect(find.text('Conejo doméstico'), findsOneWidget);
    expect(find.text('Gris ceniza'), findsOneWidget);
  });

  testWidgets('AiCameraScreen shows error screen when analyzed image is not an animal without mentioning detected object', (WidgetTester tester) async {
    const nonAnimalPreset = AiSamplePreset(
      id: 'preset-not-animal',
      label: 'Objeto',
      subtitle: 'No es un animal',
      imageUrl: '',
      isAnimal: false,
      nonAnimalReason:
          'No logramos identificar un animal en esta imagen. Por favor, toma una foto clara donde se vea bien a la mascota.',
      species: 'Otro',
      apparentBreed: 'No detectado',
      colors: [],
      distinctiveTraits: [],
      summary: 'La imagen no muestra un animal.',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AiCameraScreen(
          initialPreset: nonAnimalPreset,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Debe mostrar la pantalla de error limpia sin mencionar qué objeto se detectó
    expect(find.text('No detectamos un animal en la imagen'), findsOneWidget);
    expect(
      find.textContaining('No logramos identificar un animal en esta imagen'),
      findsOneWidget,
    );
    expect(find.textContaining('se detectó:'), findsNothing);
    expect(find.text('Tomar otra foto'), findsOneWidget);
    expect(find.text('Elegir otra de la galería'), findsOneWidget);
    expect(find.text('COINCIDENCIAS EN BASE DE DATOS'), findsNothing);
    expect(find.text('RASGOS FÍSICOS EXTRAÍDOS POR IA'), findsNothing);
  });

  test('Pet.detailsSummary hides unknown/empty optional fields in feed while keeping completed ones', () {
    // Caso 1: Perro Bull Terrier sin nombre, sin sexo y sin edad conocida
    final bullTerrier = Pet(
      id: 'test-bull-terrier',
      name: 'Sin nombre',
      species: 'Perro',
      breed: 'Bull Terrier',
      gender: 'Desconocido',
      age: 'Desconocida',
      status: YagoPetStatus.found,
      location: 'Centro, Caleta Olivia',
      timeAgo: 'Hace 5 min',
      date: DateTime.now(),
      description: 'Perro encontrado en buen estado.',
      imageUrl: '',
      contactName: 'Vecino',
      contactPhone: 'Contacto por chat interno',
      latitude: -46.4393,
      longitude: -67.5284,
    );
    expect(bullTerrier.name, 'Sin nombre');
    expect(bullTerrier.detailsSummary, 'Bull Terrier');
    expect(bullTerrier.detailsSummary.contains('Desconocido'), isFalse);
    expect(bullTerrier.detailsSummary.contains('Desconocida'), isFalse);

    // Caso 2: Mascota sin nombre, sin raza, sin sexo y sin edad conocida
    final allUnknown = Pet(
      id: 'test-all-unknown',
      name: 'Sin nombre',
      species: 'Perro',
      breed: '',
      gender: 'Desconocido',
      age: 'Desconocida',
      status: YagoPetStatus.found,
      location: 'Centro, Caleta Olivia',
      timeAgo: 'Hace 5 min',
      date: DateTime.now(),
      description: 'Perro encontrado sin datos adicionales.',
      imageUrl: '',
      contactName: 'Vecino',
      contactPhone: 'Contacto por chat interno',
      latitude: -46.4393,
      longitude: -67.5284,
    );
    expect(allUnknown.name, 'Sin nombre');
    expect(allUnknown.detailsSummary, isEmpty);
  });

  testWidgets('AiCameraScreen resets scanner when tab becomes inactive/active', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AiCameraScreen(
          isActive: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Inicialmente está en el visor en vivo
    expect(find.text('Tomar foto'), findsOneWidget);

    // Simular captura en el visor
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pumpAndSettle();

    // Debe mostrar resultados del análisis
    expect(find.text('COINCIDENCIAS EN BASE DE DATOS'), findsOneWidget);

    // Simular cambio de pestaña (isActive: false) y regreso (isActive: true)
    await tester.pumpWidget(
      const MaterialApp(
        home: AiCameraScreen(
          isActive: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      const MaterialApp(
        home: AiCameraScreen(
          isActive: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Debe haberse reseteado al visor de cámara sin mostrar el análisis anterior
    expect(find.text('COINCIDENCIAS EN BASE DE DATOS'), findsNothing);
    expect(find.text('Tomar foto'), findsOneWidget);
  });

  testWidgets('CreateReportScreen validates required fields, rejects invalid phone, and allows manual accessible submission', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateReportScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Intentar publicar vacío debe bloquearse y mostrar mensajes de validación
    final publishBtn = find.widgetWithText(YagoButton, 'Publicar reporte');
    await tester.ensureVisible(publishBtn);
    await tester.pumpAndSettle();
    await tester.tap(publishBtn);
    await tester.pumpAndSettle();

    expect(find.text('Indica el nombre o apodo al que responde tu mascota.'), findsOneWidget);
    expect(find.textContaining('Indica el barrio, calle o zona aproximada'), findsOneWidget);
    expect(find.textContaining('Agrega una breve descripción'), findsOneWidget);

    // 2. Completar nombre, ubicación escrita manualmente (sin GPS) y descripción válida
    ScaffoldMessenger.of(tester.element(publishBtn)).clearSnackBars();
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Copito'); // Nombre
    await tester.enterText(textFields.at(3), 'Barrio Miramar, Caleta Olivia'); // Ubicación manual
    await tester.enterText(textFields.at(4), 'telefono-invalido'); // Teléfono inválido
    await tester.enterText(
      textFields.at(6),
      'Se escapó por el portón, tiene collar azul y es muy manso.',
    ); // Descripción

    await tester.ensureVisible(publishBtn);
    await tester.pumpAndSettle();
    await tester.tap(publishBtn);
    await tester.pumpAndSettle();

    // Debe rechazar el teléfono inválido pero limpiar los errores ya corregidos
    expect(find.text('Indica el nombre o apodo al que responde tu mascota.'), findsNothing);
    expect(find.textContaining('El teléfono solo puede contener números'), findsOneWidget);

    // 3. Dejar teléfono vacío (accesibilidad por Chat Directo) y publicar con éxito
    ScaffoldMessenger.of(tester.element(publishBtn)).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.enterText(textFields.at(4), '');
    await tester.ensureVisible(publishBtn);
    await tester.pumpAndSettle();
    await tester.tap(publishBtn);
    await tester.pumpAndSettle();

    expect(find.text('Reporte de búsqueda publicado con éxito'), findsOneWidget);
    final createdPet = MockDataService().getAllPets().firstWhere((p) => p.name == 'Copito');
    expect(createdPet.contactPhone, 'Contacto por chat interno');
  });

  testWidgets('YagoExpandableText truncates long posts to 4 lines and toggles Ver más / Ver menos', (WidgetTester tester) async {
    const longPost = 'Cada mascota merece volver a casa.\n\n'
        'En Yago trabajamos para conectar a personas que perdieron o encontraron animales, '
        'facilitando la difusión de reportes y ayudando a reunir mascotas con sus familias.\n\n'
        'Compartí, ayudá y difundí. ¡Entre todos podemos hacer la diferencia!';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: YagoExpandableText(
              text: longPost,
              maxLines: 4,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Debe mostrar "Ver más" inicialmente y limitar el Text a 4 líneas
    expect(find.text('Ver más'), findsOneWidget);
    expect(find.text('Ver menos'), findsNothing);
    final collapsedText = tester.widget<Text>(find.text(longPost));
    expect(collapsedText.maxLines, equals(4));
    expect(collapsedText.overflow, equals(TextOverflow.ellipsis));

    // Al tocar "Ver más", se expande mostrando el texto completo y "Ver menos"
    await tester.tap(find.text('Ver más'));
    await tester.pump();

    expect(find.text('Ver menos'), findsOneWidget);
    expect(find.text('Ver más'), findsNothing);
    final expandedText = tester.widget<Text>(find.text(longPost));
    expect(expandedText.maxLines, isNull);
  });

  group('Sprint 4: Direct Chat Module UI & End-to-End Flows (HU-S4-01 to HU-S4-05)', () {
    testWidgets('DirectChatsTab displays active conversations chronologically, shows unread indicators, and clears them when opened (HU-S4-01 & HU-S4-05)', (WidgetTester tester) async {
      final mock = MockDataService();
      mock.clearUserProfileCache();

      final luna = mock.getPetById('pet-1')!;
      final milo = mock.getPetById('pet-3')!;

      final chatLuna = mock.getOrCreateChatForPet(luna, aiSimilarityPercentage: 95);
      mock.sendDirectMessage(chatLuna.id, 'Hola Camila, vi una caniche parecida.');

      final chatMilo = mock.getOrCreateChatForPet(milo);
      mock.receiveDirectMessage(
        chatMilo.id,
        '¡Hola! Tengo a Milo resguardado en Barrio Miramar.',
        sentAt: DateTime.now().add(const Duration(minutes: 2)),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // 1. Verificar indicador visual de mensaje no leído en la barra de navegación inferior (HU-S4-05)
      expect(find.byKey(const Key('nav_bar_chat_unread_badge')), findsOneWidget);
      expect(find.text('1'), findsWidgets);

      // 2. Navegar a la bandeja de Chat Directo (HU-S4-01)
      await tester.tap(find.byTooltip('Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(DirectChatsTab), findsOneWidget);
      expect(find.text('Chat Directo'), findsOneWidget);
      expect(find.byKey(const Key('inbox_header_unread_badge')), findsOneWidget);
      expect(find.byKey(Key('unread_badge_${chatMilo.id}')), findsOneWidget);

      // 3. Verificar orden cronológico (Lucía Fernández de Milo arriba de Camila Rodriguez de Luna)
      final luciaPos = tester.getTopLeft(find.text('Lucía Fernández'));
      final camilaPos = tester.getTopLeft(find.text('Camila Rodriguez'));
      expect(luciaPos.dy, lessThan(camilaPos.dy));

      // 4. Filtrar por "No leídos"
      await tester.tap(find.text('No leídos'));
      await tester.pumpAndSettle();
      expect(find.text('Lucía Fernández'), findsOneWidget);
      expect(find.text('Camila Rodriguez'), findsNothing);

      // 5. Abrir la conversación no leída -> debe mostrar la tarjeta resumida en el encabezado (HU-S4-04) y limpiar el indicador de no leído (HU-S4-05)
      await tester.tap(find.text('Lucía Fernández'));
      await tester.pumpAndSettle();

      expect(find.byType(DirectChatScreen), findsOneWidget);
      expect(find.byKey(const Key('chat_context_summary_card')), findsOneWidget);
      expect(find.text('¡Hola! Tengo a Milo resguardado en Barrio Miramar.'), findsOneWidget);

      // Volver a la bandeja y comprobar que ya no hay mensajes sin leer
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('inbox_header_unread_badge')), findsNothing);
      expect(find.byKey(const Key('nav_bar_chat_unread_badge')), findsNothing);
    });

    testWidgets('User can start a private direct chat from a community post in FeedTab and see post context header (HU-S4-02 & HU-S4-04)', (WidgetTester tester) async {
      final mock = MockDataService();
      mock.clearUserProfileCache();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedTab(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Desplazar hasta la publicación comunitaria de Veterinaria San Roque
      await tester.scrollUntilVisible(
        find.text('Veterinaria San Roque'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tocar el botón de mensaje directo al autor de la publicación comunitaria
      final dmPostBtn = find.byTooltip('Enviar mensaje directo al autor').first;
      await tester.ensureVisible(dmPostBtn);
      await tester.pumpAndSettle();
      await tester.tap(dmPostBtn);
      await tester.pumpAndSettle();

      // Debe abrir DirectChatScreen con el contexto resumido de la publicación comunitaria (HU-S4-04)
      expect(find.byType(DirectChatScreen), findsOneWidget);
      expect(find.text('Veterinaria San Roque'), findsOneWidget);
      expect(find.text('Autor/a de publicación en el feed comunitario'), findsOneWidget);
      expect(find.byKey(const Key('chat_context_summary_card')), findsOneWidget);
      expect(find.text('Publicación de Veterinaria San Roque'), findsOneWidget);
      expect(find.text('CONSEJO'), findsOneWidget);
    });

    testWidgets('DirectChatScreen shows only camera/gallery on attach, has no meeting point button, shows 3-dots menu (archive/clear/delete), and opens PetDetailScreen from header (HU-S4-03 & HU-S4-04)', (WidgetTester tester) async {
      final mock = MockDataService();
      mock.clearUserProfileCache();
      final luna = mock.getPetById('pet-1')!;

      await tester.pumpWidget(
        MaterialApp(
          home: DirectChatScreen(
            pet: luna,
            analyzedImageSource: 'assets/images/IMG_3508.JPG',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verificar tarjeta resumida en el encabezado del chat y ausencia de botón de punto de encuentro (HU-S4-04)
      expect(find.byKey(const Key('chat_context_summary_card')), findsOneWidget);
      expect(find.text('Luna'), findsOneWidget);
      expect(find.text('Caniche · Centro, El Gorosito, Caleta Olivia'), findsOneWidget);
      expect(find.byTooltip('Coordinar punto de encuentro'), findsNothing);

      // 2. Al pulsar 'Adjuntar foto' solo deben aparecer 'Tomar foto con la cámara' y 'Seleccionar de la galería'
      await tester.tap(find.byTooltip('Adjuntar foto'));
      await tester.pumpAndSettle();
      expect(find.text('Tomar foto con la cámara'), findsOneWidget);
      expect(find.text('Seleccionar de la galería'), findsOneWidget);
      expect(find.text('Adjuntar foto analizada con IA'), findsNothing);
      expect(find.text('Adjuntar foto de avistamiento reciente'), findsNothing);

      // Cerrar hoja modal de adjuntos
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // 3. Enviar un mensaje y probar menú de 3 puntitos (Archivar chat, Vaciar chat, Eliminar chat)
      await tester.enterText(
        find.byType(TextField),
        'Hola, tengo información sobre Luna.',
      );
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();
      expect(find.text('Hola, tengo información sobre Luna.'), findsOneWidget);

      await tester.tap(find.byTooltip('Opciones de conversación'));
      await tester.pumpAndSettle();
      expect(find.text('Archivar chat'), findsOneWidget);
      expect(find.text('Vaciar chat'), findsOneWidget);
      expect(find.text('Eliminar chat'), findsOneWidget);

      // Vaciar chat vacía los mensajes para el usuario actual
      await tester.tap(find.text('Vaciar chat'));
      await tester.pumpAndSettle();
      expect(find.text('Hola, tengo información sobre Luna.'), findsNothing);

      // 4. Tocar la tarjeta resumida del encabezado para abrir la ficha completa del reporte (HU-S4-04)
      await tester.tap(find.byKey(const Key('chat_context_summary_card')));
      await tester.pumpAndSettle();
      expect(find.byType(PetDetailScreen), findsOneWidget);
    });

    testWidgets('PetCard hides contact button when showContactButton is false (own post/report) and MockDataService propagates updated profile photo to user posts and reports', (WidgetTester tester) async {
      // 1. Verificar que PetCard oculta el botón de contacto en publicaciones/reportes propios
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PetCard(
                name: 'Mi Mascota',
                details: 'Caniche · Macho · 2 años',
                locationAndTime: 'Costanera, Caleta Olivia · Recién publicado',
                imageUrl: 'assets/images/IMG_3508.JPG',
                status: YagoPetStatus.lost,
                showContactButton: false,
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.mail_outline_rounded), findsNothing);

      // 2. Verificar que actualizar la foto de perfil propaga el avatar a los posts y reportes del usuario
      final mock = MockDataService();
      mock.clearUserProfileCache();

      final ownPost = FeedPost(
        id: 'post-own-avatar-test',
        authorName: 'Usuario Prueba',
        authorAvatar: null,
        timeAgo: 'Recién publicado',
        content: 'Publicación de prueba para avatar actualizado.',
        createdAt: DateTime.now(),
      );
      await mock.addCommunityPost(ownPost);

      final ownPet = Pet(
        id: 'pet-own-avatar-test',
        name: 'Toby',
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Macho',
        age: '2 años',
        status: YagoPetStatus.lost,
        location: 'Centro, Caleta Olivia',
        timeAgo: 'Recién publicado',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        description: 'Reporte de prueba para avatar actualizado.',
        imageUrl: 'assets/images/IMG_3508.JPG',
        contactName: 'Usuario Prueba',
        contactPhone: '+54 9 297 111-2222',
        latitude: -46.4385,
        longitude: -67.5278,
        isUserOwner: true,
      );
      await mock.addPet(ownPet);

      mock.updateUserProfile(
        displayName: 'Usuario Prueba',
        photoUrl: 'assets/images/IMG_4178.JPG',
      );

      final updatedPost = mock.getFeedPostById('post-own-avatar-test')!;
      final updatedPet = mock.getPetById('pet-own-avatar-test')!;
      expect(mock.resolvePostAuthorAvatar(updatedPost), 'assets/images/IMG_4178.JPG');
      expect(mock.resolvePetAuthorAvatar(updatedPet), 'assets/images/IMG_4178.JPG');

      await mock.deleteCommunityPost('post-own-avatar-test');
      await mock.deletePet('pet-own-avatar-test');
    });

    testWidgets('PetDetailScreen hides phone call option when reporter did not add a phone number and shows it when phone is provided', (WidgetTester tester) async {
      final petWithoutPhone = Pet(
        id: 'pet-no-phone',
        name: 'Rocco',
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Macho',
        age: '3 años',
        status: YagoPetStatus.lost,
        location: 'Centro, Caleta Olivia',
        timeAgo: 'Hace 1 hora',
        date: DateTime.now(),
        description: 'Perro mediano sin teléfono de contacto cargado.',
        imageUrl: 'assets/images/IMG_3508.JPG',
        contactName: 'Martín Gómez',
        contactPhone: 'Contacto por chat interno',
        latitude: -46.4385,
        longitude: -67.5278,
      );
      expect(petWithoutPhone.hasContactPhone, isFalse);
      expect(petWithoutPhone.callablePhones, isEmpty);

      await tester.pumpWidget(
        MaterialApp(
          home: PetDetailScreen(pet: petWithoutPhone),
        ),
      );
      await tester.pumpAndSettle();

      final contactBtn = find.widgetWithText(YagoButton, 'Contactar');
      await tester.ensureVisible(contactBtn);
      await tester.pumpAndSettle();
      await tester.tap(contactBtn);
      await tester.pumpAndSettle();

      // Sin teléfono: solo debe mostrar 'Enviar mensaje directo' y NO 'Llamar por teléfono'
      expect(find.text('Enviar mensaje directo'), findsOneWidget);
      expect(find.text('Llamar por teléfono'), findsNothing);

      // Cerrar modal
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // Con teléfono: debe mostrar tanto 'Llamar por teléfono' como 'Enviar mensaje directo'
      final petWithPhone = petWithoutPhone.copyWith(
        id: 'pet-with-phone',
        contactPhone: '+54 9 297 456-7890',
      );
      expect(petWithPhone.hasContactPhone, isTrue);
      expect(petWithPhone.callablePhones, ['+54 9 297 456-7890']);

      await tester.pumpWidget(
        MaterialApp(
          home: PetDetailScreen(pet: petWithPhone),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(contactBtn);
      await tester.pumpAndSettle();
      await tester.tap(contactBtn);
      await tester.pumpAndSettle();

      expect(find.text('Llamar por teléfono'), findsOneWidget);
      expect(find.text('+54 9 297 456-7890'), findsOneWidget);
      expect(find.text('Enviar mensaje directo'), findsOneWidget);
    });
  });

  group('Sprint 5: Community Moderation Flow (HU-S5-01)', () {
    testWidgets('ReportContentModal renders pet preview, allows reason selection, and submits report', (WidgetTester tester) async {
      final pet = MockDataService().getAllPets().first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ReportContentModal.show(
                        context,
                        targetType: 'pet',
                        targetId: pet.id,
                        pet: pet,
                      );
                    },
                    child: const Text('Abrir denuncia'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Abrir modal
      await tester.tap(find.text('Abrir denuncia'));
      await tester.pumpAndSettle();

      // Verificar cabecera y previsualización de la mascota
      expect(find.text('Denunciar a moderación'), findsOneWidget);
      expect(find.text('Motivo de la denuncia'), findsOneWidget);
      expect(find.text('Información falsa o broma'), findsOneWidget);
      expect(find.text('Estafa o extorsión con recompensa'), findsOneWidget);
      expect(find.text('Venta de animales o publicidad (Spam)'), findsOneWidget);
      expect(find.text('Maltrato animal o contenido violento'), findsOneWidget);
      expect(find.text('Caso ya resuelto o reporte repetido'), findsOneWidget);
      expect(find.text('Otro motivo'), findsOneWidget);

      // Verificar texto de privacidad
      expect(find.text('Tu denuncia es 100% anónima. La otra persona no sabrá quién reportó su contenido.'), findsOneWidget);

      // Seleccionar motivo: Estafa o extorsión
      await tester.tap(find.text('Estafa o extorsión con recompensa'));
      await tester.pumpAndSettle();

      // Ingresar descripción opcional
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Exigen 50.000 pesos de rescate por transferencia.');
      await tester.pumpAndSettle();

      // Enviar denuncia
      final submitBtn = find.text('Enviar denuncia');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // El modal debe cerrarse y mostrar el snackbar de agradecimiento
      expect(find.text('Denunciar a moderación'), findsNothing);
      expect(find.text('Denuncia recibida'), findsOneWidget);
    });

    testWidgets('PetDetailScreen displays report button in AppBar for reports not owned by current user', (WidgetTester tester) async {
      final pet = MockDataService().getAllPets().firstWhere((p) => !p.isUserOwner);

      await tester.pumpWidget(
        MaterialApp(
          home: PetDetailScreen(pet: pet),
        ),
      );
      await tester.pumpAndSettle();

      final reportButton = find.byTooltip('Denunciar publicación');
      expect(reportButton, findsOneWidget);

      await tester.tap(reportButton);
      await tester.pumpAndSettle();

      expect(find.text('Denunciar a moderación'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // Cancelar cierra el modal sin enviar
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Denunciar a moderación'), findsNothing);
    });

    testWidgets('DirectChatScreen unifies multiple animals for the same person with context selector and blocks user upon report', (WidgetTester tester) async {
      final mock = MockDataService();
      final pet1 = Pet(
        id: 'pet-ui-ctx-1',
        name: 'Bruno',
        breed: 'Golden',
        species: 'Perro',
        gender: 'Macho',
        age: '4 años',
        status: YagoPetStatus.lost,
        location: 'Caleta Olivia',
        timeAgo: 'Hace 2h',
        date: DateTime.now(),
        description: 'Perdido en el centro',
        imageUrl: '',
        contactName: 'Sofía Castro',
        contactPhone: '2974556677',
        latitude: -46.43,
        longitude: -67.52,
        ownerId: 'uid_sofia_castro_ui',
      );
      final pet2 = Pet(
        id: 'pet-ui-ctx-2',
        name: 'Nina',
        breed: 'Calicó',
        species: 'Gato',
        gender: 'Hembra',
        age: '2 años',
        status: YagoPetStatus.found,
        location: 'Caleta Olivia',
        timeAgo: 'Hace 30m',
        date: DateTime.now(),
        description: 'Encontrada en plaza',
        imageUrl: '',
        contactName: 'Sofía Castro',
        contactPhone: '2974556677',
        latitude: -46.44,
        longitude: -67.53,
        ownerId: 'uid_sofia_castro_ui',
      );

      final chatA = mock.getOrCreateChatForPet(pet1);
      mock.sendDirectMessage(chatA.id, 'Hola Sofía, te escribo por Bruno');
      final chatB = mock.getOrCreateChatForPet(pet2);
      mock.sendDirectMessage(chatB.id, 'Y también vi tu reporte de Nina');

      expect(chatB.id, equals(chatA.id));

      await tester.pumpWidget(
        MaterialApp(
          home: DirectChatScreen(conversation: chatB),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica barra selectora de contextos y divisores de tema en el historial
      expect(find.byKey(const Key('chat_context_selector_bar')), findsOneWidget);
      expect(find.text('Conversación sobre Bruno'), findsOneWidget);
      expect(find.text('Conversación sobre Nina'), findsOneWidget);

      // Cambiar contexto activo tocando el chip de Bruno
      await tester.tap(find.byKey(const Key('chat_context_chip_pet-ui-ctx-1')));
      await tester.pumpAndSettle();
      expect(mock.getChatById(chatA.id)!.relatedPetName, equals('Bruno'));

      // Ahora denunciamos el chat desde el menú de 3 puntitos y verificamos que bloquea y quita de la bandeja
      await tester.tap(find.byTooltip('Opciones de conversación'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Denunciar chat'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Información falsa o broma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar denuncia'));
      await tester.pumpAndSettle();

      expect(mock.getChatConversations().any((c) => c.id == chatA.id), isFalse);
      expect(
        mock.isPersonBlocked(
          userId: 'uid_sofia_castro_ui',
          userName: 'Sofía Castro',
        ),
        isTrue,
      );
    });
  });
}





