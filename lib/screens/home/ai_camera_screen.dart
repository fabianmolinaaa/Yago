import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/ai_analysis.dart';
import '../../models/pet.dart';
import '../../services/ai_vision_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';
import 'create_report_screen.dart';
import 'direct_chat_screen.dart';

/// Pantalla 3 de Yago: Escáner de Animales con Cámara en Vivo e Inteligencia Artificial
/// (Sprint 3: HU-S3-01, HU-S3-02, HU-S3-03, HU-S3-04, HU-S3-05 y HU-S3-06).
///
/// Funciona con apertura directa de cámara a pantalla completa (estilo escáner QR de Mercado Pago):
/// al pulsar el botón central de la barra de navegación se abre inmediatamente el visor de la cámara
/// con controles para tomar la fotografía en el acto o cargar una imagen desde la galería.
class AiCameraScreen extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onClose;
  final VoidCallback? onReportCreated;
  final AiSamplePreset? initialPreset;

  const AiCameraScreen({
    super.key,
    this.isActive = true,
    this.onClose,
    this.onReportCreated,
    this.initialPreset,
  });

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen>
    with WidgetsBindingObserver {
  // Controlador de cámara nativa en vivo
  List<CameraDescription> _cameras = const [];
  CameraController? _cameraController;
  int _selectedCameraIdx = 0;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  bool _isTorchOn = false;

  // Filtro de búsqueda en base de datos activa:
  // 0 = Todos (Perdidas y Encontradas), 1 = Solo Perdidas, 2 = Solo Encontradas
  int _selectedStatusFilterIndex = 0;

  File? _pickedImageFile;
  String? _selectedSampleUrl;

  bool _isAnalyzing = false;
  AiPetAnalysis? _currentAnalysis;
  List<AiMatchResult> _matches = const [];

  bool get _isFlutterTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  YagoPetStatus? get _activeStatusFilter {
    if (_selectedStatusFilterIndex == 1) return YagoPetStatus.lost;
    if (_selectedStatusFilterIndex == 2) return YagoPetStatus.found;
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialPreset != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _runAiAnalysis(preset: widget.initialPreset);
        }
      });
    } else if (widget.isActive) {
      _initLiveCamera();
    }
  }

  @override
  void didUpdateWidget(covariant AiCameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (widget.initialPreset == null) {
        _resetScanner();
      }
      _initLiveCamera();
    } else if (!widget.isActive && oldWidget.isActive) {
      _resetScanner();
      _disposeCameraController();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive || _isFlutterTest) return;
    final controller = _cameraController;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCameraController();
    } else if (state == AppLifecycleState.resumed &&
        controller == null &&
        _currentAnalysis == null) {
      _initLiveCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCameraController();
    super.dispose();
  }

  Future<void> _initLiveCamera({int? cameraIndex}) async {
    if (_isFlutterTest || _isInitializingCamera || !mounted) return;
    _isInitializingCamera = true;

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty || !mounted) {
        _isInitializingCamera = false;
        return;
      }

      final targetIdx = cameraIndex ?? _selectedCameraIdx;
      final safeIdx = targetIdx < _cameras.length ? targetIdx : 0;
      final cameraDesc = _cameras[safeIdx];

      final prevController = _cameraController;
      _cameraController = null;
      _isCameraInitialized = false;
      await prevController?.dispose();

      final controller = CameraController(
        cameraDesc,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted || !widget.isActive) {
        await controller.dispose();
        _isInitializingCamera = false;
        return;
      }

      setState(() {
        _selectedCameraIdx = safeIdx;
        _cameraController = controller;
        _isCameraInitialized = true;
        _isTorchOn = false;
      });
    } catch (_) {
      // Si el emulador no dispone de cámara física o permisos aún no otorgados,
      // mantenemos el visor interactivo con fallback al selector nativo.
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _disposeCameraController() async {
    final controller = _cameraController;
    _cameraController = null;
    if (mounted && _isCameraInitialized) {
      setState(() {
        _isCameraInitialized = false;
        _isTorchOn = false;
      });
    } else {
      _isCameraInitialized = false;
      _isTorchOn = false;
    }
    try {
      await controller?.dispose();
    } catch (_) {}
  }

  Future<void> _toggleTorch() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final nextMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(nextMode);
      if (!mounted) return;
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _initLiveCamera(cameraIndex: nextIdx);
  }

  Future<void> _handleShutterTap() async {
    if (_isAnalyzing) return;

    if (_isFlutterTest) {
      await _runAiAnalysis(
        preset: widget.initialPreset ?? AiVisionService.samplePresets.first,
      );
      return;
    }

    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      try {
        final XFile xfile = await controller.takePicture();
        final optimizedFile = await ImageCompressor.compressFile(
          File(xfile.path),
          preset: ImageCompressionPreset.postAndReport,
        );
        if (!mounted) return;
        await _runAiAnalysis(imageFile: optimizedFile);
        return;
      } catch (_) {
        // Si falla la captura directa, usamos el selector nativo de cámara
      }
    }

    await _captureOrPickImage(ImageSource.camera);
  }

  Future<void> _captureOrPickImage(ImageSource source) async {
    try {
      final file = await StorageService().pickImage(
        source: source,
        preset: ImageCompressionPreset.postAndReport,
      );
      if (file == null || !mounted) return;
      await _runAiAnalysis(imageFile: file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo obtener la imagen: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _runAiAnalysis({
    File? imageFile,
    String? imageUrl,
    AiSamplePreset? preset,
  }) async {
    setState(() {
      _isAnalyzing = true;
      _currentAnalysis = null;
      _matches = const [];
      if (imageFile != null) {
        _pickedImageFile = imageFile;
        _selectedSampleUrl = null;
      } else if (preset != null) {
        _pickedImageFile = null;
        _selectedSampleUrl = preset.imageUrl;
      } else if (imageUrl != null) {
        _pickedImageFile = null;
        _selectedSampleUrl = imageUrl;
      }
    });

    final startTime = DateTime.now();
    final analysis = await AiVisionService().analyzeImage(
      imageFile: imageFile,
      imageUrl: imageUrl ?? preset?.imageUrl,
      preset: preset,
    );

    if (!_isFlutterTest) {
      final elapsed = DateTime.now().difference(startTime);
      const minDisplay = Duration(milliseconds: 650);
      if (elapsed < minDisplay) {
        await Future<void>.delayed(minDisplay - elapsed);
      }
    }

    if (!mounted) return;

    if (analysis.isAnimal) {
      MockDataService().recordAiAnalysis(analysis);
    }
    final matches = analysis.isAnimal
        ? AiVisionService().findMatches(
            analysis,
            statusFilter: _activeStatusFilter,
          )
        : const <AiMatchResult>[];

    setState(() {
      _currentAnalysis = analysis;
      _matches = matches;
      _isAnalyzing = false;
    });
  }

  void _recalculateMatches() {
    if (_currentAnalysis == null) return;
    setState(() {
      _matches = AiVisionService().findMatches(
        _currentAnalysis!,
        statusFilter: _activeStatusFilter,
      );
    });
  }

  void _resetScanner() {
    setState(() {
      _pickedImageFile = null;
      _selectedSampleUrl = null;
      _currentAnalysis = null;
      _matches = const [];
      _isAnalyzing = false;
    });
    if (widget.isActive && !_isCameraInitialized) {
      _initLiveCamera();
    }
  }

  void _handleCloseScanner() {
    _resetScanner();
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _openEditTraitsModal() {
    final analysis = _currentAnalysis;
    if (analysis == null) return;

    String tempSpecies = analysis.species;
    final breedCtrl = TextEditingController(text: analysis.apparentBreed);
    final colorsCtrl = TextEditingController(text: analysis.colors.join(', '));
    final traitsCtrl =
        TextEditingController(text: analysis.distinctiveTraits.join(', '));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const Text(
                      'Ajustar rasgos físicos detectados',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Modifica los atributos si observas algún detalle adicional para volver a cotejar en la base de datos.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Especie',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Perro', 'Gato', 'Otro'].map((sp) {
                        final isSelected = tempSpecies == sp;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () =>
                                  setModalState(() => tempSpecies = sp),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  sp,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    YagoBreedSelectorField(
                      label: 'Raza aparente o tipo',
                      hint: 'Ej: Caniche, Mestizo, Cane Corso...',
                      controller: breedCtrl,
                      species: tempSpecies,
                      maxLength: 60,
                    ),
                    const SizedBox(height: 14),
                    YagoTextField(
                      label: 'Colores (separados por coma)',
                      hint: 'Ej: Blanco, Naranja',
                      controller: colorsCtrl,
                      maxLength: 100,
                    ),
                    const SizedBox(height: 14),
                    YagoTextField(
                      label: 'Señas particulares (separadas por coma)',
                      hint: 'Ej: Moño rosa, Collar verde, Sin collar',
                      controller: traitsCtrl,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 20),
                    YagoButton(
                      text: 'Actualizar y buscar coincidencias',
                      isFullWidth: true,
                      onPressed: () {
                        final newColors = colorsCtrl.text
                            .split(',')
                            .map((s) => InputValidators.sanitizeText(s))
                            .where((s) => s.isNotEmpty)
                            .take(5)
                            .toList();
                        final newTraits = traitsCtrl.text
                            .split(',')
                            .map((s) => InputValidators.sanitizeText(s))
                            .where((s) => s.isNotEmpty)
                            .take(InputValidators.maxTagsCount)
                            .toList();
                        final updated = analysis.copyWith(
                          species: tempSpecies,
                          apparentBreed: breedCtrl.text.trim().isEmpty
                              ? 'Mestizo'
                              : breedCtrl.text.trim(),
                          colors: newColors.isEmpty
                              ? const ['No especificado']
                              : newColors,
                          distinctiveTraits: newTraits,
                        );
                        Navigator.of(modalContext).pop();
                        setState(() {
                          _currentAnalysis = updated;
                          _matches = AiVisionService().findMatches(
                            updated,
                            statusFilter: _activeStatusFilter,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openDirectChat(AiMatchResult match) {
    if (match.pet.isUserOwner) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DirectChatScreen(
          pet: match.pet,
          aiSimilarityPercentage: match.similarityPercentage,
          analyzedImageSource: match.analyzedImageSource,
        ),
      ),
    );
  }

  void _openPetDetail(Pet pet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PetDetailScreen(pet: pet),
      ),
    );
  }

  void _openCreateFoundReportFromAi() {
    final analysis = _currentAnalysis;
    bool reportCreated = false;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          initialIsLostReport: false,
          initialImageFile: _pickedImageFile,
          initialImageUrl: _selectedSampleUrl ?? analysis?.imageSource,
          initialSpecies: analysis?.species,
          initialBreed: analysis?.apparentBreed,
          initialTags: analysis?.combinedTags,
          initialDescription: analysis?.suggestedReportDescription,
          fromAiCamera: true,
          onReportCreated: () {
            reportCreated = true;
            _resetScanner();
            widget.onReportCreated?.call();
          },
        ),
      ),
    )
        .then((_) {
      if (!mounted) return;
      if (reportCreated) {
        _resetScanner();
      } else {
        _recalculateMatches();
      }
    });
  }

  Widget _buildSpeciesIcon(String species) {
    final s = species.toLowerCase().trim();
    if (s.contains('perro')) {
      return const Icon(Icons.pets_rounded, size: 18, color: AppColors.primary);
    } else if (s.contains('gato')) {
      return const CatIcon(size: 18, color: AppColors.primary);
    } else {
      return const Icon(
        Icons.cruelty_free_rounded,
        size: 18,
        color: AppColors.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAnalyzing && _currentAnalysis == null && widget.onClose == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isAnalyzing || _currentAnalysis != null) {
          _resetScanner();
        } else {
          _handleCloseScanner();
        }
      },
      child: _isAnalyzing
          ? _buildProcessingScreen()
          : (_currentAnalysis == null
              ? _buildFullScreenLiveScanner()
              : (!_currentAnalysis!.isAnimal
                  ? _buildNotAnAnimalErrorScreen(_currentAnalysis!)
                  : _buildAnalysisResultsScreen())),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. MODO CÁMARA EN VIVO A PANTALLA COMPLETA (ESTILO QR DE MERCADO PAGO)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFullScreenLiveScanner() {
    final hasCapturedPreview = _pickedImageFile != null ||
        (_selectedSampleUrl != null && _selectedSampleUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Capa 1: Vista previa de cámara en vivo o imagen capturada ───
          if (hasCapturedPreview)
            _pickedImageFile != null
                ? Image.file(
                    _pickedImageFile!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildCameraFallbackBackdrop(),
                  )
                : YagoPetImage(
                    imageUrl: _selectedSampleUrl!,
                    fit: BoxFit.cover,
                  )
          else if (_isCameraInitialized &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            LayoutBuilder(
              builder: (context, constraints) {
                final previewSize = _cameraController!.value.previewSize;
                if (previewSize == null) {
                  return CameraPreview(_cameraController!);
                }
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewSize.height,
                      height: previewSize.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                );
              },
            )
          else
            _buildCameraFallbackBackdrop(),

          // ─── Capa 2: Controles de cámara a pantalla completa ─────────────
          SafeArea(
            child: Column(
              children: [
                // Barra superior flotante sobre la cámara (Cerrar, Título, Linterna)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      _buildGlassIconButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Cerrar cámara',
                        onTap: _handleCloseScanner,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.52),
                            borderRadius: AppRadius.fullBorder,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.center_focus_strong_rounded,
                                color: AppColors.primary,
                                size: 17,
                              ),
                              SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  'Cámara con IA',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildGlassIconButton(
                        icon: _isTorchOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        tooltip: 'Linterna',
                        isActive: _isTorchOn,
                        onTap: _toggleTorch,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ─── Barra inferior de controles de cámara (Galería / Obturador / Girar) ─
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Botón de Galería (HU-S3-02)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                _captureOrPickImage(ImageSource.gallery),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.28),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Cargar de galería',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 2. Obturador central para sacar la foto (HU-S3-01 / HU-S3-02)
                      GestureDetector(
                        onTap: _handleShutterTap,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.2,
                                ),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Tomar foto',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Botón de cambio de lente (Frontal / Trasera)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _switchCamera,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.28),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.flip_camera_ios_rounded,
                                      color: Colors.white,
                                      size: 21,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Girar cámara',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Capa 4: Superposición de análisis en curso ───────────────────
          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.72),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _buildAnalyzingLoader(),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraFallbackBackdrop() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.05,
          colors: [
            Color(0xFF232B35),
            Color(0xFF0E1318),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? AppColors.primary
            : Colors.black.withValues(alpha: 0.52),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. PANTALLA DE CARGA Y VERIFICACIÓN DE IMAGEN CON IA
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProcessingScreen() {
    final hasPreview = _pickedImageFile != null ||
        (_selectedSampleUrl != null && _selectedSampleUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Cancelar análisis',
          icon: const Icon(
            Icons.close_rounded,
            size: 21,
            color: AppColors.textPrimary,
          ),
          onPressed: _resetScanner,
        ),
        title: const Text(
          'Procesando imagen...',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPreview) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 210,
                      height: 210,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _pickedImageFile != null
                              ? Image.file(
                                  _pickedImageFile!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _buildCameraFallbackBackdrop(),
                                )
                              : YagoPetImage(
                                  imageUrl: _selectedSampleUrl!,
                                  fit: BoxFit.cover,
                                ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                          const Center(
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildAnalyzingLoader(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. PANTALLA DE ERROR CUANDO LA IMAGEN NO ES UN ANIMAL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNotAnAnimalErrorScreen(AiPetAnalysis analysis) {
    final hasPreview = _pickedImageFile != null ||
        (_selectedSampleUrl != null && _selectedSampleUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Volver al escáner',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: AppColors.textPrimary,
          ),
          onPressed: _resetScanner,
        ),
        title: const Text(
          'Cámara con IA',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasPreview) ...[
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            width: 165,
                            height: 165,
                            child: _pickedImageFile != null
                                ? Image.file(
                                    _pickedImageFile!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => YagoPetImage(
                                      imageUrl: analysis.imageSource,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : YagoPetImage(
                                    imageUrl: analysis.imageSource,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ] else ...[
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColors.error,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'No detectamos un animal en la imagen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.nonAnimalReason ??
                      'La fotografía seleccionada no parece mostrar una mascota u otro animal con claridad.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendaciones para una buena detección:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '• Asegúrate de que el animal (perro, gato, ave, conejo, tortuga, etc.) sea el centro de la foto.\n'
                        '• Evita fotos muy lejanas, movidas o de objetos cotidianos.\n'
                        '• Procura contar con buena iluminación.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                YagoButton(
                  text: 'Tomar otra foto',
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  isFullWidth: true,
                  onPressed: _resetScanner,
                ),
                const SizedBox(height: 10),
                YagoButton(
                  text: 'Elegir otra de la galería',
                  variant: YagoButtonVariant.outline,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  isFullWidth: true,
                  onPressed: () => _captureOrPickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. PANTALLA DE RESULTADOS E IDENTIFICACIÓN DE IA (HU-S3-02 A HU-S3-06)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAnalysisResultsScreen() {
    final analysis = _currentAnalysis!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: MockDataService(),
        builder: (context, _) {
          final activeReportsCount = MockDataService()
              .getAllPets()
              .where((p) =>
                  !p.isModerated &&
                  (p.status == YagoPetStatus.lost ||
                      p.status == YagoPetStatus.found))
              .length;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  tooltip: 'Volver al escáner',
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 19,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _resetScanner,
                ),
                titleSpacing: 4,
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cámara con IA',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Escáner de animales · Identificación mediante IA',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Nueva foto',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Filtro de alcance de búsqueda (Todos / Perdidas / Encontradas)
                      _buildSearchScopeSelector(activeReportsCount),
                      const SizedBox(height: 16),

                      // 2. PRIMERO: Posibles coincidencias en base de datos (>= 50% de similitud)
                      _buildMatchesSection(analysis),
                      const SizedBox(height: 22),

                      // 3. SEGUNDO: Rasgos físicos extraídos por IA (HU-S3-02)
                      _buildExtractedTraitsCard(analysis),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchScopeSelector(int activeReportsCount) {
    final labels = [
      'Todos ($activeReportsCount)',
      'Perdidas',
      'Encontradas',
    ];

    return Row(
      children: List.generate(labels.length, (idx) {
        final isSelected = _selectedStatusFilterIndex == idx;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: idx < labels.length - 1 ? 8 : 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _selectedStatusFilterIndex = idx;
                });
                _recalculateMatches();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 9,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[idx],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnalyzingLoader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Verificando y analizando imagen con IA...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '1. Verificando presencia de un animal en la foto\n'
            '2. Buscando posibles coincidencias (≥ 50%)\n'
            '3. Extrayendo especie, raza aparente, colores y señas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedTraitsCard(AiPetAnalysis analysis) {
    final confidencePct = (analysis.confidence * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'RASGOS FÍSICOS EXTRAÍDOS POR IA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Text(
                  'Confianza $confidencePct%',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Especie y Raza aparente
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildSpeciesIcon(analysis.species),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Especie',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              analysis.species,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.border),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Raza aparente',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        analysis.apparentBreed,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Colores detectados
          const Text(
            'Colores detectados',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: analysis.colors
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: AppRadius.fullBorder,
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Señas particulares
          const Text(
            'Señas particulares',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: analysis.distinctiveTraits
                .map((trait) => YagoFeatureTag(label: trait))
                .toList(),
          ),
          const SizedBox(height: 12),

          Text(
            analysis.summary,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openEditTraitsModal,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Ajustar rasgos',
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
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesSection(AiPetAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'COINCIDENCIAS EN BASE DE DATOS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _matches.isEmpty
                  ? '0 coincidencias'
                  : '${_matches.length} ${_matches.length == 1 ? "coincidencia" : "coincidencias"}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_matches.isEmpty)
          _buildNoMatchesCard(analysis)
        else ...[
          ..._matches.map(_buildMatchComparisonCard),
          const SizedBox(height: 8),
          _buildSecondaryCreateFoundReportCard(),
        ],
      ],
    );
  }

  /// Tarjeta de comparación visual lado a lado con porcentaje de similitud y acceso
  /// directo al chat con el responsable del reporte (HU-S3-04 y HU-S3-05).
  Widget _buildMatchComparisonCard(AiMatchResult match) {
    final pet = match.pet;
    final isLost = pet.status == YagoPetStatus.lost;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: match.isHighSimilarity
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
          width: match.isHighSimilarity ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Encabezado: Porcentaje de similitud visual y Badge de estado (PERDIDA / ENCONTRADA)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: match.isHighSimilarity
                      ? AppColors.reunitedBg
                      : AppColors.primaryTint,
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: match.isHighSimilarity
                          ? AppColors.reunitedText
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${match.similarityPercentage}% de similitud',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: match.isHighSimilarity
                            ? AppColors.reunitedText
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              YagoStatusBadge(status: pet.status),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Fotos comparativas lado a lado (HU-S3-04)
          Row(
            children: [
              // Foto capturada / analizada
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 125,
                        width: double.infinity,
                        child: _pickedImageFile != null
                            ? Image.file(
                                _pickedImageFile!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => YagoPetImage(
                                  imageUrl: match.analyzedImageSource,
                                  height: 125,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : YagoPetImage(
                                imageUrl: match.analyzedImageSource,
                                height: 125,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Foto analizada',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.compare_arrows_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${match.similarityPercentage}%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Foto del reporte en base de datos
              Expanded(
                child: GestureDetector(
                  onTap: () => _openPetDetail(pet),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 125,
                          width: double.infinity,
                          child: YagoPetImage(
                            imageUrl: pet.imageUrl,
                            height: 125,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Reporte: ${pet.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Información del reporte coincidente
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pet.detailsSummary,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pet.locationAndTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isLost
                                ? 'Dueño/a: ${pet.contactName}'
                                : 'Reportante: ${pet.contactName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (match.matchingTraits.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: match.matchingTraits.map((trait) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 12,
                        color: AppColors.reunitedText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trait,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),

          // 4. Acciones directas: Ver ficha completa y Abrir chat directo (HU-S3-05)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: YagoButton(
                  text: 'Ver ficha',
                  variant: YagoButtonVariant.outline,
                  size: YagoButtonSize.small,
                  onPressed: () => _openPetDetail(pet),
                ),
              ),
              if (!pet.isUserOwner) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: YagoButton(
                    text: 'Abrir chat directo',
                    variant: YagoButtonVariant.primary,
                    size: YagoButtonSize.small,
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    onPressed: () => _openDirectChat(match),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Estado cuando la IA no detecta coincidencias en la base de datos activa (HU-S3-06).
  /// Permite generar un nuevo reporte de mascota encontrada reutilizando la foto tomada
  /// y los rasgos físicos extraídos para ahorrar tiempo.
  Widget _buildNoMatchesCard(AiPetAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No se detectaron coincidencias',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'La IA cotejó la fotografía contra todos los reportes activos de mascotas perdidas y encontradas en Yago sin hallar coincidencias.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reutilizaremos la foto tomada y los rasgos detectados (${analysis.species} · ${analysis.apparentBreed}) para publicar el hallazgo en segundos.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          YagoButton(
            text: 'Generar reporte de mascota encontrada',
            variant: YagoButtonVariant.primary,
            isFullWidth: true,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 18,
              color: Colors.white,
            ),
            onPressed: _openCreateFoundReportFromAi,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCreateFoundReportCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Ninguna coincidencia corresponde al animal que viste?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Puedes publicar un nuevo reporte de mascota encontrada reutilizando la foto y los rasgos extraídos por la IA.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          YagoButton(
            text: 'Generar reporte de mascota encontrada',
            variant: YagoButtonVariant.outline,
            size: YagoButtonSize.small,
            isFullWidth: true,
            onPressed: _openCreateFoundReportFromAi,
          ),
        ],
      ),
    );
  }
}
