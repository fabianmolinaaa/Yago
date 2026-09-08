import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Modelo de datos para cada tip del onboarding
class _OnboardingTip {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingTip({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Pantalla de bienvenida y onboarding de Yago.
/// Diseño minimalista estilo Apple: fondo primario sobrio, tipografía cuidada,
/// espaciado amplio, sin bordes fluorescentes ni sombras recargadas.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  static const List<_OnboardingTip> _tips = [
    _OnboardingTip(
      title: 'Reportá en segundos',
      description:
          'Publicá una alerta con foto, detalles y ubicación para iniciar la búsqueda de inmediato.',
      icon: Icons.campaign_outlined,
    ),
    _OnboardingTip(
      title: 'Explorá tu zona',
      description:
          'Consultá el mapa interactivo en tiempo real y filtrá por mascotas perdidas o encontradas.',
      icon: Icons.map_outlined,
    ),
    _OnboardingTip(
      title: 'Avisos en tiempo real',
      description:
          'Recibí notificaciones directas si se reporta una mascota cerca de tu radio habitual.',
      icon: Icons.notifications_none_rounded,
    ),
    _OnboardingTip(
      title: 'Reconectá familias',
      description:
          'Comunicate de forma segura con vecinos y dueños para concretar cada reencuentro.',
      icon: Icons.favorite_border_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _tips.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
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
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 680;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    SizedBox(height: isCompact ? 12 : 24),

                    // 1. Cabecera Minimalista Apple: Logo limpio y título
                    _buildHeader(isCompact: isCompact),

                    SizedBox(height: isCompact ? 12 : 20),

                    // 2. Carrusel de Tips: Elegante, limpio y sin tarjetas recargadas
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                  return _buildSlideItem(
                                    _tips[index],
                                    isCompact: isCompact,
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: isCompact ? 10 : 16),

                          // Indicador de páginas estilo iOS
                          _buildPageIndicator(),
                        ],
                      ),
                    ),

                    SizedBox(height: isCompact ? 16 : 28),

                    // 3. Botones de acción estilo Apple (primario blanco sólido, secundario texto sobrio)
                    _buildActionButtons(isCompact: isCompact),

                    SizedBox(height: isCompact ? 12 : 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Encabezado minimalista: logo sin burbujas ni bordes, tipografía sobria
  Widget _buildHeader({required bool isCompact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo de Yago estilizado en blanco
        YagoLogo(
          height: isCompact ? 62 : 78,
          color: Colors.white,
        ),
        SizedBox(height: isCompact ? 8 : 12),

        // Nombre de la marca
        const Text(
          'Yago',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 3),

        // Lema atenuado
        Text(
          'Encontrar · Avisar · Reencontrar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.1,
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }

  /// Cada tip presentado con estética Apple: icono refinado en cápsula sutil y tipografía nítida
  Widget _buildSlideItem(_OnboardingTip tip, {required bool isCompact}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono en contenedor circular sutil y sobrio (sin bordes llamativos)
              Container(
                width: isCompact ? 52 : 60,
                height: isCompact ? 52 : 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tip.icon,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: isCompact ? 26 : 30,
                ),
              ),

              SizedBox(height: isCompact ? 14 : 20),

              // Título del tip
              Text(
                tip.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: isCompact ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: isCompact ? 6 : 10),

              // Descripción en tono suave plata, sin brillo fluorescente
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Text(
                  tip.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: const Color(0xFFD6DBE2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Indicador de páginas minimalista estilo iOS
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
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3.5),
            width: isActive ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  /// Botones de acción estilo Apple: botón primario blanco con curvatura suave y enlace secundario limpio
  Widget _buildActionButtons({required bool isCompact}) {
    final btnHeight = isCompact ? 48.0 : 52.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón Primario: Iniciar sesión
        SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            onPressed: _navigateToLogin,
            child: const Text('Iniciar sesión'),
          ),
        ),

        SizedBox(height: isCompact ? 6 : 8),

        // Botón Secundario: Crear cuenta (texto minimalista estilo iOS)
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.85),
            padding: const EdgeInsets.symmetric(vertical: 10),
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
