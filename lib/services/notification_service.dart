import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio de notificaciones del sistema para mensajes directos de Yago (HU-S4-05).
///
/// Muestra una notificación en el celular al recibir mensajes directos sin necesidad
/// de entrar a la aplicación. Por privacidad, la notificación únicamente informa que
/// se ha recibido un mensaje y, si llegan múltiples mensajes, acumula el número
/// en una misma notificación ("Has recibido N mensajes").
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const MethodChannel _channel = MethodChannel(
    'com.example.yago/notifications',
  );

  int _accumulatedMessagesCount = 0;
  String? _lastNotificationTitle;
  String? _lastNotificationBody;

  /// Cantidad acumulada de mensajes directos pendientes en la notificación activa.
  int get accumulatedMessagesCount => _accumulatedMessagesCount;

  /// Último título mostrado en la notificación del sistema.
  String? get lastNotificationTitle => _lastNotificationTitle;

  /// Último texto mostrado en la notificación del sistema.
  String? get lastNotificationBody => _lastNotificationBody;

  /// Genera el texto exacto de la notificación según la cantidad acumulada.
  /// - 1 mensaje: "Has recibido un mensaje"
  /// - N mensajes (>1): "Has recibido N mensajes"
  static String formatNotificationBody(int count) {
    if (count <= 1) {
      return 'Has recibido un mensaje';
    }
    return 'Has recibido $count mensajes';
  }

  /// Inicializa el canal de notificaciones del sistema y solicita permisos en Android 13+.
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod<void>('initialize');
    } catch (_) {
      // En entornos de test o plataformas sin canal nativo se ignora de forma segura.
    }
  }

  /// Registra la llegada de [newMessagesCount] mensaje(s) directo(s), acumulando el contador
  /// y disparando/actualizando la notificación del sistema en el celular.
  Future<void> notifyIncomingDirectMessages({
    int newMessagesCount = 1,
    int? totalUnreadCount,
  }) async {
    if (newMessagesCount <= 0) return;

    _accumulatedMessagesCount += newMessagesCount;
    if (totalUnreadCount != null &&
        totalUnreadCount > _accumulatedMessagesCount) {
      _accumulatedMessagesCount = totalUnreadCount;
    }

    const title = 'Yago';
    final body = formatNotificationBody(_accumulatedMessagesCount);
    _lastNotificationTitle = title;
    _lastNotificationBody = body;
    notifyListeners();

    try {
      await _channel.invokeMethod<void>('showChatNotification', {
        'count': _accumulatedMessagesCount,
        'title': title,
        'body': body,
      });
    } catch (_) {
      // Ignorado de forma segura en entorno de pruebas.
    }
  }

  /// Sincroniza el contador acumulado cuando el usuario lee o limpia conversaciones.
  /// Si ya no quedan mensajes sin leer, descarta la notificación del celular.
  Future<void> syncWithUnreadCount(int totalUnreadCount) async {
    if (totalUnreadCount <= 0) {
      await clearNotifications();
      return;
    }

    if (_accumulatedMessagesCount > totalUnreadCount) {
      _accumulatedMessagesCount = totalUnreadCount;
      const title = 'Yago';
      final body = formatNotificationBody(_accumulatedMessagesCount);
      _lastNotificationTitle = title;
      _lastNotificationBody = body;
      notifyListeners();

      try {
        await _channel.invokeMethod<void>('showChatNotification', {
          'count': _accumulatedMessagesCount,
          'title': title,
          'body': body,
        });
      } catch (_) {}
    }
  }

  /// Limpia el contador acumulado y descarta la notificación activa del celular.
  Future<void> clearNotifications() async {
    final hadActive =
        _accumulatedMessagesCount > 0 || _lastNotificationBody != null;
    _accumulatedMessagesCount = 0;
    _lastNotificationTitle = null;
    _lastNotificationBody = null;
    if (hadActive) {
      notifyListeners();
    }

    try {
      await _channel.invokeMethod<void>('cancelChatNotification');
    } catch (_) {}
  }
}
