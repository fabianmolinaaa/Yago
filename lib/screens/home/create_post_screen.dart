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

/// Pantalla de acceso rápido para crear publicaciones de todo tipo:
/// - Alertas urgentes de pérdida de mascotas (HU-S2-03)
/// - Reportes de mascotas encontradas (HU-S2-04)
/// - Consejos de cuidado y relatos de reencuentro (HU-S1-02)
/// - Avisos comunitarios
class CreatePostScreen extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const CreatePostScreen({super.key, this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImageFile;
  bool _isPublishing = false;

  // Categoría activa por defecto: 'Perdida' como acceso rápido de reporte
  String _selectedCategory = 'Perdida';
  final List<String> _categories = [
    'Perdida',
    'Encontrada',
    'Consejo',
    'Reencuentro',
    'Comunidad',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _petNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Color _getCategoryActiveColor(String category) {
    switch (category) {
      case 'Perdida':
        return AppColors.lost;
      case 'Encontrada':
        return AppColors.found;
      case 'Reencuentro':
        return AppColors.reunited;
      case 'Consejo':
        return AppColors.community;
      case 'Comunidad':
      default:
        return AppColors.primary;
    }
  }

  Color _getCategoryInactiveBg(String category) {
    switch (category) {
      case 'Perdida':
        return AppColors.lostBg;
      case 'Encontrada':
        return AppColors.foundBg;
      case 'Reencuentro':
        return AppColors.reunitedBg;
      case 'Consejo':
        return AppColors.communityBg;
      case 'Comunidad':
      default:
        return AppColors.surfaceSecondary;
    }
  }

  Color _getCategoryInactiveTextColor(String category) {
    switch (category) {
      case 'Perdida':
        return AppColors.lostText;
      case 'Encontrada':
        return AppColors.foundText;
      case 'Reencuentro':
        return AppColors.reunitedText;
      case 'Consejo':
        return AppColors.communityText;
      case 'Comunidad':
      default:
        return AppColors.textSecondary;
    }
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
    final content = _contentController.text.trim();
    final petName = _petNameController.text.trim();
    final location = _locationController.text.trim();
    final phone = _phoneController.text.trim();

    if (isPetAlert) {
      if (content.isEmpty && petName.isEmpty && _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor completa los datos de la mascota para publicar el reporte.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else {
      if (content.isEmpty && _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escribe un mensaje o adjunta una fotografía para publicar.'),
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
          folder: isPetAlert ? 'reports' : 'community_posts',
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

    if (isPetAlert) {
      final isLost = _selectedCategory == 'Perdida';
      final finalName = petName.isNotEmpty
          ? petName
          : (isLost ? 'Mascota sin nombre' : 'Mascota encontrada');
      final finalLocation = location.isNotEmpty ? location : 'CABA';
      final finalPhone = phone.isNotEmpty ? phone : '+54 9 11 0000-0000';
      final finalDesc = content.isNotEmpty
          ? content
          : (isLost
              ? 'Se extravió recientemente. Si la ves, por favor avisa de inmediato.'
              : 'Encontrada en la vía pública. Se busca a sus dueños o familia responsable.');

      final newPet = Pet(
        id: 'pet-${DateTime.now().millisecondsSinceEpoch}',
        name: finalName,
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Sin especificar',
        age: 'Adulto',
        status: isLost ? YagoPetStatus.lost : YagoPetStatus.found,
        location: finalLocation,
        timeAgo: 'Recién publicado',
        date: DateTime.now(),
        description: finalDesc,
        imageUrl: uploadedImageUrl ?? 'assets/images/IMG_3508.JPG',
        tags: isLost ? ['Urgente', 'Se busca'] : ['Encontrada', 'Avistamiento'],
        contactName: authorName,
        contactPhone: finalPhone,
        latitude: -34.5900,
        longitude: -58.4200,
        isUserOwner: true,
      );

      MockDataService().addPet(newPet);
    } else {
      final formattedContent = '[$_selectedCategory] $content';
      final newPost = FeedPost(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
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
          isPetAlert
              ? (_selectedCategory == 'Perdida'
                  ? '¡Alerta de mascota perdida publicada con éxito!'
                  : '¡Reporte de mascota encontrada publicado con éxito!')
              : '¡Publicación compartida con éxito en el feed comunitario!',
        ),
        backgroundColor: isPetAlert
            ? (_selectedCategory == 'Perdida' ? AppColors.lost : AppColors.found)
            : AppColors.found,
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
                          isPetAlert ? Icons.pets_rounded : Icons.person_rounded,
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
                                : (_selectedCategory == 'Reencuentro'
                                    ? 'Historia de reencuentro'
                                    : 'Publicación comunitaria')),
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

            // Selector de categoría temática
            const Text(
              'Tipo de publicación:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
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
                            : (cat == 'Reencuentro'
                                ? '❤️ Reencuentro'
                                : (cat == 'Consejo'
                                    ? '💡 Consejo'
                                    : '💬 Comunidad'))),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
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

            // Campo de texto principal
            Text(
              isPetAlert ? 'Descripción y detalles:' : 'Mensaje o relato:',
              style: const TextStyle(
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
                    : (_selectedCategory == 'Consejo'
                        ? 'Comparte un consejo de salud, adiestramiento o cuidado animal...'
                        : (_selectedCategory == 'Reencuentro'
                            ? 'Comparte la historia del final feliz de tu mascota reunida...'
                            : 'Comparte un aviso, consulta o vivencia con la comunidad...')),
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
                        isPetAlert
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
