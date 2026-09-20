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
  bool _isSaving = false;
  String? _nameError;

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
      final file = await StorageService().pickImage(source: source);
      if (file != null) {
        setState(() {
          _selectedImageFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo seleccionar la imagen: $e'),
            backgroundColor: AppColors.lost,
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
              if (_selectedImageFile != null || widget.currentPhotoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.lost),
                  title: const Text(
                    'Eliminar foto actual',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: AppColors.lost),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedImageFile = null;
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'El nombre no puede estar vacío';
      });
      return;
    }

    setState(() {
      _nameError = null;
      _isSaving = true;
    });

    try {
      String? photoUrl = widget.currentPhotoUrl;

      // Subir nueva foto si se seleccionó una
      if (_selectedImageFile != null) {
        try {
          photoUrl = await StorageService().uploadImage(
            file: _selectedImageFile!,
            folder: 'avatars',
          );
        } catch (_) {
          // Si falla la subida a Cloud Storage (ej: sin conexión o pruebas), mantener ruta local
          photoUrl = _selectedImageFile!.path;
        }
      }

      // Actualizar perfil en Firebase Auth
      await AuthService().updateProfile(
        displayName: name,
        photoURL: photoUrl,
      );

      final bio = _bioController.text.trim();
      final location = _locationController.text.trim();
      final phone = _phoneController.text.trim();
      final currentUser = AuthService().currentUser;

      // Actualizar en Cloud Firestore si está autenticado
      if (currentUser != null) {
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

      // Actualizar metadatos en caché local de MockDataService
      MockDataService().updateUserProfile(
        bio: bio,
        location: location,
        phone: phone,
        photoUrl: photoUrl,
      );

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
            backgroundColor: AppColors.lost,
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
            ),
            const SizedBox(height: 16),

            YagoTextField(
              label: 'Ubicación',
              hint: 'Ciudad, Provincia o Barrio (ej: Santa Cruz, Argentina)',
              controller: _locationController,
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            YagoTextField(
              label: 'Teléfono de contacto',
              hint: '+54 9 ... (opcional)',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
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

    final photoUrl = widget.currentPhotoUrl;
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      if (photoUrl.startsWith('assets/')) {
        return Image.asset(
          photoUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildGenericIcon(),
        );
      }
      return Image.network(
        photoUrl,
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
