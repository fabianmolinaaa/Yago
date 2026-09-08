import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const YagoLogo(height: 80),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          );
        }

        // Si el usuario está autenticado, navega al Home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // Si no está autenticado, muestra la pantalla de inicio con onboarding
        return const OnboardingScreen();
      },
    );
  }
}
