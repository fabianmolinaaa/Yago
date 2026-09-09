import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Modelo de datos para cada tip del onboarding
class _OnboardingTip {
  final String titleLine1;
  final String titleLine2;
  final String titleLine3;
  final String description;

  const _OnboardingTip({
    required this.titleLine1,
    required this.titleLine2,
    required this.titleLine3,
    required this.description,
  });
}

/// Pantalla de bienvenida y onboarding de Yago.
/// Diseño editorial minimalista en fondo blanco/porcelana, logo de gran peso visual,
/// texto editorial centrado, carrusel de tips interactivo con mapa y pin personalizado.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // Controlador de micro-animación flotante para el pin del mapa
  late final AnimationController _pinFloatController;
  late final Animation<double> _pinFloatAnimation;

  static const List<_OnboardingTip> _tips = [
    _OnboardingTip(
      titleLine1: 'Reportá en segundos',
      titleLine2: 'para salvar vidas.',
      titleLine3: 'En comunidad.',
      description:
          'Publicá una alerta con foto, detalles y ubicación para iniciar la búsqueda comunitaria de inmediato.',
    ),
    _OnboardingTip(
      titleLine1: 'Tu mapa',
      titleLine2: 'en tiempo real',
      titleLine3: 'para estar cerca.',
      description:
          'Consulta la ubicación de tu mascota y filtra por mascotas perdidas o encontradas.',
    ),
    _OnboardingTip(
      titleLine1: 'Avisos directos',
      titleLine2: 'en tiempo real',
      titleLine3: 'cerca de tu radio.',
      description:
          'Recibí notificaciones instantáneas si una mascota se reporta perdida cerca de tu zona habitual.',
    ),
    _OnboardingTip(
      titleLine1: 'Reconectá familias',
      titleLine2: 'y sus mascotas',
      titleLine3: 'en comunidad.',
      description:
          'Comunicate de forma segura con vecinos y dueños para concretar cada reencuentro feliz.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pinFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pinFloatAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _pinFloatController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Evitar animaciones infinitas durante tests automáticos para permitir pumpAndSettle
    final isTestEnvironment = Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnvironment) {
      _pinFloatController.repeat(reverse: true);
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _tips.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _pauseAutoScrollTemporarily() {
    _autoScrollTimer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pinFloatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 700;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 20.0 : 28.0,
                ),
                child: Column(
                  children: [
                    SizedBox(height: isCompact ? 10 : 20),

                    // 1. Cabecera editorial: Logo amplio (2.5x) y texto editorial centrado
                    _buildHeader(isCompact: isCompact),

                    SizedBox(height: isCompact ? 10 : 18),

                    // 2. Carrusel de Tips con tipografía editorial y visuales
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                            _pauseAutoScrollTemporarily();
                          }
                          return false;
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _tips.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return _buildSlide(
                              index: index,
                              tip: _tips[index],
                              isCompact: isCompact,
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 8 : 14),

                    // 3. Indicador de páginas minimalista tipo cápsula
                    _buildPageIndicator(),

                    SizedBox(height: isCompact ? 14 : 22),

                    // 4. Botones de acción inferiores
                    _buildActionButtons(isCompact: isCompact),

                    SizedBox(height: isCompact ? 10 : 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Cabecera con el logo ampliado (2.5x) y el texto editorial debajo centrado
  Widget _buildHeader({required bool isCompact}) {
    // Aumento visual del logo a 2–2.5x respecto al diseño previo (~36px -> ~88px)
    final logoHeight = isCompact ? 72.0 : 88.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo de Yago oficial centrado horizontalmente
        YagoLogo(
          height: logoHeight,
        ),

        SizedBox(height: isCompact ? 8 : 12),

        // Texto editorial de los pilares de la marca centrado
        const Text(
          'Explora · Conecta · Reencuentra',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.4,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  /// Construye cada diapositiva del carrusel de tips
  Widget _buildSlide({
    required int index,
    required _OnboardingTip tip,
    required bool isCompact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título editorial con tercera línea en color atenuado
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: isCompact ? 24 : 29,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.6,
              height: 1.18,
              color: const Color(0xFF1D232C),
            ),
            children: [
              TextSpan(text: '${tip.titleLine1}\n'),
              TextSpan(text: '${tip.titleLine2}\n'),
              TextSpan(
                text: tip.titleLine3,
                style: const TextStyle(
                  color: Color(0xFF737C8A),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isCompact ? 8 : 12),

        // Subtítulo / Descripción explicativa
        Text(
          tip.description,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: isCompact ? 13.5 : 14.5,
            fontWeight: FontWeight.w400,
            height: 1.42,
            letterSpacing: -0.1,
            color: const Color(0xFF737C8A),
          ),
        ),

        SizedBox(height: isCompact ? 8 : 14),

        // Área visual ilustrada para cada tip
        Expanded(
          child: Center(
            child: _buildSlideVisual(index, isCompact: isCompact),
          ),
        ),
      ],
    );
  }

  /// Visual para cada tip (el tip 1 corresponde al mapa con el pin y el logo)
  Widget _buildSlideVisual(int index, {required bool isCompact}) {
    switch (index) {
      case 1:
        // Segundo tip: Mapa de la app con el pin personalizado y el logo en su interior
        return _buildMapSlideVisual(isCompact: isCompact);
      case 0:
        return _buildReportAlertVisual(isCompact: isCompact);
      case 2:
        return _buildNotificationVisual(isCompact: isCompact);
      case 3:
      default:
        return _buildReunionVisual(isCompact: isCompact);
    }
  }

  /// Visual del Mapa (Tip 2) usando map_without_pin.png con el Pin superpuesto en el radar
  Widget _buildMapSlideVisual({required bool isCompact}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // map_without_pin.png tiene aspecto 1598 x 984 (1.624)
        // El centro exacto de los anillos concéntricos está en (50% w, 50% h)
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        double mapWidth = maxW;
        double mapHeight = mapWidth / 1.624;

        if (mapHeight > maxH) {
          mapHeight = maxH;
          mapWidth = mapHeight * 1.624;
        }

        const pinWidth = 44.0;
        const pinHeight = 54.0;

        return AnimatedBuilder(
          animation: _pinFloatAnimation,
          builder: (context, child) {
            final floatOffset = _pinFloatAnimation.value;

            return SizedBox(
              width: mapWidth,
              height: mapHeight,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 1. Imagen del mapa con difuminado perimetral para fundirse con el fondo blanco
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.16, 0.82, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.12, 0.88, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/images/map_without_pin.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),

                  // Gradiente radial blanco perimetral para un difuminado orgánico perfecto
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.92,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.50),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.50, 0.84, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Sombra de contacto en el centro del radar (x=50%, y=50%)
                  Positioned(
                    top: (mapHeight * 0.50) - 2,
                    left: (mapWidth * 0.50) - 10,
                    child: Container(
                      width: 20,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B)
                            .withValues(alpha: 0.22 - (floatOffset * 0.015)),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. El Pin personalizado posicionado con su punta tocando el centro
                  Positioned(
                    top: (mapHeight * 0.50) - pinHeight - floatOffset,
                    left: (mapWidth * 0.50) - (pinWidth / 2),
                    child: const _YagoMapPin(
                      width: pinWidth,
                      height: pinHeight,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Visual estilizado para el Tip 1: Reporte de alerta en segundos
  Widget _buildReportAlertVisual({required bool isCompact}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Milo',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1D232C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCECEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PERDIDO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD46761),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Beagle · Collar azul · Hace 10 min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF737C8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF737C8A)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'A 250 m de tu radio habitual',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF737C8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visual estilizado para el Tip 3: Avisos en tiempo real
  Widget _buildNotificationVisual({required bool isCompact}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: EdgeInsets.all(isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF232E3A),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¡Alerta en tu vecindario!',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D232C),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Mascota avistada a 300 m. Tocá para ver la foto y cooperar.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF737C8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visual estilizado para el Tip 4: Reconexión de familias
  Widget _buildReunionVisual({required bool isCompact}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: EdgeInsets.all(isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFF428C63),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¡Reencuentro confirmado!',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D232C),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Gracias a la red comunitaria, Milo ya se encuentra seguro con su familia.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF737C8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de páginas minimalista estilo cápsula iOS
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_tips.length, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () {
            _pauseAutoScrollTemporarily();
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3.5),
            width: isActive ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF232E3A)
                  : const Color(0xFFD6DBE2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  /// Botones de acción inferiores: CTA primario oscuro con flecha y enlace secundario sobrio
  Widget _buildActionButtons({required bool isCompact}) {
    final btnHeight = isCompact ? 50.0 : 54.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón Primario: Iniciar sesión con flecha
        SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF232E3A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            onPressed: _navigateToLogin,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Iniciar sesión'),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: isCompact ? 4 : 8),

        // Botón Secundario: Crear una cuenta
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF737C8A),
            padding: const EdgeInsets.symmetric(vertical: 8),
            textStyle: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
          onPressed: _navigateToRegister,
          child: const Text('Crear una cuenta'),
        ),
      ],
    );
  }
}

/// Widget personalizado para renderizar el pin del mapa con el logo oficial de Yago adentro
class _YagoMapPin extends StatelessWidget {
  final double width;
  final double height;

  const _YagoMapPin({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Silueta del pin en gota invertida (teardrop) en tono grafito oscuro
          CustomPaint(
            size: Size(width, height),
            painter: _TeardropPinPainter(
              color: const Color(0xFF232E3A),
            ),
          ),

          // 2. Isotipo blanco de Yago perfectamente centrado en la cabeza circular del pin
          Positioned(
            top: (width - 20) / 2,
            child: Image.asset(
              'assets/images/yago_icon.png',
              width: 20,
              height: 20,
              color: Colors.white,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.pets_rounded,
                  size: 18,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter de precisión para dibujar la silueta en gota del pin de mapa
class _TeardropPinPainter extends CustomPainter {
  final Color color;

  _TeardropPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;
    final center = Offset(r, r);

    final path = Path();
    // Inicia en la punta inferior exacta
    path.moveTo(w / 2, h);

    // Curva bezier ascendente izquierda hacia la tangente del círculo superior
    path.cubicTo(
      w * 0.05,
      h * 0.65,
      0,
      r * 1.3,
      0,
      r,
    );

    // Arco semicircular en la parte superior
    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      3.14159265, // PI (lado izquierdo)
      3.14159265, // Barrido de PI hacia el lado derecho
      false,
    );

    // Curva bezier descendente derecha hacia la punta inferior
    path.cubicTo(
      w,
      r * 1.3,
      w * 0.95,
      h * 0.65,
      w / 2,
      h,
    );

    path.close();

    // Sombra suave proyectada por el pin
    canvas.drawShadow(path, const Color(0x38000000), 5.0, true);

    // Relleno sólido del pin
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TeardropPinPainter oldDelegate) =>
      oldDelegate.color != color;
}
