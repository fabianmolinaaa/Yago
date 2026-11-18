import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/feed_post.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

/// Pantalla de creación de publicaciones para el feed comunitario de Yago.
///
/// Diseño minimalista inspirado en redes sociales modernas:
/// - Línea divisoria horizontal debajo de la barra superior "Crear Publicación" (sin bloque de usuario).
/// - Área de descripción limpia y directa ("Agrega una descripción...").
/// - Botones de acción tipo fila con chevron (`>`):
///   1. `Agregar Fotos >` (con previsualización de tarjetas redondeadas debajo al estilo referencia).
///   2. `Agregar Etiqueta >` (`Consejo`, `Reencuentro`, `Apareamiento`, `Aviso`, `Salud`),
///      excluyendo `Perdida` y `Encontrada` (exclusivos del módulo Crear Reporte).
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

  final List<File> _selectedImageFiles = [];
  bool _isPublishing = false;

  // Etiqueta opcional seleccionada ('Consejo', 'Reencuentro', 'Apareamiento', 'Aviso', 'Salud')
  String? _selectedCategory;
  String _selectedSpecies = 'Perro';
  String _selectedGender = 'Macho';

  String? _locationError;
  String? _phoneError;

  static const List<String> _categories = [
    'Consejo',
    'Reencuentro',
    'Apareamiento',
    'Aviso',
    'Salud',
  ];

  static const List<String> _speciesOptions = [
    'Perro',
    'Gato',
    'Otro',
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
      case 'Apareamiento':
        return AppColors.mating;
      case 'Reencuentro':
        return AppColors.reunited;
      case 'Consejo':
        return AppColors.community;
      case 'Salud':
        return const Color(0xFF0369A1);
      case 'Aviso':
        return const Color(0xFFB45309);
      default:
        return AppColors.primary;
    }
  }

  Color _getCategoryInactiveBg(String? category) {
    switch (category) {
      case 'Apareamiento':
        return AppColors.matingBg;
      case 'Reencuentro':
        return AppColors.reunitedBg;
      case 'Consejo':
        return AppColors.communityBg;
      case 'Salud':
        return const Color(0xFFE0F2FE);
      case 'Aviso':
        return const Color(0xFFFEF3C7);
      default:
        return AppColors.surfaceSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Consejo':
        return Icons.lightbulb_outline_rounded;
      case 'Reencuentro':
        return Icons.favorite_rounded;
      case 'Apareamiento':
        return Icons.pets_rounded;
      case 'Aviso':
        return Icons.campaign_rounded;
      case 'Salud':
        return Icons.medical_services_outlined;
      default:
        return Icons.local_offer_outlined;
    }
  }

  String _getCategorySubtitle(String category) {
    switch (category) {
      case 'Consejo':
        return 'Recomendaciones útiles de cuidado y bienestar animal';
      case 'Reencuentro':
        return 'Historias de final feliz de mascotas que volvieron a casa';
      case 'Apareamiento':
        return 'Búsqueda de pareja / cruza responsable con datos de la mascota';
      case 'Aviso':
        return 'Comunicados barriales, eventos o novedades para la comunidad';
      case 'Salud':
        return 'Jornadas de castración, vacunación, guardias o campañas sanitarias';
      default:
        return '';
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

  Widget _buildSpeciesPill(String species) {
    final isSelected = _selectedSpecies == species;
    return GestureDetector(
      onTap: () => setState(() => _selectedSpecies = species),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFEFF3F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          species,
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
      final file = await StorageService().pickImage(
        source: source,
        preset: ImageCompressionPreset.postAndReport,
      );
      if (file != null && mounted) {
        setState(() {
          _selectedImageFiles.add(file);
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
                  'Agregar Fotos',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Tomar foto con la cámara',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Capturar una imagen en este momento'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.community.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.community,
                    ),
                  ),
                  title: const Text(
                    'Seleccionar de la galería',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Elegir una foto guardada en tu teléfono'),
                  onTap: () {
                    Navigator.pop(ctx);
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

  void _showTagPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Seleccionar etiqueta',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _locationError = null;
                            _phoneError = null;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Quitar etiqueta',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Elige una etiqueta opcional para clasificar tu publicación en el feed:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ..._categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final activeColor = _getCategoryActiveColor(cat);
                  final inactiveBg = _getCategoryInactiveBg(cat);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? null : cat;
                          _locationError = null;
                          _phoneError = null;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? inactiveBg
                              : AppColors.surfaceSecondary.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? activeColor : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: inactiveBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(cat),
                                size: 18,
                                color: activeColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? activeColor
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getCategorySubtitle(cat),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? activeColor : AppColors.subtle,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _publishPost() async {
    final content = InputValidators.sanitizeText(_contentController.text);
    final petName = InputValidators.sanitizeText(_petNameController.text);
    final breed = InputValidators.sanitizeText(_breedController.text);
    final location = InputValidators.sanitizeText(_locationController.text);
    final phone = InputValidators.sanitizeText(_phoneController.text);
    final isMating = _selectedCategory == 'Apareamiento';

    // Validación contextual
    if (isMating) {
      if (content.isEmpty && petName.isEmpty && _selectedImageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por favor, completa los datos o una foto de la mascota para publicar.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final locationErr = InputValidators.validateLocationText(location);
      final phoneErr = InputValidators.validatePhone(phone, required: false);

      if (locationErr != null || phoneErr != null) {
        setState(() {
          _locationError = locationErr;
          _phoneError = phoneErr;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(phoneErr ?? locationErr!),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else {
      if (content.isEmpty && _selectedImageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Escribe una descripción o adjunta una fotografía para publicar.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (content.isNotEmpty &&
          content.length < 3 &&
          _selectedImageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escribe al menos 3 caracteres para publicar.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isPublishing = true);

    String? uploadedImageUrl;

    // Subida a Firebase Cloud Storage con compresión de alta calidad (1600 px, 85%)
    if (_selectedImageFiles.isNotEmpty) {
      final primaryFile = _selectedImageFiles.first;
      if (FirestoreService().isFirebaseReady) {
        try {
          uploadedImageUrl = await StorageService().uploadImage(
            file: primaryFile,
            folder: isMating ? 'mating_posts' : 'community_posts',
            preset: ImageCompressionPreset.postAndReport,
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
      } else {
        final compressed = await ImageCompressor.compressFile(
          primaryFile,
          preset: ImageCompressionPreset.postAndReport,
        );
        uploadedImageUrl = compressed.path;
      }
    }

    final currentUser = AuthService().currentUser;
    final authorName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : 'Usuario Yago';
    final authorAvatar =
        MockDataService().currentUserAvatar ?? currentUser?.photoURL;

    try {
      if (isMating) {
        final finalName = petName.isNotEmpty ? petName : 'Mascota';
        final finalBreed = breed.isNotEmpty ? breed : 'Mestizo';
        final finalGender = _selectedGender;
        final finalLocation =
            location.isNotEmpty ? location : 'Caleta Olivia';
        final finalPhone = phone.isNotEmpty
            ? phone
            : 'Contacto por chat interno';
        final finalDesc = content.isNotEmpty
            ? content
            : 'Búsqueda de pareja para cruza responsable. Contactar por mensaje directo.';

        final List<String> tags = [
          'Apareamiento',
          'Busca pareja',
          _selectedGender,
        ];

        final coords = InputValidators.inferCoordinatesFromText(finalLocation);

        final newPet = Pet(
          id: 'pet-${DateTime.now().millisecondsSinceEpoch}',
          ownerId: currentUser?.uid,
          ownerAvatar: authorAvatar,
          name: finalName,
          breed: finalBreed,
          species: _selectedSpecies,
          gender: finalGender,
          age: 'Desconocida',
          status: YagoPetStatus.mating,
          location: finalLocation,
          timeAgo: 'Recién publicado',
          date: DateTime.now(),
          description: finalDesc,
          imageUrl: uploadedImageUrl ?? 'assets/images/IMG_5370.JPG',
          tags: tags,
          contactName: authorName,
          contactPhone: finalPhone,
          latitude: coords.latitude,
          longitude: coords.longitude,
          isUserOwner: true,
        );

        await MockDataService().addPet(newPet);
      } else {
        String categoryType = 'general';
        if (_selectedCategory == 'Consejo') {
          categoryType = 'tip';
        } else if (_selectedCategory == 'Reencuentro') {
          categoryType = 'reunion';
        } else if (_selectedCategory == 'Aviso') {
          categoryType = 'aviso';
        } else if (_selectedCategory == 'Salud') {
          categoryType = 'salud';
        }

        final newPost = FeedPost(
          id: 'post-${DateTime.now().millisecondsSinceEpoch}',
          authorId: currentUser?.uid,
          authorName: authorName,
          authorAvatar: authorAvatar,
          timeAgo: 'Recién publicado',
          content: content,
          imageUrl: uploadedImageUrl,
          likesCount: 0,
          commentsCount: 0,
          isLiked: false,
          postType: categoryType,
          createdAt: DateTime.now(),
        );

        await MockDataService().addCommunityPost(newPost);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la publicación: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() => _isPublishing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMating
              ? '¡Publicación de búsqueda de pareja creada con éxito!'
              : '¡Publicación compartida con éxito en el feed!',
        ),
        backgroundColor: isMating ? AppColors.mating : AppColors.primary,
      ),
    );

    widget.onPostCreated?.call();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMating = _selectedCategory == 'Apareamiento';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Crear Publicación',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Center(
              child: SizedBox(
                height: 34,
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
        // Línea horizontal debajo de Crear Publicación (como en la referencia)
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Área de descripción limpia (estilo referencia) ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: TextField(
                controller: _contentController,
                minLines: 4,
                maxLines: 8,
                maxLength: 600,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.5,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: _selectedCategory == 'Apareamiento'
                      ? 'Describe temperamento, vacunas, certificado de salud o qué buscas en su pareja...'
                      : (_selectedCategory == 'Consejo'
                          ? 'Comparte un consejo de salud, cuidado o bienestar animal...'
                          : (_selectedCategory == 'Reencuentro'
                              ? 'Comparte la historia del final feliz de tu mascota...'
                              : (_selectedCategory == 'Salud'
                                  ? 'Detalla horarios, requisitos o lugar de la jornada de castración / salud...'
                                  : (_selectedCategory == 'Aviso'
                                      ? 'Escribe el aviso o comunicado para la comunidad...'
                                      : 'Agrega una descripción...')))),
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.5,
                    color: AppColors.subtle,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.feedDivider),

            // ─── 2. Botón: Agregar Fotos > ───────────────────────────────────
            InkWell(
              onTap: _showImageSourceModal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Agregar Fotos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_selectedImageFiles.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedImageFiles.length == 1
                              ? '1 foto'
                              : '${_selectedImageFiles.length} fotos',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Previsualización de fotos seleccionadas o tomadas (estilo referencia)
            if (_selectedImageFiles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                child: _selectedImageFiles.length == 1
                    ? Center(
                        child: _buildPhotoPreviewCard(
                          file: _selectedImageFiles.first,
                          index: 0,
                          width: 200,
                          height: 260,
                        ),
                      )
                    : SizedBox(
                        height: 240,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImageFiles.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, idx) => _buildPhotoPreviewCard(
                            file: _selectedImageFiles[idx],
                            index: idx,
                            width: 180,
                            height: 240,
                          ),
                        ),
                      ),
              ),
            ],

            const Divider(height: 1, thickness: 1, color: AppColors.feedDivider),

            // ─── 3. Botón: Agregar Etiqueta > ────────────────────────────────
            InkWell(
              onTap: _showTagPickerModal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      size: 23,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Agregar Etiqueta',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_selectedCategory != null) ...[
                      YagoPostCategoryBadge(category: _selectedCategory!),
                      const SizedBox(width: 6),
                    ],
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Chips rápidos de etiquetas debajo (estilo píldoras de la referencia)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedCategory != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryInactiveBg(_selectedCategory),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _getCategoryActiveColor(_selectedCategory)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(_selectedCategory!),
                            size: 18,
                            color: _getCategoryActiveColor(_selectedCategory),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Etiqueta seleccionada: $_selectedCategory',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _getCategoryActiveColor(_selectedCategory),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedCategory = null;
                              _locationError = null;
                              _phoneError = null;
                            }),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: _getCategoryActiveColor(_selectedCategory),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final activeColor = _getCategoryActiveColor(cat);
                        final inactiveBg = _getCategoryInactiveBg(cat);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedCategory = isSelected ? null : cat;
                                _locationError = null;
                                _phoneError = null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? activeColor
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? activeColor
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(cat),
                                    size: 15,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (isSelected && inactiveBg != Colors.transparent) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.feedDivider),

            // ─── 4. Campos contextuales si se eligió "Apareamiento" ──────────
            if (isMating) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Búsqueda de pareja / Apareamiento',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.matingText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Especie',
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
                      children: _speciesOptions.map(_buildSpeciesPill).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: YagoTextField(
                            label: 'Nombre de la mascota',
                            hint: 'Ej: Simba, Bella',
                            controller: _petNameController,
                            maxLength: 50,
                            prefixIcon: const Icon(
                              Icons.pets_rounded,
                              size: 18,
                              color: AppColors.subtle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: YagoBreedSelectorField(
                            label: 'Raza',
                            hint: 'Ej: Golden Retriever',
                            controller: _breedController,
                            species: _selectedSpecies,
                            maxLength: 60,
                            prefixIcon: const Icon(
                              Icons.pets_outlined,
                              size: 18,
                              color: AppColors.subtle,
                            ),
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
                            hint: 'Ej: Barrio Parque, Caleta Olivia',
                            controller: _locationController,
                            maxLength: 90,
                            errorText: _locationError,
                            onChanged: (_) {
                              if (_locationError != null) {
                                setState(() => _locationError = null);
                              }
                            },
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.subtle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: YagoTextField(
                            label: 'Teléfono (Opcional)',
                            hint: 'Ej: +54 9 297 345-6789',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 25,
                            errorText: _phoneError,
                            onChanged: (_) {
                              if (_phoneError != null) {
                                setState(() => _phoneError = null);
                              }
                            },
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: AppColors.subtle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewCard({
    required File file,
    required int index,
    required double width,
    required double height,
  }) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              file,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageFiles.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
