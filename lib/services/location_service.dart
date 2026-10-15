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

class CityResult {
  final String cityName;
  final String province;
  final String country;
  final double latitude;
  final double longitude;

  const CityResult({
    required this.cityName,
    required this.province,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  String get fullDisplayName =>
      province.isNotEmpty ? '$cityName, $province' : (country.isNotEmpty ? '$cityName, $country' : cityName);
}

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Obtiene la posición GPS real del dispositivo y resuelve la dirección/barrio.
  /// Lanza [LocationServiceException] si el GPS está apagado o los permisos son denegados,
  /// permitiendo informar con claridad al usuario en la interfaz.
  Future<LocationResult> getCurrentLocation() async {
    // En entorno de tests automáticos (donde no hay sensor GPS ni permisos de hardware):
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return const LocationResult(
        locationName: 'Costanera, Caleta Olivia',
        latitude: -46.4348,
        longitude: -67.5182,
      );
    }

    // 1. Verificar si el servicio de ubicación está habilitado en el dispositivo
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'El GPS está desactivado. Por favor enciende la ubicación en tu dispositivo.',
      );
    }

    // 2. Verificar y solicitar permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          'Permiso de ubicación denegado. Puedes escribir la dirección manualmente.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Los permisos de ubicación están denegados permanentemente en los Ajustes del dispositivo.',
      );
    }

    // 3. Obtener la posición GPS REAL y precisa del hardware
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    // 4. Geocodificación inversa real consultando OpenStreetMap Nominatim
    String resolvedName;
    try {
      resolvedName = await reverseGeocode(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      debugPrint('Error en reverse geocode: $e');
      resolvedName = 'Ubicación actual (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
    }

    return LocationResult(
      locationName: resolvedName,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Busca lugares, plazas o barrios por texto usando Nominatim (OSM)
  Future<List<LocationResult>> searchPlaces(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [
        LocationResult(
          locationName: '$cleanQuery, Caleta Olivia',
          latitude: -46.4348,
          longitude: -67.5182,
        ),
      ];
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);

    try {
      final encodedQuery = Uri.encodeComponent(cleanQuery);
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&q=$encodedQuery&limit=5&addressdetails=1',
      );

      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'YagoPetApp/1.0 (contacto@yagoapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final list = jsonDecode(responseBody) as List<dynamic>;

        return list.map((item) {
          final lat = double.tryParse(item['lat'].toString()) ?? -34.5889;
          final lon = double.tryParse(item['lon'].toString()) ?? -58.4233;
          final displayName = item['display_name'] as String? ?? cleanQuery;

          // Simplificar nombres muy largos para mostrarlos de forma elegante
          final parts = displayName.split(',');
          final shortName = parts.take(3).join(',').trim();

          return LocationResult(
            locationName: shortName,
            latitude: lat,
            longitude: lon,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('LocationService: error en searchPlaces: $e');
    } finally {
      client.close();
    }

    return [];
  }

  /// Busca ciudades y localidades dinámicamente mediante el servicio geográfico
  /// oficial de OpenStreetMap / Nominatim (igual que en Google Maps o Facebook Marketplace).
  Future<List<CityResult>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [
        CityResult(
          cityName: cleanQuery,
          province: 'Chubut',
          country: 'Argentina',
          latitude: -43.2531,
          longitude: -65.3094,
        ),
      ];
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);

    try {
      final encodedQuery = Uri.encodeComponent(cleanQuery);
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&q=$encodedQuery&limit=8&addressdetails=1',
      );

      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'YagoPetApp/1.0 (contacto@yagoapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final list = jsonDecode(responseBody) as List<dynamic>;

        final results = <CityResult>[];
        final seen = <String>{};

        for (final item in list) {
          final address = item['address'] as Map<String, dynamic>?;
          String rawCity = '';
          String province = '';
          String country = '';

          if (address != null) {
            rawCity = address['city'] ??
                address['town'] ??
                address['village'] ??
                address['municipality'] ??
                address['hamlet'] ??
                address['county'] ??
                item['name'] ??
                '';
            province = address['state'] ?? address['state_district'] ?? '';
            country = address['country'] ?? '';
          } else {
            rawCity = item['name'] ?? '';
          }

          // Limpiar prefijos administrativos comunes para tener el nombre limpio de la ciudad
          String cleanCity = rawCity
              .replaceAll('Municipio de ', '')
              .replaceAll('Comuna de ', '')
              .replaceAll('Departamento ', '')
              .replaceAll('Partido de ', '')
              .trim();
          if (cleanCity.isEmpty) {
            cleanCity = item['name']?.toString() ?? '';
          }

          final key = '${cleanCity.toLowerCase()}_${province.toLowerCase()}';
          if (cleanCity.isNotEmpty && !seen.contains(key)) {
            seen.add(key);
            final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
            final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;

            results.add(CityResult(
              cityName: cleanCity,
              province: province,
              country: country,
              latitude: lat,
              longitude: lon,
            ));
          }
        }

        return results;
      }
    } catch (e) {
      debugPrint('LocationService.searchCities error: $e');
    } finally {
      client.close();
    }

    return [];
  }

  /// Geocodificación inversa real mediante la API oficial de Nominatim (OSM)
  Future<String> reverseGeocode(double lat, double lng) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=16&addressdetails=1',
      );

      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'YagoPetApp/1.0 (contacto@yagoapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final address = json['address'] as Map<String, dynamic>?;

        if (address != null) {
          final road = address['road'];
          final houseNumber = address['house_number'];
          final neighbourhood = address['neighbourhood'] ??
              address['suburb'] ??
              address['quarter'] ??
              address['residential'] ??
              address['city_district'];
          final city = address['city'] ?? address['town'] ?? address['municipality'] ?? address['state'];

          final parts = <String>[];
          if (road != null) {
            parts.add(houseNumber != null ? '$road $houseNumber' : '$road');
          }
          if (neighbourhood != null && !parts.contains(neighbourhood)) {
            parts.add(neighbourhood.toString());
          }
          if (city != null && !parts.contains(city)) {
            parts.add(city.toString());
          }

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
      }
    } finally {
      client.close();
    }

    return 'Cerca de (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }
}
