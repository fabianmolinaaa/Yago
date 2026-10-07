import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final String locationName;
  final double latitude;
  final double longitude;

  const LocationResult({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Obtiene la ubicación actual del dispositivo y resuelve el barrio o ciudad.
  /// Si los permisos son denegados o se ejecuta en simulador/test, retorna un valor seguro de fallback.
  Future<LocationResult?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fallback si el servicio está apagado
        return const LocationResult(
          locationName: 'Palermo, CABA',
          latitude: -34.5889,
          longitude: -58.4233,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            locationName: 'Palermo, CABA',
            latitude: -34.5889,
            longitude: -58.4233,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          locationName: 'Palermo, CABA',
          latitude: -34.5889,
          longitude: -58.4233,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );

      final resolvedName = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        locationName: resolvedName,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('LocationService: error obteniendo posición: $e');
      // Fallback seguro sin bloquear al usuario
      return const LocationResult(
        locationName: 'Palermo, CABA',
        latitude: -34.5889,
        longitude: -58.4233,
      );
    }
  }

  /// Resuelve coordenadas a un nombre de barrio legible mediante geocodificación inversa
  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=14',
      );

      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'YagoPetApp/1.0 (contacto@yagoapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final address = json['address'] as Map<String, dynamic>?;

        if (address != null) {
          final neighbourhood = address['neighbourhood'] ??
              address['suburb'] ??
              address['quarter'] ??
              address['city_district'];
          final city = address['city'] ?? address['town'] ?? address['state'] ?? 'CABA';

          if (neighbourhood != null) {
            return '$neighbourhood, $city';
          }
          if (address['road'] != null) {
            return '${address['road']}, $city';
          }
          return '$city';
        }
      }
    } catch (_) {
      // Si falla la red o hay timeout, usar aproximación según coordenadas
    }

    // Aproximación por cuadrantes conocidos en CABA / Argentina
    if (lat >= -34.62 && lat <= -34.55 && lng >= -58.48 && lng <= -58.38) {
      if (lat > -34.58) return 'Belgrano / Núñez, CABA';
      if (lat > -34.60) return 'Palermo / Recoleta, CABA';
      return 'Caballito / Almagro, CABA';
    }

    return 'Cerca de (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
  }
}
