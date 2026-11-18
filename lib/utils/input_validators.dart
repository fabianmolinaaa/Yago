/// Utilidades centralizadas de validación y saneamiento de formularios en Yago.
///
/// Diseñadas bajo principios de seguridad defensiva y accesibilidad comunitaria:
/// - Impide fechas futuras o reportes antiguos (> 30 días).
/// - Valida formatos reales (correo, teléfono, edad neutral según Regla 4, etiquetas).
/// - Previene inyección de textos desmesurados y suplantación de cuentas oficiales.
class InputValidators {
  InputValidators._();

  /// Antigüedad máxima permitida para reportes de mascotas perdidas o encontradas.
  static const int maxReportAgeDays = 30;

  /// Cantidad máxima de teléfonos de contacto por reporte.
  static const int maxContactPhones = 3;

  /// Cantidad máxima de etiquetas (señas particulares) por reporte.
  static const int maxTagsCount = 8;

  /// Longitud máxima de cada etiqueta de seña particular.
  static const int maxTagLength = 35;

  /// Nombres reservados que no pueden ser utilizados por cuentas de usuario estándar.
  static const List<String> _reservedNames = [
    'equipo yago',
    'comunidad yago',
    'yago oficial',
    'admin',
    'administrador',
    'moderador',
    'soporte yago',
  ];

  /// Limpia espacios redundantes dentro de una cadena de texto.
  static String sanitizeText(String input) {
    return input.trim().replaceAll(RegExp(r'[ \t]+'), ' ');
  }

  /// Valida formato de correo electrónico (compatible con dominios modernos y subdominios).
  static bool isValidEmail(String email) {
    final clean = email.trim();
    if (clean.isEmpty || clean.length > 100) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(clean);
  }

  /// Valida el nombre completo o de perfil de un usuario.
  /// Retorna `null` si es válido, o el mensaje de error correspondiente.
  static String? validatePersonName(
    String name, {
    String emptyMessage = 'Por favor, ingresa tu nombre completo.',
  }) {
    final clean = sanitizeText(name);
    if (clean.isEmpty) {
      return emptyMessage;
    }
    if (clean.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }
    if (clean.length > 60) {
      return 'El nombre no puede superar los 60 caracteres.';
    }
    // Debe contener al menos 2 letras reales (no solo números o símbolos)
    final letterMatches = RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]').allMatches(clean);
    if (letterMatches.length < 2) {
      return 'Ingresa un nombre válido con letras.';
    }
    final lower = clean.toLowerCase();
    if (_reservedNames.any((r) => lower == r || lower.contains('equipo yago'))) {
      return 'Este nombre está reservado para la administración de Yago.';
    }
    return null;
  }

  /// Valida una contraseña en el registro.
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Por favor, ingresa una contraseña.';
    }
    if (password.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres válidos (sin contar espacios extremos).';
    }
    if (password.length > 128) {
      return 'La contraseña no puede superar los 128 caracteres.';
    }
    return null;
  }

  /// Valida un número de teléfono o WhatsApp.
  ///
  /// Por accesibilidad (usuarios sin línea activa que usan Chat Directo),
  /// el teléfono puede ser opcional (`required: false`), pero si se ingresa
  /// debe tener un formato telefónico válido (entre 7 y 15 dígitos).
  static String? validatePhone(String phone, {bool required = false}) {
    final clean = phone.trim();
    if (clean.isEmpty) {
      return required
          ? 'Ingresa un teléfono de contacto válido.'
          : null;
    }
    if (clean.length > 25) {
      return 'El número de teléfono es demasiado largo.';
    }
    // Solo permitir dígitos, +, -, paréntesis y espacios
    if (!RegExp(r'^\+?[\d\s\-()]+$').hasMatch(clean)) {
      return 'El teléfono solo puede contener números, +, guiones o espacios.';
    }
    // Contar cantidad real de dígitos numéricos (estándar E.164: 7 a 15 dígitos)
    final digitsOnly = clean.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7) {
      return 'El teléfono debe contener al menos 7 dígitos numéricos.';
    }
    if (digitsOnly.length > 15) {
      return 'El teléfono no puede superar los 15 dígitos numéricos.';
    }
    // Evitar números ficticios obvios de un solo dígito repetido (ej. 00000000)
    if (RegExp(r'^(\d)\1{6,}$').hasMatch(digitsOnly)) {
      return 'Por favor, ingresa un número de contacto real.';
    }
    return null;
  }

  /// Valida que la fecha de un reporte no sea futura ni tenga más de [maxDaysAgo] días.
  static String? validateReportDate(
    DateTime date, {
    int maxDaysAgo = maxReportAgeDays,
    DateTime? nowOverride,
  }) {
    final now = nowOverride ?? DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final earliestAllowed = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: maxDaysAgo));

    if (date.isAfter(todayEnd)) {
      return 'La fecha del reporte no puede ser una fecha futura.';
    }
    if (date.isBefore(earliestAllowed)) {
      return 'El reporte no puede tener más de $maxDaysAgo días de antigüedad.';
    }
    return null;
  }

  /// Valida el campo de edad neutral según la especie (Regla 4).
  static String? validateNeutralAge(String ageText, {required bool unknownAge}) {
    if (unknownAge) return null;
    final clean = sanitizeText(ageText);
    if (clean.isEmpty) return null; // Si queda vacío se asume 'Desconocida'

    if (clean.length > 35) {
      return 'La edad estimada no puede superar los 35 caracteres.';
    }
    if (clean.contains('-')) {
      return 'La edad no puede contener valores negativos.';
    }
    // Verificar si escribió un número desproporcionado (ej. 500 años)
    final numberMatch = RegExp(r'\d+').firstMatch(clean);
    if (numberMatch != null) {
      final value = int.tryParse(numberMatch.group(0)!);
      if (value != null && value <= 0) {
        return 'Ingresa una edad mayor a cero o marca "No conozco la edad".';
      }
      if (value != null && value > 80) {
        return 'Verifica la edad ingresada (máximo 80).';
      }
    }
    return null;
  }

  /// Valida una etiqueta de seña particular antes de agregarla.
  static String? validateTag(String rawTag, List<String> existingTags) {
    final clean = sanitizeText(rawTag);
    if (clean.isEmpty) return null;
    if (clean.length < 2) {
      return 'Cada seña particular debe tener al menos 2 caracteres.';
    }
    if (clean.length > maxTagLength) {
      return 'La seña particular es muy larga (máx. $maxTagLength caracteres).';
    }
    if (existingTags.length >= maxTagsCount) {
      return 'Puedes agregar hasta $maxTagsCount señas particulares como máximo.';
    }
    final alreadyExists = existingTags.any(
      (t) => t.toLowerCase() == clean.toLowerCase(),
    );
    if (alreadyExists) {
      return 'Esta seña particular ya fue agregada.';
    }
    return null;
  }

  /// Valida la ubicación escrita o seleccionada.
  /// No requiere GPS (puede escribirse a mano si el GPS del dispositivo falla),
  /// pero sí requiere al menos el nombre del barrio, calle o zona.
  static String? validateLocationText(String location) {
    final clean = sanitizeText(location);
    if (clean.isEmpty) {
      return 'Indica el barrio, calle o zona aproximada (puedes escribirlo manualmente).';
    }
    if (clean.length < 3) {
      return 'Ingresa una referencia de zona más descriptiva (mín. 3 caracteres).';
    }
    if (clean.length > 90) {
      return 'La ubicación no puede superar los 90 caracteres.';
    }
    return null;
  }

  /// Infiere coordenadas aproximadas de barrios conocidos de Caleta Olivia
  /// cuando la persona usuaria escribe la zona manualmente sin usar GPS ni mapa.
  static ({double latitude, double longitude}) inferCoordinatesFromText(
    String locationText, {
    double currentLat = -46.4385,
    double currentLng = -67.5278,
  }) {
    final lower = locationText.toLowerCase();
    const knownZones = <String, (double, double)>{
      'costanera': (-46.4348, -67.5182),
      'gorosito': (-46.4385, -67.5278),
      'centro': (-46.4385, -67.5278),
      'parque': (-46.4425, -67.5245),
      'miramar': (-46.4478, -67.5150),
      'gregores': (-46.4452, -67.5348),
      'patagonia': (-46.4415, -67.5410),
      '3 de febrero': (-46.4362, -67.5320),
      'rotary': (-46.4530, -67.5490),
      'mutual': (-46.4495, -67.5290),
    };

    for (final entry in knownZones.entries) {
      if (lower.contains(entry.key)) {
        return (latitude: entry.value.$1, longitude: entry.value.$2);
      }
    }
    return (latitude: currentLat, longitude: currentLng);
  }

  /// Calcula la etiqueta temporal coherente con la fecha del reporte (`_reportDate`).
  static String formatReportTimeAgo(DateTime reportDate, {DateTime? nowOverride}) {
    final now = nowOverride ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(reportDate.year, reportDate.month, reportDate.day);
    final diffDays = today.difference(selectedDay).inDays;

    if (diffDays <= 0) {
      return 'Recién publicado';
    } else if (diffDays == 1) {
      return 'Ayer';
    } else {
      return 'Hace $diffDays días';
    }
  }
}
