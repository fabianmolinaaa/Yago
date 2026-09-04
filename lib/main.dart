import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const YagoApp());
}

class YagoApp extends StatelessWidget {
  final Widget? home;

  const YagoApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yago',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home ?? const LoginScreen(),
    );
  }
}

// Retrocompatibilidad
typedef StandMapApp = YagoApp;
