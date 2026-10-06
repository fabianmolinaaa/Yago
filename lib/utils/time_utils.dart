/// Utilidades para formateo dinámico de fechas y tiempos relativos en Yago.
library;

/// Extrae una fecha a partir de un ID con patrón timestamp (ej: "post-1728224567890", "pet-1728224567890").
DateTime? extractDateFromId(String id) {
  final match = RegExp(r'\d{10,}').firstMatch(id);
  if (match != null) {
    final millis = int.tryParse(match.group(0)!);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}

/// Formatea de manera dinámica una fecha al estilo de redes sociales:
/// "Recién publicado", "Hace 5 min", "Hace 2 horas", "Ayer, 14:30", "Hace 3 días", etc.
String formatTimeAgo(DateTime? date, {String fallback = 'Reciente'}) {
  if (date == null) return fallback;
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.isNegative || difference.inSeconds < 60) {
    return 'Recién publicado';
  } else if (difference.inMinutes < 60) {
    return 'Hace ${difference.inMinutes} min';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return 'Hace $hours ${hours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inDays == 1) {
    final minutes = date.minute.toString().padLeft(2, '0');
    final hours = date.hour.toString().padLeft(2, '0');
    return 'Ayer, $hours:$minutes';
  } else if (difference.inDays < 7) {
    return 'Hace ${difference.inDays} días';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return 'Hace $weeks ${weeks == 1 ? 'sem' : 'semanas'}';
  } else {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    final monthName = months[date.month - 1];
    final minutes = date.minute.toString().padLeft(2, '0');
    final hours = date.hour.toString().padLeft(2, '0');
    if (date.year == now.year) {
      return '${date.day} $monthName, $hours:$minutes';
    }
    return '${date.day} $monthName ${date.year}';
  }
}
