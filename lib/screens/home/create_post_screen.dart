import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/feed_post.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

/// Pantalla para crear y compartir publicaciones comunitarias (HU-S1-02)
/// Permite redactar anécdotas, consejos o vivencias y adjuntar fotos reales a Cloud Storage.
class CreatePostScreen extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const CreatePostScreen({super.key, this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImageFile;
  bool _isPublishing = false;

  String _selectedCategory = 'Consejo';
  final List<String> _categories = [
    'Consejo',
    'Reencuentro',
    'Anécdota',
    'Comunidad',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
                  'Adjuntar fotografía',
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
                  subtitle: const Text('Comparte una foto capturada al instante'),
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
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un mensaje o adjunta una fotografía para publicar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    String? uploadedImageUrl;

    // Subida a Firebase Cloud Storage si adjuntó una foto
    if (_selectedImageFile != null) {
      try {
        uploadedImageUrl = await StorageService().uploadImage(
          file: _selectedImageFile!,
          folder: 'community_posts',
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

    // Formatear contenido con la categoría seleccionada
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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Publicación compartida con éxito en el feed comunitario!'),
        backgroundColor: AppColors.found,
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
                  backgroundColor: AppColors.community.withValues(alpha: 0.15),
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? const Icon(Icons.person_rounded, color: AppColors.community, size: 24)
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
                        color: AppColors.communityBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Publicación comunitaria',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.communityText,
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
              'Categoría:',
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
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceSecondary,
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Campo de texto principal para el contenido
            TextField(
              controller: _contentController,
              maxLines: 6,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Comparte un relato de reencuentro, un consejo de cuidado o vivencia con la comunidad...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Adjuntar fotografía a la publicación',
                        style: TextStyle(
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
