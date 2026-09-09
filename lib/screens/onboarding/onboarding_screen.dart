import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Pantalla de bienvenida y Onboarding de Yago basada en el diseño de referencia.
/// Cuenta con una animación de presentación inicial en fondo oscuro (logo grande claro, texto Yago y transición)
/// y la pantalla principal de onboarding con la ilustración del mapa, el lema y las acciones inferiores.
class OnboardingScreen extends StatefulWidget {
  /// Permite forzar u omitir la animación de presentación de entrada.
  /// Si no se especifica, se muestra únicamente la primera vez en la sesión.
  final bool? showIntro;

  /// Registra si la animación de intro ya fue ejecutada en la sesión actual.
  static bool hasShownIntro = false;

  const OnboardingScreen({
    super.key,
    this.showIntro,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // Controlador de la animación de presentación de inicio
  late final AnimationController _introController;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _introFadeOut;

  bool _isIntroActive = false;

  @override
  void initState() {
    super.initState();

    final isTestEnvironment = Platform.environment.containsKey('FLUTTER_TEST');

    // Determinar si corresponde mostrar la animación de presentación
    final shouldShowIntro = widget.showIntro ??
        (!isTestEnvironment && !OnboardingScreen.hasShownIntro);

    _isIntroActive = shouldShowIntro;
    if (shouldShowIntro) {
      OnboardingScreen.hasShownIntro = true;
    }

    // Animación secuencial de presentación (Intro/Splash)
    // 0.00 - 0.35: Aparición del logo grande sin texto (fade in + scale)
    // 0.35 - 0.70: Aparición del texto "Yago" debajo del logo (fade in + slide up)
    // 0.70 - 0.85: Pausa para admirar la marca
    // 0.85 - 1.00: Transición hacia el onboarding (fade out del lienzo oscuro)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOutCubic),
      ),
    );

    _iconScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _introFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _introController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isIntroActive = false;
          });
        }
      }
    });

    if (_isIntroActive) {
      _introController.forward();
    }
  }

  void _skipIntro() {
    if (_isIntroActive) {
      _introController.stop();
      setState(() {
        _isIntroActive = false;
      });
    }
  }

  @override
  void dispose() {
    _introController.dispose();
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
      value: _isIntroActive
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: const Color(0xFF11161F),
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. Pantalla principal de Onboarding con las dimensiones y estilo del diseño de referencia
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 720;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 20.0 : 28.0,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: isCompact ? 16 : 28),

                            // 1. Logo oficial de Yago en cabecera
                            YagoLogo(
                              height: isCompact ? 68.0 : 82.0,
                            ),

                            SizedBox(height: isCompact ? 12 : 24),

                            // 2. Ilustración central (perro, gato, mapa con radar y pin)
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  'assets/images/onboarding_illustration.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),

                            SizedBox(height: isCompact ? 14 : 26),

                            // 3. Título editorial en dos líneas
                            Text(
                              'Explora, Conecta,\nReencuentra',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: isCompact ? 24 : 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.20,
                                color: const Color(0xFF1D273B),
                              ),
                            ),

                            SizedBox(height: isCompact ? 8 : 12),

                            // 4. Subtítulo explicativo
                            Text(
                              'Ayudá a encontrar mascotas perdidas\ny reportá las que veas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: isCompact ? 13.5 : 15.0,
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                                color: const Color(0xFF64748B),
                              ),
                            ),

                            SizedBox(height: isCompact ? 20 : 36),

                            // 5. Botones de acción inferiores
                            _buildActionButtons(isCompact: isCompact),

                            SizedBox(height: isCompact ? 8 : 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Capa de Animación de Presentación (Fondo oscuro, logo grande sin texto, luego texto y transición)
            if (_isIntroActive)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _skipIntro,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _introController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _introFadeOut.value.clamp(0.0, 1.0),
                        child: child,
                      );
                    },
                    child: Container(
                      color: const Color(0xFF11161F),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _introController,
                          builder: (context, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo grande sin texto, claro y centrado
                                Opacity(
                                  opacity: _iconOpacity.value.clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: _iconScale.value,
                                    child: Image.asset(
                                      'assets/images/yago_icon.png',
                                      width: 108,
                                      height: 108,
                                      color: Colors.white,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Texto "Yago" que aparece debajo
                                Opacity(
                                  opacity: _textOpacity.value.clamp(0.0, 1.0),
                                  child: SlideTransition(
                                    position: _textSlide,
                                    child: const Text(
                                      'Yago',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Botones de acción inferiores con dimensiones y aspecto del diseño
  Widget _buildActionButtons({required bool isCompact}) {
    final btnHeight = isCompact ? 52.0 : 58.0;

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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            onPressed: _navigateToLogin,
            child: const Row(
              children: [
                SizedBox(width: 24),
                Expanded(
                  child: Text(
                    'Iniciar sesión',
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: isCompact ? 4 : 10),

        // Botón Secundario: Crear una cuenta
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(vertical: 8),
            textStyle: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.5,
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
