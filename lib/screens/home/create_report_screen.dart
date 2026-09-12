import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

class CreateReportScreen extends StatefulWidget {
  final VoidCallback? onReportCreated;

  const CreateReportScreen({super.key, this.onReportCreated});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  // Tipo de reporte: true = Perdida, false = Encontrada
  bool _isLostReport = true;

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _tagInputController = TextEditingController();

  String _selectedSpecies = 'Perro';
  String _selectedGender = 'Macho';
  final String _selectedAge = 'Adulto';

  final List<String> _tags = [];
  bool _isSubmitting = false;

  // Foto de muestra seleccionada por defecto
  String _selectedImageUrl = 'assets/images/IMG_3508.JPG';

  final List<String> _sampleImages = [
    'assets/images/IMG_3508.JPG',
    'assets/images/IMG_4178.JPG',
    'assets/images/IMG_2935.JPG',
    'assets/images/IMG_5370.JPG',
    'assets/images/IMG_5560.JPG',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactPhoneController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _submitReport() {
    final name = _nameController.text.trim().isEmpty
        ? (_isLostReport ? 'Mascota sin nombre' : 'Mascota encontrada')
        : _nameController.text.trim();
    final breed = _breedController.text.trim().isEmpty ? 'Mestizo' : _breedController.text.trim();
    final location = _locationController.text.trim().isEmpty ? 'CABA' : _locationController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? (_isLostReport
            ? 'Se extravió recientemente. Por favor si alguien la ve, contactarse de inmediato.'
            : 'Encontrada en la vía pública. Se busca a sus dueños o familia responsable.')
        : _descriptionController.text.trim();
    final phone = _contactPhoneController.text.trim().isEmpty
        ? '+54 9 11 0000-0000'
        : _contactPhoneController.text.trim();

    setState(() => _isSubmitting = true);

    final currentUser = AuthService().currentUser;
    final contactName = currentUser?.displayName ?? 'Usuario Yago';

    final newPet = Pet(
      id: 'pet-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      breed: breed,
      species: _selectedSpecies,
      gender: _selectedGender,
      age: _selectedAge,
      status: _isLostReport ? YagoPetStatus.lost : YagoPetStatus.found,
      location: location,
      timeAgo: 'Recién publicado',
      date: DateTime.now(),
      description: description,
      imageUrl: _selectedImageUrl,
      tags: _tags.isEmpty ? ['Se busca ayuda'] : List.from(_tags),
      contactName: contactName,
      contactPhone: phone,
      latitude: -34.5900,
      longitude: -58.4200,
      isUserOwner: true,
    );

    MockDataService().addPet(newPet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLostReport
              ? '¡Reporte de búsqueda publicado con éxito!'
              : '¡Reporte de mascota encontrada publicado con éxito!',
        ),
        backgroundColor: _isLostReport ? AppColors.lost : AppColors.found,
      ),
    );

    if (widget.onReportCreated != null) {
      widget.onReportCreated!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publicar Reporte'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector: ¿Perdiste o Encontraste?
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLostReport = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isLostReport ? AppColors.lost : Colors.transparent,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: _isLostReport ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Perdí mi mascota',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isLostReport ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLostReport = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isLostReport ? AppColors.found : Colors.transparent,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets_rounded,
                              size: 18,
                              color: !_isLostReport ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Encontré una mascota',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: !_isLostReport ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Selector de foto de la mascota
            const Text(
              'Fotografía de la mascota',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: AppColors.border),
                image: DecorationImage(
                  image: _selectedImageUrl.startsWith('assets/')
                      ? AssetImage(_selectedImageUrl) as ImageProvider
                      : NetworkImage(_selectedImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lgBorder,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.bottomLeft,
                child: const Row(
                  children: [
                    Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Toca abajo para cambiar la foto de muestra',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Miniaturas de fotos
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                itemBuilder: (context, index) {
                  final img = _sampleImages[index];
                  final isSelected = _selectedImageUrl == img;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageUrl = img),
                    child: Container(
                      width: 52,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.smBorder,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2.5 : 1,
                        ),
                        image: DecorationImage(
                          image: img.startsWith('assets/')
                              ? AssetImage(img) as ImageProvider
                              : NetworkImage(img),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Nombre de la mascota
            YagoTextField(
              label: _isLostReport ? 'Nombre de tu mascota' : 'Nombre asignado o conocido',
              hint: _isLostReport ? 'Ej: Milo, Luna...' : 'Ej: Sin nombre / "Negrito"',
              controller: _nameController,
              prefixIcon: const Icon(Icons.pets_rounded, size: 20, color: AppColors.subtle),
            ),
            const SizedBox(height: 16),

            // Especie, Sexo y Edad
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Especie', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSpecies,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                        ),
                        items: ['Perro', 'Gato', 'Otro']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSpecies = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sexo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                        ),
                        items: ['Macho', 'Hembra', 'Desconocido']
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGender = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Raza
            YagoTextField(
              label: 'Raza o apariencia',
              hint: 'Ej: Mestizo, Caniche, Siamés...',
              controller: _breedController,
            ),
            const SizedBox(height: 16),

            // Ubicación del hecho
            YagoTextField(
              label: _isLostReport ? 'Lugar donde se extravió' : 'Lugar donde fue vista o encontrada',
              hint: 'Ej: Palermo, Plaza Armenia / Av. Santa Fe al 3200',
              controller: _locationController,
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.subtle),
            ),
            const SizedBox(height: 16),

            // Teléfono de contacto
            YagoTextField(
              label: 'Teléfono o WhatsApp de contacto',
              hint: '+54 9 11 1234-5678',
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.subtle),
            ),
            const SizedBox(height: 16),

            // Señas particulares / tags
            const Text(
              'Señas particulares (chips, collar, manchas)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: YagoTextField(
                    label: '',
                    hint: 'Ej: Collar rojo, Con chip...',
                    controller: _tagInputController,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: _addTag,
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.surface,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // Descripción detallada
            YagoTextField(
              label: 'Descripción de lo sucedido',
              hint: 'Cuéntanos cómo ocurrió, cómo reacciona con desconocidos o cualquier dato útil...',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 28),

            // Botón de publicación
            YagoButton(
              text: _isLostReport ? 'Publicar búsqueda urgente' : 'Publicar mascota encontrada',
              size: YagoButtonSize.large,
              isFullWidth: true,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitReport,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
