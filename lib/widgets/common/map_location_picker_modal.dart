import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../utils/design_system.dart';
import 'yago_button.dart';

/// Modal interactivo para ubicar un punto en el mapa (HU-S2-03).
/// Permite al usuario buscar plazas/barrios, arrastrar el mapa o tocar un punto
/// para seleccionar la ubicación exacta cuando no se encuentra en el lugar del hecho.
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
    String initialLocation = 'Palermo, CABA',
    double initialLatitude = -34.5889,
    double initialLongitude = -58.4233,
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

  final TextEditingController _searchController = TextEditingController();
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;
  bool _isResolvingAddress = false;
  Timer? _debounceTimer;

  // Offset del mapa interactivo
  Offset _mapOffset = Offset.zero;

  // Zonas de referencia rápida populares
  final List<Map<String, dynamic>> _quickZones = [
    {'name': 'Plaza Armenia, Palermo', 'lat': -34.5891, 'lng': -58.4255},
    {'name': 'Parque Las Heras, Palermo', 'lat': -34.5841, 'lng': -58.4068},
    {'name': 'Parque Centenario, Caballito', 'lat': -34.6063, 'lng': -58.4355},
    {'name': 'Barrancas de Belgrano', 'lat': -34.5602, 'lng': -58.4501},
    {'name': 'Plaza Serrano, Palermo', 'lat': -34.5883, 'lng': -58.4308},
    {'name': 'Recoleta, CABA', 'lat': -34.5878, 'lng': -58.3934},
  ];

  @override
  void initState() {
    super.initState();
    _currentLocationName = widget.initialLocation.isNotEmpty
        ? widget.initialLocation
        : 'Palermo, CABA';
    _currentLatitude = widget.initialLatitude;
    _currentLongitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
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
      _mapOffset = Offset.zero;
    });
  }

  Future<void> _onMapPanEnd() async {
    setState(() => _isResolvingAddress = true);
    try {
      // Desplazamiento aproximado en grados según offset
      final deltaLat = -_mapOffset.dy * 0.00005;
      final deltaLng = _mapOffset.dx * 0.00005;

      final newLat = _currentLatitude + deltaLat;
      final newLng = _currentLongitude + deltaLng;

      final resolvedName = await LocationService().reverseGeocode(newLat, newLng);
      if (!mounted) return;
      setState(() {
        _currentLatitude = newLat;
        _currentLongitude = newLng;
        _currentLocationName = resolvedName;
        _mapOffset = Offset.zero;
        _isResolvingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isResolvingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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

          // Resultados de búsqueda flotantes (si hay)
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                    title: Text(place.locationName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    onTap: () => _selectPlace(place),
                  );
                },
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
          const SizedBox(height: 8),

          // ─── Lienzo interactivo de mapa con pin central ─────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECEF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _mapOffset += details.delta;
                    });
                  },
                  onPanEnd: (_) => _onMapPanEnd(),
                  child: Stack(
                    children: [
                      // Fondo de mapa con calles y manzanas
                      Transform.translate(
                        offset: _mapOffset,
                        child: CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: _MapCanvasPainter(),
                        ),
                      ),

                      // Círculo de radar contextual
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // Pin central flotante
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Indicador superior de arrastre
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pan_tool_rounded, size: 13, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Text(
                                _isResolvingAddress
                                    ? 'Actualizando dirección...'
                                    : 'Arrastra el mapa para ubicar el punto',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta de ubicación seleccionada
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
                        'PUNTO SELECCIONADO',
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
                        '(${_currentLatitude.toStringAsFixed(4)}, ${_currentLongitude.toStringAsFixed(4)})',
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
          const SizedBox(height: 14),

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

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blockPaint = Paint()
      ..color = const Color(0xFFDEE3E8)
      ..style = PaintingStyle.fill;

    final parkPaint = Paint()
      ..color = const Color(0xFFD3E7D7)
      ..style = PaintingStyle.fill;

    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final avenuePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // Dibujar manzanas (grid urbano simulado)
    const step = 80.0;
    for (double x = -step * 2; x < size.width + step * 2; x += step) {
      for (double y = -step * 2; y < size.height + step * 2; y += step) {
        final isPark = (x.toInt() % 160 == 0 && y.toInt() % 160 == 0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 6, y + 6, step - 12, step - 12),
            const Radius.circular(8),
          ),
          isPark ? parkPaint : blockPaint,
        );
      }
    }

    // Calles horizontales y verticales
    for (double y = -step * 2; y < size.height + step * 2; y += step) {
      canvas.drawLine(Offset(-step * 2, y), Offset(size.width + step * 2, y), streetPaint);
    }
    for (double x = -step * 2; x < size.width + step * 2; x += step) {
      canvas.drawLine(Offset(x, -step * 2), Offset(x, size.height + step * 2), streetPaint);
    }

    // Avenida diagonal principal
    canvas.drawLine(
      const Offset(-100, 50),
      Offset(size.width + 100, size.height + 150),
      avenuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
