import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
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

  // Foto de la mascota: archivo local seleccionado o muestra
  File? _pickedImageFile;
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

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final file = await StorageService().pickImage(source: source);
      if (file != null) {
        setState(() {
          _pickedImageFile = file;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Fotografía de la mascota',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Tomar foto con la cámara', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Captura una imagen al instante'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.found.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.found),
                  ),
                  title: const Text('Elegir de la galería', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Selecciona una foto de tu dispositivo'),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                if (_pickedImageFile != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    ),
                    title: const Text('Quitar foto seleccionada', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _pickedImageFile = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReport() async {
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

    String finalImageUrl = _selectedImageUrl;

    // Si el usuario seleccionó una foto propia, la subimos a Firebase Storage
    if (_pickedImageFile != null) {
      try {
        finalImageUrl = await StorageService().uploadImage(
          file: _pickedImageFile!,
          folder: 'reports',
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo subir la foto a Firebase Storage: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final currentUser = AuthService().currentUser;
    final contactName = currentUser?.displayName ?? 'Usuario Yago';

    final newPet = Pet(
      id: 'pet-${DateTime.now().millisecondsSinceEpoch}',
      ownerId: currentUser?.uid,
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
      imageUrl: finalImageUrl,
      tags: _tags.isEmpty ? ['Se busca ayuda'] : List.from(_tags),
      contactName: contactName,
      contactPhone: phone,
      latitude: -34.5900,
      longitude: -58.4200,
      isUserOwner: true,
    );

    MockDataService().addPet(newPet);

    if (!mounted) return;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fotografía de la mascota',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (_pickedImageFile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.found.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 12, color: AppColors.found),
                        SizedBox(width: 4),
                        Text(
                          'Foto propia cargada',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.found,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Contenedor principal de la foto interactivo
            GestureDetector(
              onTap: _showImageSourceModal,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(
                    color: _pickedImageFile != null ? AppColors.primary : AppColors.border,
                    width: _pickedImageFile != null ? 2 : 1,
                  ),
                  image: _pickedImageFile != null
                      ? DecorationImage(
                          image: FileImage(_pickedImageFile!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
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
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _pickedImageFile != null
                                ? 'Toca para cambiar de foto'
                                : 'Toca para tomar foto o abrir galería',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Miniaturas de fotos de muestra alternativas
            Row(
              children: [
                const Text(
                  'O usa una foto de muestra:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_pickedImageFile != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _pickedImageFile = null),
                    child: const Text(
                      'Restablecer',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                itemBuilder: (context, index) {
                  final img = _sampleImages[index];
                  final isSelected = _pickedImageFile == null && _selectedImageUrl == img;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _pickedImageFile = null;
                      _selectedImageUrl = img;
                    }),
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
