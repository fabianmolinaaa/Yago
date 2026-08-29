import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/stand.dart';
import '../../utils/app_colors.dart';

class StandListTab extends StatefulWidget {
  final Event event;

  const StandListTab({
    super.key,
    required this.event,
  });

  @override
  State<StandListTab> createState() => _StandListTabState();
}

class _StandListTabState extends State<StandListTab> {
  StandStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final stands = widget.event.stands.where((s) {
      if (_filterStatus == null) return true;
      return s.status == _filterStatus;
    }).toList();

    return Column(
      children: [
        // Chips de filtro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              FilterChip(
                label: Text('Todos (${widget.event.stands.length})'),
                selected: _filterStatus == null,
                onSelected: (_) => setState(() => _filterStatus = null),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Libres (${widget.event.availableStandsCount})'),
                selected: _filterStatus == StandStatus.available,
                onSelected: (_) =>
                    setState(() => _filterStatus = StandStatus.available),
                selectedColor: AppColors.standAvailableBg,
                checkmarkColor: AppColors.standAvailable,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Ocupados (${widget.event.occupiedStandsCount})'),
                selected: _filterStatus == StandStatus.occupied,
                onSelected: (_) =>
                    setState(() => _filterStatus = StandStatus.occupied),
                selectedColor: AppColors.standOccupiedBg,
                checkmarkColor: AppColors.standOccupied,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // Lista de stands
        Expanded(
          child: stands.isEmpty
              ? const Center(
                  child: Text(
                    'No hay stands con este filtro',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: stands.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final stand = stands[index];
                    final isAvailable = stand.status == StandStatus.available;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColors.standAvailableBg
                                : AppColors.standOccupiedBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isAvailable
                                  ? AppColors.standAvailable
                                  : AppColors.standOccupied,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            stand.number,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? AppColors.standAvailable
                                  : AppColors.standOccupied,
                            ),
                          ),
                        ),
                        title: Text(
                          stand.exhibitorName ?? 'Sin asignar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: stand.exhibitorName != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                        subtitle: Text(
                          'Posición: (${stand.x.toInt()}, ${stand.y.toInt()})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColors.standAvailableBg
                                : AppColors.standOccupiedBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAvailable ? 'Libre' : 'Ocupado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? AppColors.standAvailable
                                  : AppColors.standOccupied,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
