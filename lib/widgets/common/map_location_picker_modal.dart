import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location_service.dart';
import '../../utils/design_system.dart';
import 'yago_button.dart';

/// Modal interactivo con mapa real (OpenStreetMap) para ubicar un punto (HU-S2-03).
/// Permite al usuario buscar direcciones/plazas, arrastrar el mapa, tocar cualquier
/// punto para reubicar el pin y ver con nitidez los nombres reales de las calles.
class MapLocationPickerModal extends StatefulWidget {
  final String initialLocation;
  final double initialLatitude;
  final double initialLongitude;

  const MapLocationPickerModal({
    super.key,
    required this.initialLocation,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  static Future<LocationResult?> show(
    BuildContext context, {
    String initialLocation = 'Costanera, Caleta Olivia',
    double initialLatitude = -46.4348,
    double initialLongitude = -67.5182,
  }) {
    return showModalBottomSheet<LocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MapLocationPickerModal(
        initialLocation: initialLocation,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
    );
  }

  @override
  State<MapLocationPickerModal> createState() => _MapLocationPickerModalState();
}

class _MapLocationPickerModalState extends State<MapLocationPickerModal> {
  late String _currentLocationName;
  late double _currentLatitude;
  late double _currentLongitude;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<LocationResult> _searchResults = [];
  bool _isSearching = false;
  bool _isResolvingAddress = false;
  Timer? _searchDebounceTimer;
  Timer? _moveDebounceTimer;

  // Zonas de referencia rápida populares en Caleta Olivia
  final List<Map<String, dynamic>> _quickZones = [
    {'name': 'El Gorosito (Centro)', 'lat': -46.4385, 'lng': -67.5278},
    {'name': 'Costanera, Caleta Olivia', 'lat': -46.4348, 'lng': -67.5182},
    {'name': 'Barrio Parque, Caleta Olivia', 'lat': -46.4425, 'lng': -67.5245},
    {'name': 'Barrio Miramar, Caleta Olivia', 'lat': -46.4478, 'lng': -67.5150},
    {'name': 'Barrio Gregores, Caleta Olivia', 'lat': -46.4452, 'lng': -67.5348},
    {'name': 'Barrio Patagonia, Caleta Olivia', 'lat': -46.4415, 'lng': -67.5410},
  ];

  @override
  void initState() {
    super.initState();
    _currentLocationName = widget.initialLocation.isNotEmpty
        ? widget.initialLocation
        : 'Costanera, Caleta Olivia';
    _currentLatitude = widget.initialLatitude;
    _currentLongitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _moveDebounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await LocationService().searchPlaces(query);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSearching = false);
      }
    });
  }

  void _selectPlace(LocationResult place) {
    setState(() {
      _currentLocationName = place.locationName;
      _currentLatitude = place.latitude;
      _currentLongitude = place.longitude;
      _searchResults = [];
      _searchController.clear();
    });

    _mapController.move(LatLng(place.latitude, place.longitude), 16.0);
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      _currentLatitude = point.latitude;
      _currentLongitude = point.longitude;
      _isResolvingAddress = true;
    });

    _mapController.move(point, _mapController.camera.zoom);
    _reverseGeocodeDebounced(point.latitude, point.longitude);
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        _currentLatitude = camera.center.latitude;
        _currentLongitude = camera.center.longitude;
        _isResolvingAddress = true;
      });
      _reverseGeocodeDebounced(camera.center.latitude, camera.center.longitude);
    }
  }

  void _reverseGeocodeDebounced(double lat, double lng) {
    _moveDebounceTimer?.cancel();
    _moveDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final resolved = await LocationService().reverseGeocode(lat, lng);
        if (!mounted) return;
        setState(() {
          _currentLocationName = resolved;
          _isResolvingAddress = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isResolvingAddress = false);
      }
    });
  }

  Future<void> _centerOnCurrentGps() async {
    try {
      final gpsResult = await LocationService().getCurrentLocation();
      _selectPlace(gpsResult);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo centrar en GPS: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicar en el mapa',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Elige la zona donde ocurrió el extravío o hallazgo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.muted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Buscador de lugares
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar plaza, barrio o calle...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.muted),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    )
                  : (_searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        )
                      : null),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Resultados de búsqueda flotantes
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final place = _searchResults[index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                        ),
                        title: Text(
                          place.locationName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        onTap: () => _selectPlace(place),
                      );
                    },
                  ),
                ),
              ),
            ),

          // Zonas populares de referencia en 1 tap
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickZones.map((zone) {
                final isSelected = _currentLocationName.contains(zone['name'] as String);
                return Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 8),
                  child: InkWell(
                    onTap: () {
                      _selectPlace(
                        LocationResult(
                          locationName: zone['name'] as String,
                          latitude: zone['lat'] as double,
                          longitude: zone['lng'] as double,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryTint : const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        zone['name'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // ─── MAPA REAL CON OPENSTREETMAP (CALLES NÍTIDAS Y NOMBRES REALES) ───
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(_currentLatitude, _currentLongitude),
                        initialZoom: 15.5,
                        minZoom: 4.0,
                        maxZoom: 18.5,
                        onPositionChanged: _onPositionChanged,
                        onTap: (_, point) => _onMapTapped(point),
                      ),
                      children: [
                        // Capa de mosaicos reales con nombres de calles en alta resolución
                        if (!isTest)
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.yago.app',
                            maxZoom: 19,
                          ),

                        // Círculo de radio contextual de 300 metros
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(_currentLatitude, _currentLongitude),
                              radius: 300,
                              useRadiusInMeter: true,
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderColor: AppColors.primary.withValues(alpha: 0.55),
                              borderStrokeWidth: 1.5,
                            ),
                          ],
                        ),

                        // Marcador con pin central nítido
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_currentLatitude, _currentLongitude),
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Chip superior de ayuda interactiva
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Text(
                              _isResolvingAddress
                                  ? 'Identificando calle...'
                                  : 'Toca o arrastra para mover el pin',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Controles flotantes de Zoom y GPS
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'map_zoom_in',
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            onPressed: () {
                              _mapController.move(
                                _mapController.camera.center,
                                (_mapController.camera.zoom + 1).clamp(4.0, 18.5),
                              );
                            },
                            child: const Icon(Icons.add_rounded, size: 20),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'map_zoom_out',
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            onPressed: () {
                              _mapController.move(
                                _mapController.camera.center,
                                (_mapController.camera.zoom - 1).clamp(4.0, 18.5),
                              );
                            },
                            child: const Icon(Icons.remove_rounded, size: 20),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'map_my_gps',
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            tooltip: 'Mi ubicación GPS',
                            onPressed: _centerOnCurrentGps,
                            child: const Icon(Icons.my_location_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tarjeta informativa de la ubicación seleccionada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PUNTO SELECCIONADO EN EL MAPA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentLocationName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Lat: ${_currentLatitude.toStringAsFixed(4)}, Lng: ${_currentLongitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Botón de confirmación
          YagoButton(
            text: 'Confirmar esta ubicación',
            size: YagoButtonSize.large,
            isFullWidth: true,
            onPressed: () {
              Navigator.of(context).pop(
                LocationResult(
                  locationName: _currentLocationName,
                  latitude: _currentLatitude,
                  longitude: _currentLongitude,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
