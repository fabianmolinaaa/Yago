import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const StandMapApp());
}

class StandMapApp extends StatelessWidget {
  const StandMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StandMap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
