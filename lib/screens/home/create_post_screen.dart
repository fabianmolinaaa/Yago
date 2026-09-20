import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/feed_post.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

/// Pantalla de acceso rápido para crear publicaciones en el feed:
/// - Momentos cotidianos o fotos con tu mascota (sin categoría obligatoria)
/// - Alertas de pérdida de mascotas (HU-S2-03)
/// - Reportes de mascotas encontradas (HU-S2-04)
/// - Consejos de cuidado o relatos de reencuentro
/// (Nota: La etiqueta 'Comunidad' está reservada para avisos del equipo/moderadores de Yago).
class CreatePostScreen extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const CreatePostScreen({super.key, this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImageFile;
  bool _isPublishing = false;

  // Tipo de publicación opcional (null = momento libre con tu mascota)
  String? _selectedCategory;
  String _selectedGender = 'Macho';

  final List<String> _categories = [
    'Perdida',
    'Encontrada',
    'Apareamiento',
    'Consejo',
    'Reencuentro',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _petNameController.dispose();
    _breedController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Color _getCategoryActiveColor(String? category) {
    switch (category) {
      case 'Perdida':
        return AppColors.lost;
      case 'Encontrada':
        return AppColors.found;
      case 'Apareamiento':
        return AppColors.mating;
      case 'Reencuentro':
        return AppColors.reunited;
      case 'Consejo':
        return AppColors.community;
      default:
        return AppColors.primary;
    }
  }

  Color _getCategoryInactiveBg(String? category) {
    switch (category) {
      case 'Perdida':
        return AppColors.lostBg;
      case 'Encontrada':
        return AppColors.foundBg;
      case 'Apareamiento':
        return AppColors.matingBg;
      case 'Reencuentro':
        return AppColors.reunitedBg;
      case 'Consejo':
        return AppColors.communityBg;
      default:
        return AppColors.surfaceSecondary;
    }
  }

  Color _getCategoryInactiveTextColor(String? category) {
    switch (category) {
      case 'Perdida':
        return AppColors.lostText;
      case 'Encontrada':
        return AppColors.foundText;
      case 'Apareamiento':
        return AppColors.matingText;
      case 'Reencuentro':
        return AppColors.reunitedText;
      case 'Consejo':
        return AppColors.communityText;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildGenderPill(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : const Color(0xFFEFF3F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          gender,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await StorageService().pickImage(source: source);
      if (file != null) {
        setState(() {
          _selectedImageFile = file;
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
                  'Fotografía de la publicación',
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
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
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
                  subtitle: const Text('Selecciona una imagen de tu dispositivo'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _publishPost() async {
    final isPetAlert = _selectedCategory == 'Perdida' || _selectedCategory == 'Encontrada';
    final isMating = _selectedCategory == 'Apareamiento';
    final isPetEntity = isPetAlert || isMating;
    final content = _contentController.text.trim();
    final petName = _petNameController.text.trim();
    final breed = _breedController.text.trim();
    final location = _locationController.text.trim();
    final phone = _phoneController.text.trim();

    if (isPetEntity) {
      if (content.isEmpty && petName.isEmpty && _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMating
                  ? 'Por favor completa los datos de la mascota para publicar la búsqueda de pareja.'
                  : 'Por favor completa los datos de la mascota para publicar el reporte.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else {
      if (content.isEmpty && _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escribe una descripción o adjunta una fotografía para publicar.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isPublishing = true);

    String? uploadedImageUrl;

    // Subida a Firebase Cloud Storage
    if (_selectedImageFile != null) {
      try {
        uploadedImageUrl = await StorageService().uploadImage(
          file: _selectedImageFile!,
          folder: isMating
              ? 'mating_posts'
              : (isPetAlert ? 'reports' : 'community_posts'),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isPublishing = false);
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
    final authorName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : 'Comunidad Yago';
    final authorAvatar = currentUser?.photoURL;

    if (isPetEntity) {
      final isLost = _selectedCategory == 'Perdida';
      final defaultName = isMating
          ? 'Mascota'
          : (isLost ? 'Mascota sin nombre' : 'Mascota encontrada');
      final finalName = petName.isNotEmpty ? petName : defaultName;
      final finalBreed = isMating && breed.isNotEmpty ? breed : 'Mestizo';
      final finalGender = isMating ? _selectedGender : 'Sin especificar';
      final finalLocation = location.isNotEmpty ? location : 'CABA';
      final finalPhone = phone.isNotEmpty ? phone : '+54 9 11 0000-0000';
      final finalDesc = content.isNotEmpty
          ? content
          : (isMating
              ? 'Búsqueda de pareja para cruza responsable. Contactar por mensaje directo.'
              : (isLost
                  ? 'Se extravió recientemente. Si la ves, por favor avisa de inmediato.'
                  : 'Encontrada en la vía pública. Se busca a sus dueños o familia responsable.'));

      final YagoPetStatus status = isMating
          ? YagoPetStatus.mating
          : (isLost ? YagoPetStatus.lost : YagoPetStatus.found);

      final List<String> tags = isMating
          ? ['Apareamiento', 'Busca pareja', _selectedGender]
          : (isLost ? ['Urgente', 'Se busca'] : ['Encontrada', 'Avistamiento']);

      final newPet = Pet(
        id: 'pet-${DateTime.now().millisecondsSinceEpoch}',
        ownerId: currentUser?.uid,
        name: finalName,
        breed: finalBreed,
        species: 'Perro',
        gender: finalGender,
        age: 'Adulto',
        status: status,
        location: finalLocation,
        timeAgo: 'Recién publicado',
        date: DateTime.now(),
        description: finalDesc,
        imageUrl: uploadedImageUrl ??
            (isMating
                ? 'assets/images/IMG_5370.JPG'
                : 'assets/images/IMG_3508.JPG'),
        tags: tags,
        contactName: authorName,
        contactPhone: finalPhone,
        latitude: -34.5900,
        longitude: -58.4200,
        isUserOwner: true,
      );

      MockDataService().addPet(newPet);
    } else {
      // Si seleccionó Consejo o Reencuentro, añade la etiqueta; si es libre, guarda el contenido limpio
      final formattedContent = _selectedCategory != null
          ? '[$_selectedCategory] $content'
          : content;

      final newPost = FeedPost(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
        authorId: currentUser?.uid,
        authorName: authorName,
        authorAvatar: authorAvatar,
        timeAgo: 'Recién publicado',
        content: formattedContent,
        imageUrl: uploadedImageUrl,
        likesCount: 0,
        commentsCount: 0,
        isLiked: false,
      );

      MockDataService().addCommunityPost(newPost);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMating
              ? '¡Publicación de búsqueda de pareja creada con éxito!'
              : (isPetAlert
                  ? (_selectedCategory == 'Perdida'
                      ? '¡Alerta de mascota perdida publicada con éxito!'
                      : '¡Reporte de mascota encontrada publicado con éxito!')
                  : '¡Publicación compartida con éxito en el feed!'),
        ),
        backgroundColor: isMating
            ? AppColors.mating
            : (isPetAlert
                ? (_selectedCategory == 'Perdida'
                    ? AppColors.lost
                    : AppColors.found)
                : AppColors.primary),
      ),
    );

    if (widget.onPostCreated != null) {
      widget.onPostCreated!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final authorName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : 'Usuario Yago';
    final isPetAlert = _selectedCategory == 'Perdida' || _selectedCategory == 'Encontrada';
    final isMating = _selectedCategory == 'Apareamiento';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear Publicación'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: SizedBox(
                height: 36,
                child: YagoButton(
                  text: 'Publicar',
                  size: YagoButtonSize.small,
                  isLoading: _isPublishing,
                  onPressed: _isPublishing ? null : _publishPost,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de autor y tipo de publicación
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _getCategoryActiveColor(_selectedCategory).withValues(alpha: 0.15),
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? Icon(
                          (isPetAlert || isMating) ? Icons.pets_rounded : Icons.person_rounded,
                          color: _getCategoryActiveColor(_selectedCategory),
                          size: 22,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryInactiveBg(_selectedCategory),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedCategory == 'Perdida'
                            ? 'Alerta de pérdida urgente'
                            : (_selectedCategory == 'Encontrada'
                                ? 'Reporte de mascota encontrada'
                                : (_selectedCategory == 'Apareamiento'
                                    ? 'Búsqueda de pareja / Apareamiento'
                                    : (_selectedCategory == 'Reencuentro'
                                        ? 'Historia de reencuentro'
                                        : (_selectedCategory == 'Consejo'
                                            ? 'Consejo para la comunidad'
                                            : 'Momento con mi mascota')))),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryInactiveTextColor(_selectedCategory),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Selector de tipo de publicación (opcional)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tipo de publicación (Opcional):',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_selectedCategory != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedCategory = null),
                    child: const Text(
                      'Quitar etiqueta',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final activeColor = _getCategoryActiveColor(cat);
                final inactiveBg = _getCategoryInactiveBg(cat);
                final inactiveTextColor = _getCategoryInactiveTextColor(cat);

                return ChoiceChip(
                  label: Text(
                    cat == 'Perdida'
                        ? '🚨 Perdida'
                        : (cat == 'Encontrada'
                            ? '🐾 Encontrada'
                            : (cat == 'Apareamiento'
                                ? '💕 Apareamiento'
                                : (cat == 'Reencuentro'
                                    ? '❤️ Reencuentro'
                                    : '💡 Consejo'))),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      // Al tocar un chip activo se deselecciona
                      _selectedCategory = selected ? cat : null;
                    });
                  },
                  selectedColor: activeColor,
                  backgroundColor: inactiveBg,
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : inactiveTextColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? activeColor : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Campos contextuales para alertas de mascotas (Perdida / Encontrada)
            if (isPetAlert) ...[
              Row(
                children: [
                  Expanded(
                    child: YagoTextField(
                      label: _selectedCategory == 'Perdida'
                          ? 'Nombre de la mascota'
                          : 'Nombre conocido o apodo',
                      hint: _selectedCategory == 'Perdida' ? 'Ej: Milo, Luna' : 'Ej: Sin nombre / "Negrito"',
                      controller: _petNameController,
                      prefixIcon: const Icon(Icons.pets_rounded, size: 18, color: AppColors.subtle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: YagoTextField(
                      label: 'Zona / Barrio',
                      hint: 'Ej: Palermo, CABA',
                      controller: _locationController,
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.subtle),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              YagoTextField(
                label: 'Teléfono de contacto (Opcional)',
                hint: 'Ej: +54 9 11 5566-7788',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.subtle),
              ),
              const SizedBox(height: 14),
            ],

            // Campos contextuales para Búsqueda de Pareja (Apareamiento)
            if (isMating) ...[
              Row(
                children: [
                  Expanded(
                    child: YagoTextField(
                      label: 'Nombre de la mascota',
                      hint: 'Ej: Simba, Bella',
                      controller: _petNameController,
                      prefixIcon: const Icon(Icons.pets_rounded, size: 18, color: AppColors.subtle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: YagoTextField(
                      label: 'Raza',
                      hint: 'Ej: Golden Retriever',
                      controller: _breedController,
                      prefixIcon: const Icon(Icons.pets_outlined, size: 18, color: AppColors.subtle),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: YagoTextField(
                      label: 'Zona / Barrio',
                      hint: 'Ej: Belgrano, CABA',
                      controller: _locationController,
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.subtle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: YagoTextField(
                      label: 'Teléfono (Opcional)',
                      hint: 'Ej: +54 9 11 3456-7890',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.subtle),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selector de sexo minimalista y elegante sin color
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sexo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildGenderPill('Macho'),
                      const SizedBox(width: 8),
                      _buildGenderPill('Hembra'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Campo de texto principal con label solicitado
            const Text(
              'Descripción de la publicación',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: isPetAlert ? 4 : 5,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: isPetAlert
                    ? (_selectedCategory == 'Perdida'
                        ? 'Describe señas particulares, collar, cómo ocurrió la pérdida o cualquier dato útil...'
                        : 'Describe el estado de la mascota, señas particulares o dónde está retenida...')
                    : (_selectedCategory == 'Apareamiento'
                        ? 'Describe temperamento, vacunas, certificado de salud, pedigrí o qué buscas en su pareja...'
                        : (_selectedCategory == 'Consejo'
                            ? 'Comparte un consejo de salud, adiestramiento o cuidado animal...'
                            : (_selectedCategory == 'Reencuentro'
                                ? 'Comparte la historia del final feliz de tu mascota reunida...'
                                : 'Comparte una foto o lo que quieras sobre tu mascota...'))),
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.subtle,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: BorderSide(
                    color: _getCategoryActiveColor(_selectedCategory),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Previsualización de foto o botón para adjuntar
            if (_selectedImageFile != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.lgBorder,
                    child: Image.file(
                      _selectedImageFile!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImageFile = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Se subirá a Firebase Storage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              GestureDetector(
                onTap: _showImageSourceModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.lgBorder,
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryActiveColor(_selectedCategory).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 28,
                          color: _getCategoryActiveColor(_selectedCategory),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (isPetAlert || isMating)
                            ? 'Fotografía de la mascota (Muy recomendada)'
                            : 'Adjuntar fotografía a la publicación',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca para capturar con la cámara o abrir tu galería',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
