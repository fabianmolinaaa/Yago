import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/stand.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/stand_map_view.dart';

class StandMapTab extends StatefulWidget {
  final Event event;
  final VoidCallback onStandUpdated;

  const StandMapTab({
    super.key,
    required this.event,
    required this.onStandUpdated,
  });

  @override
  State<StandMapTab> createState() => _StandMapTabState();
}

class _StandMapTabState extends State<StandMapTab> {
  void _showStandDetails(Stand stand) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isAvailable = stand.status == StandStatus.available;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stand ${stand.number}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.standAvailableBg
                          : AppColors.standOccupiedBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAvailable
                            ? AppColors.standAvailable
                            : AppColors.standOccupied,
                      ),
                    ),
                    child: Text(
                      isAvailable ? 'Disponible' : 'Ocupado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAvailable
                            ? AppColors.standAvailable
                            : AppColors.standOccupied,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),

              // Coordenadas
              Row(
                children: [
                  const Icon(Icons.pin_drop_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Posición en plano: X: ${stand.x.toInt()}px, Y: ${stand.y.toInt()}px',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Expositor
              Row(
                children: [
                  const Icon(Icons.business_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stand.exhibitorName != null
                          ? 'Expositor: ${stand.exhibitorName}'
                          : 'Sin expositor asignado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: stand.exhibitorName != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: stand.exhibitorName != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón de alternar estado
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newStatus = isAvailable
                        ? StandStatus.occupied
                        : StandStatus.available;
                    final updatedStand = stand.copyWith(
                      status: newStatus,
                      exhibitorName: isAvailable ? 'Expositor Asignado' : null,
                    );
                    MockDataService().updateStand(widget.event.id, updatedStand);
                    Navigator.of(ctx).pop();
                    widget.onStandUpdated();
                  },
                  icon: Icon(
                    isAvailable ? Icons.check_circle : Icons.remove_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    isAvailable ? 'Marcar como Ocupado' : 'Liberar Stand',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable
                        ? AppColors.standOccupied
                        : AppColors.standAvailable,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StandMapView(
      stands: widget.event.stands,
      onStandTap: _showStandDetails,
    );
  }
}
