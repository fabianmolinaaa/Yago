import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialBio;
  final String initialLocation;
  final String initialPhone;
  final String? currentPhotoUrl;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialBio,
    required this.initialLocation,
    required this.initialPhone,
    this.currentPhotoUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _phoneController;

  File? _selectedImageFile;
  bool _removeCurrentPhoto = false;
  bool _isSaving = false;
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    _locationController = TextEditingController(text: widget.initialLocation);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await StorageService().pickImage(
        source: source,
        preset: ImageCompressionPreset.avatar,
      );
      if (file != null) {
        setState(() {
          _selectedImageFile = file;
          _removeCurrentPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo seleccionar la imagen: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Foto de perfil',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: AppColors.textPrimary),
                title: const Text('Tomar foto', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.textPrimary),
                title: const Text('Elegir de la galería', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImageFile != null ||
                  (!_removeCurrentPhoto && widget.currentPhotoUrl != null))
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text(
                    'Eliminar foto actual',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedImageFile = null;
                      _removeCurrentPhoto = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final name = InputValidators.sanitizeText(_nameController.text);
    final bio = InputValidators.sanitizeText(_bioController.text);
    final location = InputValidators.sanitizeText(_locationController.text);
    final phone = InputValidators.sanitizeText(_phoneController.text);

    final nameErr = InputValidators.validatePersonName(
      name,
      emptyMessage: 'El nombre no puede estar vacío',
    );
    final phoneErr = InputValidators.validatePhone(phone, required: false);

    if (nameErr != null || phoneErr != null) {
      setState(() {
        _nameError = nameErr;
        _phoneError = phoneErr;
      });
      return;
    }

    setState(() {
      _nameError = null;
      _phoneError = null;
      _isSaving = true;
    });

    try {
      String? photoUrl = _removeCurrentPhoto ? null : widget.currentPhotoUrl;

      // Subir nueva foto comprimida con perfil de avatar si se seleccionó una
      if (_selectedImageFile != null) {
        try {
          photoUrl = await StorageService().uploadImage(
            file: _selectedImageFile!,
            folder: 'avatars',
            preset: ImageCompressionPreset.avatar,
          );
        } catch (_) {
          // Si falla la subida a Cloud Storage (ej: sin conexión o pruebas), mantener ruta local optimizada
          final compressed = await ImageCompressor.compressFile(
            _selectedImageFile!,
            preset: ImageCompressionPreset.avatar,
          );
          photoUrl = compressed.path;
        }
      }

      // Actualizar perfil en Firebase Auth
      await AuthService().updateProfile(
        displayName: name,
        photoURL: photoUrl,
      );

      final currentUser = AuthService().currentUser;

      // Actualizar metadatos en caché local de MockDataService (y propagar a publicaciones/reportes propios)
      MockDataService().updateUserProfile(
        bio: bio,
        location: location,
        phone: phone,
        photoUrl: photoUrl,
        displayName: name,
        clearPhoto: photoUrl == null,
      );

      // Actualizar en Cloud Firestore si está autenticado (preservando rol y createdAt)
      if (currentUser != null) {
        try {
          await FirestoreService().updateUserProfile(currentUser.uid, {
            'displayName': name,
            'photoUrl': photoUrl,
            'phoneNumber': phone,
            'bio': bio,
            'location': location,
          });
        } catch (_) {
          try {
            await FirestoreService().setUserProfile(
              UserModel(
                uid: currentUser.uid,
                email: currentUser.email ?? '',
                displayName: name,
                photoUrl: photoUrl,
                phoneNumber: phone,
                bio: bio,
                location: location,
                updatedAt: DateTime.now(),
              ),
            );
          } catch (_) {}
        }

        // Sincronizar la nueva foto y nombre en todas las publicaciones y reportes del usuario en Firestore
        FirestoreService()
            .syncUserAuthorMetadata(
              userId: currentUser.uid,
              userName: name,
              photoUrl: photoUrl,
            )
            .catchError((_) {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.primaryDark,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sección de Foto de Perfil
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImagePickerModal,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryTint,
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildAvatarPreview(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerModal,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showImagePickerModal,
              child: const Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Formulario de edición
            YagoTextField(
              label: 'Nombre',
              hint: 'Tu nombre completo o apodo',
              controller: _nameController,
              maxLength: 60,
              errorText: _nameError,
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textSecondary),
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: 16),

            YagoTextField(
              label: 'Biografía',
              hint: 'Cuéntale a la comunidad sobre ti y tus mascotas...',
              controller: _bioController,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            YagoTextField(
              label: 'Ubicación',
              hint: 'Ciudad, Provincia o Barrio (ej: Santa Cruz, Argentina)',
              controller: _locationController,
              maxLength: 80,
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            YagoTextField(
              label: 'Teléfono de contacto',
              hint: '+54 9 ... (opcional)',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 25,
              errorText: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) {
                  setState(() => _phoneError = null);
                }
              },
              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
              helperText: 'Visible cuando coordines avisos o reencuentros de mascotas.',
            ),
            const SizedBox(height: 32),

            // Botón principal inferior de guardar
            SizedBox(
              width: double.infinity,
              child: YagoButton(
                text: 'Guardar cambios',
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
      );
    }

    if (_removeCurrentPhoto) {
      return _buildGenericIcon();
    }

    final photoUrl = widget.currentPhotoUrl?.trim();
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('assets/')) {
        return Image.asset(
          photoUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildGenericIcon(),
        );
      }
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        return Image.network(
          photoUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildGenericIcon(),
        );
      }
      return Image.file(
        File(photoUrl),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildGenericIcon(),
      );
    }

    return _buildGenericIcon();
  }

  Widget _buildGenericIcon() {
    return Container(
      color: AppColors.primaryTint,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 52,
        color: AppColors.primary,
      ),
    );
  }
}
