import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/chat_conversation.dart';
import '../../models/feed_post.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';

/// Pantalla de Chat Directo 1 a 1 entre personas (HU-S3-05, HU-S4-02, HU-S4-03, HU-S4-04, HU-S4-05).
///
/// Permite iniciar o continuar una conversación privada vinculada a:
/// - Un reporte del feed de reportes o mascota del feed (`pet`)
/// - Una publicación del feed comunitario (`post`)
/// - Una coincidencia detectada con la Cámara IA (`pet` + `aiSimilarityPercentage`)
/// - Una conversación activa abierta desde la bandeja de chats (`conversation`)
class DirectChatScreen extends StatefulWidget {
  final Pet? pet;
  final FeedPost? post;
  final DirectChatConversation? conversation;
  final int? aiSimilarityPercentage;
  final String? analyzedImageSource;

  const DirectChatScreen({
    super.key,
    this.pet,
    this.post,
    this.conversation,
    this.aiSimilarityPercentage,
    this.analyzedImageSource,
  });

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen>
    with WidgetsBindingObserver {
  late DirectChatConversation _conversation;
  Pet? _resolvedPet;
  FeedPost? _resolvedPost;
  String? _pendingImageUrl;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  StreamSubscription<List<DirectChatMessage>>? _messagesSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initConversation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      MockDataService().setActiveOpenChat(_conversation.id);
      MockDataService().markChatAsRead(_conversation.id);
    }
  }

  void _initConversation() {
    final mock = MockDataService();
    mock.ensureUserSubscriptions();

    if (widget.pet != null) {
      _resolvedPet = widget.pet;
      _conversation = mock.getOrCreateChatForPet(
        widget.pet!,
        aiSimilarityPercentage: widget.aiSimilarityPercentage,
        notify: false,
      );
    } else if (widget.post != null) {
      _resolvedPost = widget.post;
      _conversation = mock.getOrCreateChatForPost(
        widget.post!,
        notify: false,
      );
    } else if (widget.conversation != null) {
      _conversation = mock.getChatById(widget.conversation!.id) ??
          widget.conversation!;
      if (_conversation.isPostContext && _conversation.relatedPostId != null) {
        _resolvedPost = mock.getFeedPostById(_conversation.relatedPostId!);
      } else if (_conversation.relatedPetId.isNotEmpty) {
        _resolvedPet = mock.getPetById(_conversation.relatedPetId);
      }
    } else {
      throw ArgumentError(
        'DirectChatScreen requiere pet, post o conversation.',
      );
    }

    if (FirestoreService().isFirebaseReady) {
      _messagesSub = FirestoreService()
          .streamChatMessages(_conversation.id)
          .listen((streamedMsgs) {
        MockDataService().updateChatMessagesFromStream(
          _conversation.id,
          streamedMsgs,
        );
      }, onError: (_) {});
    }

    mock.setActiveOpenChat(_conversation.id);

    // Marcar mensajes como leídos al abrir la conversación (HU-S4-05)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        MockDataService().markChatAsRead(_conversation.id);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MockDataService().setActiveOpenChat(null);
    _messagesSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? presetText, String? customImageUrl]) async {
    final rawText = presetText ?? _messageController.text;
    final text = InputValidators.sanitizeText(rawText);
    String? imageToSend = customImageUrl ?? _pendingImageUrl;

    if (text.isEmpty && (imageToSend == null || imageToSend.isEmpty)) return;
    final cappedText = text.length > 500 ? text.substring(0, 500) : text;

    if (presetText == null) {
      _messageController.clear();
    }

    setState(() {
      _pendingImageUrl = null;
    });

    if (imageToSend != null &&
        imageToSend.isNotEmpty &&
        FirestoreService().isFirebaseReady &&
        !imageToSend.startsWith('http') &&
        !imageToSend.startsWith('assets/')) {
      try {
        final cleanPath = imageToSend.replaceFirst(RegExp(r'^file://'), '');
        final file = File(cleanPath);
        if (await file.exists()) {
          imageToSend = await StorageService().uploadImage(
            file: file,
            folder: 'chat_images',
          );
        }
      } catch (_) {}
    }

    MockDataService().sendDirectMessage(
      _conversation.id,
      cappedText,
      imageUrl: imageToSend,
    );

    if (mounted) {
      setState(() {
        _conversation =
            MockDataService().getChatById(_conversation.id) ?? _conversation;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 82,
      );
      if (picked != null && mounted) {
        setState(() {
          _pendingImageUrl = picked.path;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo acceder a la cámara o galería en este entorno.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Adjuntar foto',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Elige una opción para compartir una fotografía en el chat.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Tomar foto con la cámara',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Capturar una fotografía en este momento',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Seleccionar de la galería',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Elegir una foto guardada en tu teléfono',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
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

  void _handleChatMenuAction(String action, DirectChatConversation currentChat) {
    if (action == 'archive') {
      final archived = MockDataService().toggleArchiveChat(currentChat.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(archived ? 'Chat archivado' : 'Chat desarchivado'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
    } else if (action == 'clear') {
      MockDataService().clearChatForUser(currentChat.id);
      setState(() {
        _conversation =
            MockDataService().getChatById(currentChat.id) ?? currentChat;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Chat vaciado para ti'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
    } else if (action == 'delete') {
      MockDataService().deleteChatConversation(currentChat.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else if (action == 'report') {
      final currentUid = AuthService().currentUser?.uid;
      final otherId = currentChat.participantIds.firstWhere(
        (id) => id != currentUid,
        orElse: () => '',
      );
      final otherName = currentChat.displayContactNameFor(
        currentUid,
        currentUserName: AuthService().currentUser?.displayName,
      );
      ReportContentModal.show(
        context,
        targetType: 'chat_message',
        targetId: currentChat.id,
        chat: currentChat,
        targetAuthorId: otherId,
        targetAuthorName: otherName,
      ).then((reported) {
        if (reported == true && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _selectTopicContext(ChatTopicContext topic) {
    final updated = MockDataService().switchActiveChatContext(
      _conversation.id,
      topic,
    );
    setState(() {
      _conversation = updated;
      if (topic.isPostContext) {
        _resolvedPost = MockDataService().getFeedPostById(topic.itemId);
        _resolvedPet = null;
      } else {
        _resolvedPet = MockDataService().getPetById(topic.itemId);
        _resolvedPost = null;
      }
    });
  }

  void _openContextTarget() {
    final currentChat =
        MockDataService().getChatById(_conversation.id) ?? _conversation;

    if (!currentChat.isPostContext) {
      final targetPet =
          MockDataService().getPetById(currentChat.relatedPetId) ??
              _resolvedPet;
      if (targetPet != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PetDetailScreen(pet: targetPet),
          ),
        );
        return;
      }
    }

    // Mostrar detalle de la publicación comunitaria vinculada (HU-S4-04)
    final targetPost = (currentChat.relatedPostId != null
            ? MockDataService().getFeedPostById(currentChat.relatedPostId!)
            : null) ??
        _resolvedPost;
    final postCategory = targetPost?.categoryTag ??
        currentChat.relatedPostCategory ??
        'Comunidad';
    final postContent = targetPost?.displayContent ??
        currentChat.relatedPostSnippet ??
        currentChat.relatedPetName;
    final postImage = targetPost?.imageUrl ?? currentChat.relatedPetImage;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  YagoPostCategoryBadge(category: postCategory),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Publicación de ${_conversation.contactName}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                postContent,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
              if (postImage.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: YagoPetImage(
                      imageUrl: postImage,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _resolveRoleSubtitle(YagoPetStatus status, bool isPostContext) {
    if (isPostContext) {
      return 'Autor/a de publicación en el feed comunitario';
    }
    switch (status) {
      case YagoPetStatus.lost:
        return 'Dueño/a del reporte de mascota perdida';
      case YagoPetStatus.found:
        return 'Reportante de mascota encontrada';
      case YagoPetStatus.mating:
        return 'Publicación de apareamiento responsable';
      case YagoPetStatus.reunited:
        return 'Autor/a de historia de reencuentro';
      case YagoPetStatus.community:
      case YagoPetStatus.urgent:
      case YagoPetStatus.isNew:
        return 'Miembro de la comunidad Yago';
    }
  }

  List<String> _buildQuickAlertMessages({
    required String contactName,
    required String petOrTopicName,
    required YagoPetStatus status,
    required bool isPostContext,
    required int? aiSimilarity,
  }) {
    if (isPostContext) {
      return [
        '¡Hola $contactName! Te escribo por tu publicación en el feed comunitario.',
        'Me gustaría hacerte una consulta sobre lo que compartiste.',
        '¿Podemos coordinar por acá?',
      ];
    }

    if (status == YagoPetStatus.mating) {
      return [
        '¡Hola $contactName! Vi la publicación de $petOrTopicName para apareamiento responsable.',
        'Me gustaría conversar sobre antecedentes sanitarios y coordinar un encuentro.',
        '¿En qué zona de la ciudad se encuentran?',
      ];
    }

    final isLost = status == YagoPetStatus.lost;
    return [
      if (aiSimilarity != null)
        '¡Hola $contactName! Analicé una foto con la Cámara IA de Yago y dio un $aiSimilarity% de similitud con $petOrTopicName.',
      isLost
          ? '¡Hola! Acabo de avistar a $petOrTopicName en la vía pública.'
          : '¡Hola! Creo que la mascota que encontraste es la mía.',
      '¿Podemos conversar por acá para confirmar los datos?',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockDataService(),
      builder: (context, _) {
        final currentChat =
            MockDataService().getChatById(_conversation.id) ?? _conversation;
        final messages = currentChat.messages;
        final currentUser = AuthService().currentUser;
        final currentUid = currentUser?.uid ?? 'local-user';
        final currentUserName = currentUser?.displayName;

        // Si llegaron mensajes nuevos mientras estamos con la app en primer plano en la pantalla, marcarlos como leídos
        final lifecycleState = WidgetsBinding.instance.lifecycleState;
        final isAppResumed =
            lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
        if (currentChat.unreadCount > 0 && isAppResumed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              MockDataService().markChatAsRead(currentChat.id);
            }
          });
        }

        final isPostContext = currentChat.isPostContext;
        final activeItemId = isPostContext
            ? (currentChat.relatedPostId ?? currentChat.relatedPetId)
            : currentChat.relatedPetId;
        final activePet = !isPostContext
            ? (_resolvedPet?.id == activeItemId
                ? _resolvedPet
                : MockDataService().getPetById(activeItemId))
            : null;
        final activePost = isPostContext
            ? (_resolvedPost?.id == activeItemId
                ? _resolvedPost
                : MockDataService().getFeedPostById(activeItemId))
            : null;

        final status = activePet?.status ?? currentChat.relatedPetStatus;
        final resolvedName = currentChat.displayContactNameFor(
          currentUid,
          currentUserName: currentUserName,
        );
        final contactName = resolvedName.isNotEmpty
            ? resolvedName
            : (activePet?.contactName.isNotEmpty == true
                ? activePet!.contactName
                : 'Responsable del reporte');
        final contactAvatar = currentChat.displayContactAvatarFor(
          currentUid,
          currentUserName: currentUserName,
        );
        final isArchived = currentChat.isArchivedFor(currentUid);
        final roleSubtitle = _resolveRoleSubtitle(status, isPostContext);
        final aiSimilarity = currentChat.aiSimilarityPercentage ??
            widget.aiSimilarityPercentage;
        final petOrTopicName = currentChat.relatedPetName.isNotEmpty
            ? currentChat.relatedPetName
            : (activePet?.name.isNotEmpty == true
                ? activePet!.name
                : 'la mascota');

        final quickAlertMessages = _buildQuickAlertMessages(
          contactName: contactName,
          petOrTopicName: petOrTopicName,
          status: status,
          isPostContext: isPostContext,
          aiSimilarity: aiSimilarity,
        );

        final contextImageUrl = currentChat.relatedPetImage.isNotEmpty
            ? currentChat.relatedPetImage
            : (activePet?.imageUrl ?? activePost?.imageUrl ?? '');
        final contextSubtitle = isPostContext
            ? (currentChat.relatedPostSnippet ??
                activePost?.displayContent ??
                'Publicación del feed comunitario')
            : [
                if ((currentChat.relatedPetBreed.isNotEmpty
                        ? currentChat.relatedPetBreed
                        : (activePet?.breed ?? ''))
                    .trim()
                    .isNotEmpty)
                  (currentChat.relatedPetBreed.isNotEmpty
                          ? currentChat.relatedPetBreed
                          : (activePet?.breed ?? ''))
                      .trim(),
                if ((currentChat.relatedPetLocation.isNotEmpty
                        ? currentChat.relatedPetLocation
                        : (activePet?.location ?? ''))
                    .trim()
                    .isNotEmpty)
                  (currentChat.relatedPetLocation.isNotEmpty
                          ? currentChat.relatedPetLocation
                          : (activePet?.location ?? ''))
                      .trim(),
              ].join(' · ');

        final effectiveContexts = currentChat.effectiveContexts;
        final hasMessagesForActiveContext = messages.isNotEmpty &&
            messages.any(
              (m) =>
                  m.contextItemId == activeItemId ||
                  (m.contextItemId == null && effectiveContexts.length <= 1),
            );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
              onPressed: () => Navigator.of(context).pop(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                if (contactAvatar != null && contactAvatar.isNotEmpty)
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryTint,
                    backgroundImage: NetworkImage(contactAvatar),
                    onBackgroundImageError: (_, _) {},
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryTint,
                    child: Text(
                      contactName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        roleSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'Opciones de conversación',
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
                onSelected: (val) => _handleChatMenuAction(val, currentChat),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isArchived ? 'Desarchivar chat' : 'Archivar chat',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(
                          Icons.cleaning_services_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10),
                        Text('Vaciar chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Eliminar chat',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Denunciar chat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              const Divider(height: 1, color: AppColors.border),

              // ─── Selector de contextos si se habló por múltiples animales/publicaciones ───
              if (effectiveContexts.length > 1) ...[
                Container(
                  key: const Key('chat_context_selector_bar'),
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Temas en esta conversación (${effectiveContexts.length}):',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: effectiveContexts.map((topic) {
                            final isSelected =
                                topic.itemId == activeItemId &&
                                    topic.isPostContext == isPostContext;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                key: Key('chat_context_chip_${topic.itemId}'),
                                borderRadius: AppRadius.fullBorder,
                                onTap: () => _selectTopicContext(topic),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceSecondary,
                                    borderRadius: AppRadius.fullBorder,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        topic.isPostContext
                                            ? Icons.forum_outlined
                                            : Icons.pets_rounded,
                                        size: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        topic.title,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
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
                const Divider(height: 1, color: AppColors.border),
              ],

              // ─── 1. Tarjeta resumida de la publicación o reporte (HU-S4-04) ───
              Material(
                key: const Key('chat_context_summary_card'),
                color: AppColors.surfaceSecondary,
                child: InkWell(
                  onTap: _openContextTarget,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        if (contextImageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 46,
                              height: 46,
                              child: YagoPetImage(
                                imageUrl: contextImageUrl,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              isPostContext
                                  ? Icons.forum_outlined
                                  : Icons.pets_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      isPostContext
                                          ? 'Publicación de $contactName'
                                          : petOrTopicName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isPostContext)
                                    YagoPostCategoryBadge(
                                      category: currentChat.relatedPostCategory ??
                                          activePost?.categoryTag ??
                                          'Comunidad',
                                    )
                                  else
                                    YagoStatusBadge(status: status),
                                  if (aiSimilarity != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.reunitedBg,
                                        borderRadius: AppRadius.fullBorder,
                                      ),
                                      child: Text(
                                        '$aiSimilarity% IA',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.reunitedText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                contextSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // ─── 2. Mensajes del chat y respuestas rápidas de aviso (HU-S4-03) ───
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  children: [
                    // Aviso de seguridad de canal privado
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Chat directo y privado con $contactName. '
                              'Usa este canal para compartir pistas y mantener una comunicación segura.',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (messages.isNotEmpty) ...[
                      ...messages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final msg = entry.value;
                        final prevMsg = idx > 0 ? messages[idx - 1] : null;
                        final msgTopicId = msg.contextItemId ?? '';
                        final prevTopicId = prevMsg?.contextItemId ?? '';
                        final msgTopicTitle = (msg.contextTitle ?? '').trim();
                        final showTopicHeader = msgTopicTitle.isNotEmpty &&
                            (idx == 0 ? effectiveContexts.length > 1 : msgTopicId != prevTopicId);

                        final isMe = msg.senderId == currentUid;
                        final hasImage =
                            msg.imageUrl != null && msg.imageUrl!.isNotEmpty;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showTopicHeader)
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 10,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSecondary,
                                    borderRadius: AppRadius.fullBorder,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        msg.contextIsPost == true
                                            ? Icons.forum_outlined
                                            : Icons.pets_rounded,
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Conversación sobre $msgTopicTitle',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.78,
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : Colors.white,
                                  border: isMe
                                      ? null
                                      : Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isMe && msg.senderName.isNotEmpty) ...[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 3),
                                          child: Text(
                                            msg.senderName,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (hasImage) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          height: 150,
                                          width: double.infinity,
                                          child: YagoPetImage(
                                            imageUrl: msg.imageUrl!,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (msg.text.isNotEmpty)
                                        const SizedBox(height: 8),
                                    ],
                                    if (msg.text.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          msg.text,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13.5,
                                            color: isMe
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(msg.sentAt),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10.5,
                                            color: isMe
                                                ? Colors.white.withValues(alpha: 0.75)
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all_rounded,
                                            size: 13,
                                            color: Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],

                    if (!hasMessagesForActiveContext) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          top: messages.isNotEmpty ? 8 : 0,
                          bottom: 8,
                        ),
                        child: Text(
                          effectiveContexts.length > 1
                              ? 'MENSAJES RÁPIDOS DE AVISO ($petOrTopicName)'
                              : 'MENSAJES RÁPIDOS DE AVISO',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...quickAlertMessages.map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _sendMessage(suggestion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12.5,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.send_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Vista previa de foto adjunta pendiente (HU-S4-03) ──────────
              if (_pendingImageUrl != null && _pendingImageUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: YagoPetImage(
                            imageUrl: _pendingImageUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Foto adjunta lista para enviar',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Quitar foto adjunta',
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _pendingImageUrl = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // ─── 3. Barra de escritura de mensaje directo (HU-S4-03) ───────
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Tooltip(
                        message: 'Adjuntar foto',
                        child: Material(
                          color: AppColors.surfaceSecondary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _showAttachmentSheet,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLength: 500,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText:
                                'Escribe un mensaje para $contactName...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              color: AppColors.subtle,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceSecondary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Enviar mensaje',
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _sendMessage,
                            child: const Padding(
                              padding: EdgeInsets.all(11),
                              child: Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
