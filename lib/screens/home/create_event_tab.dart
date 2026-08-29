import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/stand.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_colors.dart';

class CreateEventTab extends StatefulWidget {
  final VoidCallback? onEventCreated;

  const CreateEventTab({super.key, this.onEventCreated});

  @override
  State<CreateEventTab> createState() => _CreateEventTabState();
}

class _CreateEventTabState extends State<CreateEventTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  int _initialStandsCount = 6;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      // Generar stands iniciales con coordenadas (x, y) en cuadrícula
      final generatedStands = <Stand>[];
      const standsPerRow = 3;
      const startX = 30.0;
      const startY = 40.0;
      const spacingX = 100.0;
      const spacingY = 100.0;

      for (int i = 0; i < _initialStandsCount; i++) {
        final row = i ~/ standsPerRow;
        final col = i % standsPerRow;
        final number = (i + 1).toString().padLeft(2, '0');

        generatedStands.add(
          Stand(
            id: 'std-${DateTime.now().millisecondsSinceEpoch}-$i',
            number: number,
            status: StandStatus.available,
            x: startX + (col * spacingX),
            y: startY + (row * spacingY),
          ),
        );
      }

      final newEvent = Event(
        id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? 'Evento organizado en StandMap.'
            : _descriptionController.text.trim(),
        stands: generatedStands,
      );

      MockDataService().addEvent(newEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evento "${newEvent.name}" creado con éxito'),
          backgroundColor: AppColors.standAvailable,
        ),
      );

      _nameController.clear();
      _locationController.clear();
      _descriptionController.clear();

      widget.onEventCreated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo Evento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Define la información general y la cantidad inicial de stands.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Nombre
            const Text(
              'Nombre del evento *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ej: Expo Agro 2026',
                prefixIcon: Icon(Icons.event, size: 20, color: AppColors.textMuted),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 18),

            // Lugar
            const Text(
              'Ubicación / Recinto *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Ej: Pabellón Azul, Predio Ferial',
                prefixIcon:
                    Icon(Icons.location_on, size: 20, color: AppColors.textMuted),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Ingresa una ubicación' : null,
            ),
            const SizedBox(height: 18),

            // Fecha
            const Text(
              'Fecha del evento',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 20, color: AppColors.textMuted),
                    const SizedBox(width: 12),
                    Text(
                      dateFormatted,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Cambiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Stands iniciales
            const Text(
              'Cantidad de stands iniciales',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded,
                      size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Text(
                    '$_initialStandsCount stands',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.primaryLight),
                    onPressed: _initialStandsCount > 1
                        ? () => setState(() => _initialStandsCount--)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.primaryLight),
                    onPressed: _initialStandsCount < 20
                        ? () => setState(() => _initialStandsCount++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Descripción
            const Text(
              'Descripción o notas adicionales',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Detalles sobre temáticas, sectores o indicaciones...',
              ),
            ),
            const SizedBox(height: 28),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveEvent,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Crear y Guardar Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
