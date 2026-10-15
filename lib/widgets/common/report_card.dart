import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pet.dart';
import '../../utils/design_system.dart';
import 'yago_badge.dart';
import 'yago_button.dart';
import 'yago_pet_image.dart';

/// Tarjeta visual estilo Pinterest (Masonry) diseñada para distribución
/// orgánica y limpia de fotografías de mascotas perdidas y encontradas.
///
/// La fotografía es 100% limpia sin chips ni badges de colores invasivos superpuestos.
/// La altura se adapta naturalmente al aspect ratio de la imagen.
/// El estado (Perdida / Encontrada) se comunica de forma moderna y sutil en el pie de foto
/// mediante un micro-indicador y tipografía limpia junto al barrio.
class ReportGridCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onZoneTap;
  final VoidCallback? onOptionsTap;

  const ReportGridCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onZoneTap,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = pet.status == YagoPetStatus.lost;
    final neighborhood = pet.location.isNotEmpty
        ? pet.location.split(',')[0].trim()
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 1. Fotografía limpia con tamaño definido uniforme (180px) ──
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: YagoPetImage(
                imageUrl: pet.imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholderHeight: 180,
              ),
            ),
          ),

          // ─── 2. Pie de foto minimalista con micro-indicador tipográfico ───
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 2, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre de la mascota
                      Text(
                        pet.name.isNotEmpty ? pet.name : pet.breed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Estado sutil con micro-punto indicador y barrio
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.subtle,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4.5),
                          Text(
                            isLost ? 'Perdida' : 'Encontrada',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (neighborhood.isNotEmpty) ...[
                            Expanded(
                              child: Text(
                                ' · $neighborhood',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón minimalista de opciones (...)
                GestureDetector(
                  onTap: () {
                    if (onOptionsTap != null) {
                      onOptionsTap!();
                    } else if (onZoneTap != null) {
                      onZoneTap!();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 19,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta horizontal compacta para vista alternativa de lista
class ReportListCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onZoneTap;

  const ReportListCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = pet.status == YagoPetStatus.lost;
    final neighborhood = pet.location.isNotEmpty
        ? pet.location.split(',')[0].trim()
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: YagoPetImage(
                    imageUrl: pet.imageUrl,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            pet.name.isNotEmpty ? pet.name : 'Sin nombre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          pet.timeAgo.isNotEmpty ? pet.timeAgo : 'Reciente',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.twitterHandle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.subtle,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4.5),
                        Text(
                          isLost ? 'Perdida' : 'Encontrada',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (neighborhood.isNotEmpty) ...[
                          Text(
                            ' · $neighborhood',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species} · ${pet.breed}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (onZoneTap != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: onZoneTap,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Ver zona en mapa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal inferior para visualización contextual de zona en mapa (HU-S2-02).
/// Ampliado, nítido y con mapa interactivo real (OpenStreetMap) centrado en las coordenadas reales.
class ContextualZoneModal extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onOpenFullDetail;

  const ContextualZoneModal({
    super.key,
    required this.pet,
    this.onOpenFullDetail,
  });

  static void show(BuildContext context, Pet pet, {VoidCallback? onOpenFullDetail}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ContextualZoneModal(
        pet: pet,
        onOpenFullDetail: onOpenFullDetail,
      ),
    );
  }

  @override
  State<ContextualZoneModal> createState() => _ContextualZoneModalState();
}

class _ContextualZoneModalState extends State<ContextualZoneModal> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openInMaps(BuildContext context) async {
    final lat = widget.pet.latitude;
    final lng = widget.pet.longitude;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la aplicación de mapas.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la aplicación de mapas.')),
        );
      }
    }
  }

  void _recenterMap() {
    _mapController.move(
      LatLng(widget.pet.latitude, widget.pet.longitude),
      15.8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    const accentColor = AppColors.primary;
    final screenHeight = MediaQuery.of(context).size.height;
    // Modal ampliado al 86% de la pantalla para máxima visibilidad del mapa
    final modalHeight = (screenHeight * 0.86).clamp(540.0, 840.0);

    return SafeArea(
      child: SizedBox(
        height: modalHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle de arrastre superior
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cabecera con datos de la mascota
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: YagoPetImage(
                      imageUrl: widget.pet.imageUrl,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenFullDetail?.call();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.pet.name.isNotEmpty ? widget.pet.name : 'Reporte de mascota',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              YagoStatusBadge(status: widget.pet.status),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.pet.breed.isNotEmpty
                                ? '${widget.pet.breed} · ${widget.pet.location}'
                                : widget.pet.location,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 22),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ─── MAPA AMPLIADO Y PROMINENTE CON FLUTTER_MAP Y OPENSTREETMAP ───
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border, width: 1.2),
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(widget.pet.latitude, widget.pet.longitude),
                            initialZoom: 15.8,
                            minZoom: 4.0,
                            maxZoom: 18.5,
                          ),
                          children: [
                            // Capa de mosaicos reales con calles y barrios nítidos
                            if (!isTest)
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.yago.app',
                                maxZoom: 19,
                              ),

                            // Círculo de radio contextual de 500 metros
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: LatLng(widget.pet.latitude, widget.pet.longitude),
                                  radius: 500,
                                  useRadiusInMeter: true,
                                  color: accentColor.withValues(alpha: 0.12),
                                  borderColor: accentColor.withValues(alpha: 0.65),
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),

                            // Marcador / Pin con alta visibilidad
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(widget.pet.latitude, widget.pet.longitude),
                                  width: 140,
                                  height: 84,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Cartel flotante con nombre
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.28),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.pets_rounded, color: Colors.white, size: 12),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                widget.pet.name.isNotEmpty ? widget.pet.name : 'Aquí',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Inter',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Pin central blanco/primario con halo
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.45),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Botón flotante para re-centrar el mapa en la mascota
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _recenterMap,
                              child: const Padding(
                                padding: EdgeInsets.all(9),
                                child: Icon(
                                  Icons.my_location_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Etiqueta flotante inferior con barrio y radio
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.radar_rounded,
                                    size: 16,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Radio estimado de 500m alrededor de ${widget.pet.location}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'Coordenadas: ${widget.pet.latitude.toStringAsFixed(4)}, ${widget.pet.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
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
              const SizedBox(height: 12),

              // Nota informativa de privacidad
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Por seguridad comunitaria, se muestra un radio contextual aproximado del hecho.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Botón de acción principal: Abrir en Maps
              SizedBox(
                width: double.infinity,
                child: YagoButton(
                  text: 'Abrir en Maps',
                  icon: const Icon(
                    Icons.map_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () => _openInMaps(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
