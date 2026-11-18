import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_colors.dart';

class PhoneLauncher {
  PhoneLauncher._();

  /// Normaliza un número telefónico (conservando '+' inicial y dígitos)
  /// y abre la aplicación nativa de llamadas del dispositivo (`tel:`).
  static Future<bool> launchPhoneDialer(
    BuildContext context,
    String rawPhone,
  ) async {
    final firstPhone = rawPhone.split('/').first.trim();
    final sanitized = firstPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (sanitized.replaceAll(RegExp(r'\D'), '').length < 6) {
      return false;
    }

    final uri = Uri(scheme: 'tel', path: sanitized);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;

      final fallbackLaunched = await launchUrl(uri);
      if (fallbackLaunched) return true;
    } catch (_) {
      // En entornos de prueba o emuladores sin app de teléfono instalada
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcando a $firstPhone...'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
    return false;
  }
}
