import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';

class PetMapTab extends StatefulWidget {
  const PetMapTab({super.key});

  @override
  State<PetMapTab> createState() => _PetMapTabState();
}

class _PetMapTabState extends State<PetMapTab> {
  Pet? _selectedPet;

  @override
  Widget build(BuildContext context) {
    final pets = MockDataService().getAllPets();

    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      appBar: AppBar(
        title: const Text('Mapa de Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primary),
            tooltip: 'Mi ubicación',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centrado en tu ubicación actual (CABA).'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo de mapa interactivo simulado estilizado
          GestureDetector(
            onTap: () {
              if (_selectedPet != null) {
                setState(() => _selectedPet = null);
              }
            },
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 2.5,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: _MapGridPainter(),
                  child: Stack(
                    children: [
                      // Centro de referencia: Obelisco / CABA
                      Positioned(
                        top: 280,
                        left: 170,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_city_rounded, size: 14, color: AppColors.muted),
                              SizedBox(width: 4),
                              Text('CABA Centro', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),

                      // Pines de las mascotas
                      ...pets.map((pet) {
                        // Mapeo proporcional de coordenadas para la visualización gráfica
                        // Rango latitud: -34.54 a -34.62 -> Y de 100 a 460
                        // Rango longitud: -58.48 a -58.39 -> X de 40 a 320
                        final normY = (-pet.latitude - 34.54) / (34.63 - 34.54);
                        final normX = (-pet.longitude - 58.39) / (58.49 - 58.39);

                        final pinY = (normY * 360 + 80).clamp(60.0, 500.0);
                        final pinX = (normX * 280 + 30).clamp(20.0, 320.0);

                        final isSelected = _selectedPet?.id == pet.id;

                        Color pinColor;
                        switch (pet.status) {
                          case YagoPetStatus.lost:
                            pinColor = AppColors.lost;
                            break;
                          case YagoPetStatus.found:
                            pinColor = AppColors.found;
                            break;
                          case YagoPetStatus.reunited:
                            pinColor = AppColors.reunited;
                            break;
                          default:
                            pinColor = AppColors.community;
                        }

                        return Positioned(
                          top: pinY,
                          left: pinX,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPet = pet;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(isSelected ? 6 : 4),
                              decoration: BoxDecoration(
                                color: pinColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: pinColor.withValues(alpha: 0.4),
                                    blurRadius: isSelected ? 12 : 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                pet.species == 'Gato' ? Icons.pets_rounded : Icons.location_on_rounded,
                                size: isSelected ? 24 : 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Leyenda superior flotante
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: AppRadius.mdBorder,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Perdidas', AppColors.lost),
                  _buildLegendItem('Encontradas', AppColors.found),
                  _buildLegendItem('Reunidas', AppColors.reunited),
                ],
              ),
            ),
          ),

          // Tarjeta emergente inferior al tocar un pin
          if (_selectedPet != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.mdBorder,
                      child: _selectedPet!.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              _selectedPet!.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surface,
                                child: const Icon(Icons.pets, color: AppColors.subtle),
                              ),
                            )
                          : Image.network(
                              _selectedPet!.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surface,
                                child: const Icon(Icons.pets, color: AppColors.subtle),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              YagoStatusBadge(status: _selectedPet!.status),
                              GestureDetector(
                                onTap: () => setState(() => _selectedPet = null),
                                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedPet!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${_selectedPet!.breed} · ${_selectedPet!.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PetDetailScreen(pet: _selectedPet!),
                                ),
                              );
                            },
                            child: const Text(
                              'Ver ficha completa →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
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
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final riverPaint = Paint()
      ..color = const Color(0xFFC9E2F8)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke;

    // Río de la Plata simbólico en el borde superior derecho
    final riverPath = Path();
    riverPath.moveTo(size.width * 0.4, 0);
    riverPath.quadraticBezierTo(size.width * 0.7, 80, size.width, 140);
    canvas.drawPath(riverPath, riverPaint);

    // Calles y avenidas simbólicas
    final path = Path();
    // Avenidas horizontales
    path.moveTo(0, 160);
    path.lineTo(size.width, 160);
    path.moveTo(0, 260);
    path.lineTo(size.width, 260);
    path.moveTo(0, 360);
    path.lineTo(size.width, 360);

    // Avenidas verticales y diagonales
    path.moveTo(80, 0);
    path.lineTo(80, size.height);
    path.moveTo(180, 0);
    path.lineTo(180, size.height);
    path.moveTo(280, 0);
    path.lineTo(280, size.height);

    // Diagonal Av. Santa Fe / Cabildo
    path.moveTo(0, 100);
    path.lineTo(size.width, 420);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
