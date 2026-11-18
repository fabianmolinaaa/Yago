import 'package:flutter/material.dart';

import '../../models/chat_conversation.dart';
import '../../models/feed_post.dart';
import '../../models/moderation_report.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import 'yago_button.dart';
import 'yago_pet_image.dart';

/// Modal oficial del Design System de Yago para denunciar contenido falso, spam,
/// maltrato, estafas o mensajes indebidos (HU-S5-01 / Sprint 5).
class ReportContentModal extends StatefulWidget {
  final String targetType; // 'pet' | 'feed_post' | 'chat_message' | 'user'
  final String targetId;
  final String? targetTitle;
  final String? targetAuthorId;
  final String? targetAuthorName;
  final Pet? pet;
  final FeedPost? post;
  final DirectChatConversation? chat;

  const ReportContentModal({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.targetAuthorId,
    this.targetAuthorName,
    this.pet,
    this.post,
    this.chat,
  });

  /// Abre el modal de denuncia y retorna `true` si la denuncia fue enviada exitosamente.
  static Future<bool?> show(
    BuildContext context, {
    required String targetType,
    required String targetId,
    String? targetTitle,
    String? targetAuthorId,
    String? targetAuthorName,
    Pet? pet,
    FeedPost? post,
    DirectChatConversation? chat,
  }) {
    String computedTitle = targetTitle ?? '';
    String? computedAuthorId = targetAuthorId;
    String? computedAuthorName = targetAuthorName;

    if (pet != null) {
      if (computedTitle.isEmpty) {
        computedTitle = pet.name.isNotEmpty
            ? pet.name
            : (pet.hasKnownBreed ? pet.breed : 'Mascota reportada');
      }
      computedAuthorId ??= pet.ownerId;
      computedAuthorName ??= pet.contactName;
    } else if (post != null) {
      if (computedTitle.isEmpty) {
        computedTitle = post.content.length > 50
            ? '${post.content.substring(0, 50)}...'
            : post.content;
      }
      computedAuthorId ??= post.authorId;
      computedAuthorName ??= post.authorName;
    } else if (chat != null) {
      if (computedTitle.isEmpty) {
        computedTitle = 'Conversación con ${chat.contactName}';
      }
      computedAuthorId ??= chat.participantIds.isNotEmpty ? chat.participantIds.first : null;
      computedAuthorName ??= chat.contactName;
    }

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportContentModal(
        targetType: targetType,
        targetId: targetId,
        targetTitle: computedTitle,
        targetAuthorId: computedAuthorId,
        targetAuthorName: computedAuthorName,
        pet: pet,
        post: post,
        chat: chat,
      ),
    );
  }

  @override
  State<ReportContentModal> createState() => _ReportContentModalState();
}

class _ReportContentModalState extends State<ReportContentModal> {
  ModerationReasonOption? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String get _targetFriendlyName {
    switch (widget.targetType) {
      case 'pet':
        return 'este reporte de mascota';
      case 'feed_post':
        return 'esta publicación comunitaria';
      case 'chat_message':
      case 'user':
        return 'esta conversación';
      default:
        return 'este contenido';
    }
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final currentUser = AuthService().currentUser;
      final reporterId = currentUser?.uid ?? 'anonymous-user';
      final reporterName = currentUser?.displayName;
      final reporterEmail = currentUser?.email;

      final report = ModerationReport(
        id: '', // Se genera automáticamente en Firestore / Mock
        reporterId: reporterId,
        reporterName: reporterName,
        reporterEmail: reporterEmail,
        targetType: widget.targetType,
        targetId: widget.targetId,
        targetTitle: widget.targetTitle,
        targetAuthorId: widget.targetAuthorId,
        targetAuthorName: widget.targetAuthorName,
        reason: _selectedReason!.code,
        reasonTitle: _selectedReason!.title,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // 1. Guardar en Firestore
      final success = await FirestoreService().submitModerationReport(report);

      // 2. Sincronizar en MockDataService
      MockDataService().addModerationReport(report);

      if (mounted) {
        Navigator.of(context).pop(success);

        // Feedback visual amigable y tranquilizador para el usuario
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Denuncia recibida',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (widget.targetType == 'chat_message' ||
                                widget.targetType == 'user')
                            ? 'Gracias por cuidar la comunidad de Yago. Se bloqueó al usuario y se quitó el chat de tu bandeja.'
                            : 'Gracias por cuidar la comunidad de Yago. Nuestro equipo revisará $_targetFriendlyName.',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar la denuncia. Por favor intenta nuevamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final reasons = ModerationReasonOption.defaultOptions;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── 1. Indicador de arrastre ───
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ─── 2. Contenido scrolleable ───
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera con icono semántico
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: AppColors.error,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Denunciar a moderación',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Indica por qué consideras que $_targetFriendlyName no cumple con las normas de convivencia de Yago.',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Tarjeta de resumen de lo que se está reportando
                    const SizedBox(height: 16),
                    _buildTargetPreviewCard(),

                    const SizedBox(height: 20),
                    const Text(
                      'Motivo de la denuncia',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lista de opciones específicas del ecosistema Yago
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reasons.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final option = reasons[index];
                        final isSelected = _selectedReason == option;

                        return Material(
                          color: isSelected
                              ? AppColors.primaryTint
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _selectedReason = option;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      size: 19,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.description,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 11.5,
                                            color: AppColors.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.subtle,
                                        width: isSelected ? 5.5 : 1.5,
                                      ),
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Campo de texto para detalle opcional
                    const SizedBox(height: 16),
                    const Text(
                      'Detalle o información adicional (opcional)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      maxLength: 300,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Cuéntanos más detalles para ayudar al equipo de moderación a evaluar la situación con rapidez...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          color: AppColors.subtle,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Nota de privacidad y tranquilidad
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tu denuncia es 100% anónima. La otra persona no sabrá quién reportó su contenido.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ─── 3. Botones de acción ───
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: YagoButton(
                      text: 'Cancelar',
                      variant: YagoButtonVariant.secondary,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: YagoButton(
                      text: 'Enviar denuncia',
                      variant: YagoButtonVariant.destructive,
                      isLoading: _isSubmitting,
                      onPressed: _selectedReason == null || _isSubmitting
                          ? null
                          : _submitReport,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta compacta para dar contexto visual de qué se está denunciando
  Widget _buildTargetPreviewCard() {
    if (widget.pet != null) {
      final pet = widget.pet!;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: YagoPetImage(
                  imageUrl: pet.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name.isNotEmpty
                        ? pet.name
                        : (pet.hasKnownBreed ? pet.breed : 'Mascota reportada'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.status == YagoPetStatus.lost ? "Mascota perdida" : "Mascota encontrada"} · ${pet.location}',
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
      );
    }

    if (widget.post != null) {
      final post = widget.post!;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryTint,
              child: Icon(Icons.article_outlined, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.content,
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
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        widget.targetTitle ?? 'Elemento ID: ${widget.targetId}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
