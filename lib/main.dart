import 'package:flutter/material.dart';

import 'screens/auth/auth_gate.dart';
import 'utils/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirestoreService().seedExistingData().catchError((_) {});

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
      home: home ?? const AuthGate(),
    );
  }
}
