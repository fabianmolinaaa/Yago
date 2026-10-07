import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
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
  String _selectedAge = 'Adulto (3-6 años)';
  DateTime _reportDate = DateTime.now();

  double _latitude = -34.5889;
  double _longitude = -58.4233;
  bool _isDetectingLocation = false;

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

  final List<String> _ageOptions = [
    'Cachorro (< 1 año)',
    'Joven (1-2 años)',
    'Adulto (3-6 años)',
    'Senior (7+ años)',
    'Desconocida',
  ];

  final List<String> _suggestedTags = [
    'Collar rojo',
    'Con chip',
    'Mancha blanca',
    'Orejas caídas',
    'Pelaje largo',
    'Manso',
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

  void _addSuggestedTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      final result = await LocationService().getCurrentLocation();
      if (!mounted) return;

      if (result != null) {
        setState(() {
          _locationController.text = result.locationName;
          _latitude = result.latitude;
          _longitude = result.longitude;
          _isDetectingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Ubicación detectada: ${result.locationName}'),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isDetectingLocation = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDetectingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo detectar la ubicación automáticamente.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectReportDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _isLostReport ? AppColors.lost : AppColors.found,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reportDate = picked;
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
                  'Foto de la mascota',
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
        ? 'Sin nombre'
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
      date: _reportDate,
      description: description,
      imageUrl: finalImageUrl,
      tags: _tags.isEmpty ? ['Se busca ayuda'] : List.from(_tags),
      contactName: contactName,
      contactPhone: phone,
      latitude: _latitude,
      longitude: _longitude,
      isUserOwner: true,
    );

    try {
      await MockDataService().addPet(newPet);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el reporte: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

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

    widget.onReportCreated?.call();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(_reportDate, DateTime.now());
    final isYesterday = DateUtils.isSameDay(
      _reportDate,
      DateTime.now().subtract(const Duration(days: 1)),
    );

    String formattedDateText;
    if (isToday) {
      formattedDateText = 'Hoy (${_reportDate.day}/${_reportDate.month})';
    } else if (isYesterday) {
      formattedDateText = 'Ayer (${_reportDate.day}/${_reportDate.month})';
    } else {
      formattedDateText = '${_reportDate.day}/${_reportDate.month}/${_reportDate.year}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publicar reporte'),
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
            // ─── 1. Selector Compacto "Perdí mi mascota" | "Encontré una mascota" ─
            Container(
              height: 46,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLostReport = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isLostReport ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: _isLostReport
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Perdí mi mascota',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: _isLostReport ? FontWeight.w600 : FontWeight.w500,
                            color: _isLostReport ? AppColors.lost : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLostReport = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_isLostReport ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: !_isLostReport
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Encontré una mascota',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: !_isLostReport ? FontWeight.w600 : FontWeight.w500,
                            color: !_isLostReport ? AppColors.found : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── 2. Foto de la Mascota Minimalista ───────────────────────────
            _buildSectionHeader('FOTO DE LA MASCOTA'),
            GestureDetector(
              onTap: _showImageSourceModal,
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _pickedImageFile != null ? AppColors.primary : AppColors.border,
                        width: _pickedImageFile != null ? 1.5 : 1,
                      ),
                      image: DecorationImage(
                        image: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!)
                            : (_selectedImageUrl.startsWith('assets/')
                                ? AssetImage(_selectedImageUrl) as ImageProvider
                                : NetworkImage(_selectedImageUrl)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _showImageSourceModal,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_camera_outlined, size: 15, color: AppColors.primary),
                        SizedBox(width: 5),
                        Text(
                          'Cambiar foto · Elegir de galería',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_pickedImageFile != null)
                  GestureDetector(
                    onTap: () => setState(() => _pickedImageFile = null),
                    child: const Text(
                      'Restablecer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Thumbnails de muestra
            SizedBox(
              height: 48,
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
                      width: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
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
            const SizedBox(height: 28),

            // ─── 3. Información de la Mascota ────────────────────────────────
            _buildSectionHeader('INFORMACIÓN DE LA MASCOTA'),
            YagoTextField(
              label: 'Nombre de la mascota',
              hint: 'Ej: Milo, Luna, "Negrito"...',
              controller: _nameController,
              prefixIcon: const Icon(Icons.pets_rounded, size: 20, color: AppColors.subtle),
            ),
            const SizedBox(height: 14),

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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
            const SizedBox(height: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edad aproximada',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedAge,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.muted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                  ),
                  items: _ageOptions
                      .map((age) => DropdownMenuItem(value: age, child: Text(age)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedAge = val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            YagoTextField(
              label: 'Raza o apariencia',
              hint: 'Ej: Mestizo, Caniche, Golden...',
              controller: _breedController,
            ),
            const SizedBox(height: 28),

            // ─── 4. Dónde y Cuándo ───────────────────────────────────────────
            _buildSectionHeader('DÓNDE Y CUÁNDO'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YagoTextField(
                  label: 'Ubicación',
                  hint: 'Ej: Plaza Armenia, Palermo',
                  controller: _locationController,
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.subtle),
                  suffixIcon: _isDetectingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.primary,
                            size: 21,
                          ),
                          tooltip: 'Usar mi ubicación',
                          onPressed: _detectCurrentLocation,
                        ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _isDetectingLocation ? null : _detectCurrentLocation,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isDetectingLocation ? 'Detectando GPS...' : 'Usar mi ubicación',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _selectReportDate,
                  borderRadius: AppRadius.mdBorder,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_note_rounded,
                          size: 19,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            formattedDateText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ─── 5. Contacto ─────────────────────────────────────────────────
            _buildSectionHeader('CONTACTO'),
            YagoTextField(
              label: 'Teléfono o WhatsApp',
              hint: '+54 9 11 1234-5678',
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.subtle),
            ),
            const SizedBox(height: 28),

            // ─── 6. Señas Particulares ───────────────────────────────────────
            _buildSectionHeader('SEÑAS PARTICULARES'),
            YagoTextField(
              label: 'Señas particulares (chips, collar, manchas)',
              hint: 'Ej: Collar rojo, Con chip, Mancha blanca...',
              controller: _tagInputController,
              prefixIcon: const Icon(Icons.style_outlined, size: 20, color: AppColors.muted),
              onFieldSubmitted: (_) => _addTag(),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(7.0),
                child: InkWell(
                  onTap: _addTag,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Sugerencias:',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ..._suggestedTags.map((st) {
                    final isAdded = _tags.contains(st);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => _addSuggestedTag(st),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isAdded ? AppColors.primaryTint : const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAdded ? AppColors.primary : AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '+ $st',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isAdded ? FontWeight.w700 : FontWeight.w500,
                              color: isAdded ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
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
                    deleteIcon: const Icon(Icons.close_rounded, size: 14),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),

            // ─── 7. Descripción ──────────────────────────────────────────────
            _buildSectionHeader('DESCRIPCIÓN'),
            YagoTextField(
              label: 'Descripción',
              hint: 'Cuéntanos qué ocurrió, cómo reacciona o cualquier dato útil...',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // ─── 8. Pie y Botón Unificado "Publicar reporte" ──────────────────
            const Center(
              child: Text(
                'Al publicar, otras personas podrán ver este reporte y contactarte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 12),

            YagoButton(
              text: 'Publicar reporte',
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
