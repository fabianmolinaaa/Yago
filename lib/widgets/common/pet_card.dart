import 'package:flutter/material.dart';

import '../../utils/design_system.dart';
import 'yago_badge.dart';
import 'yago_logo.dart';
import 'yago_pet_image.dart';


/// Card de publicación de mascota con diseño estilo Instagram/Twitter optimizado para Yago.
class PetCard extends StatefulWidget {
  final String name;
  final String details; // ej: "Lhasa Apso · Hembra · 3 años"
  final String locationAndTime; // ej: "Palermo, CABA · Hace 2 horas"
  final String imageUrl;
  final YagoPetStatus status;
  final List<String> tags;
  final String? storyText;
  final String? description;
  final String? authorName;
  final String? authorHandle;
  final String? authorAvatar;
  final int imagesCount;
  final int commentsCount;
  final int sharesCount;
  final int likesCount;
  final String viewsCount;
  final bool isBookmarked;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onContactTap;
  final Widget? optionsMenu;

  const PetCard({
    super.key,
    required this.name,
    required this.details,
    required this.locationAndTime,
    required this.imageUrl,
    required this.status,
    this.tags = const [],
    this.storyText,
    this.description,
    this.authorName,
    this.authorHandle,
    this.authorAvatar,
    this.imagesCount = 3,
    this.commentsCount = 8,
    this.sharesCount = 24,
    this.likesCount = 142,
    this.viewsCount = '1.8 mil',
    this.isBookmarked = false,
    this.isLiked = false,
    this.onTap,
    this.onBookmarkTap,
    this.onLikeTap,
    this.onShareTap,
    this.onCommentTap,
    this.onContactTap,
    this.optionsMenu,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _likes = widget.likesCount;
  }

  void _handleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    widget.onLikeTap?.call();
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)} mil';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final isCommunity = widget.status == YagoPetStatus.community;
    final author = isCommunity
        ? 'Equipo Yago'
        : (widget.authorName ?? 'Comunidad Yago');

    // Separar ubicación y tiempo si viene con " · " (ej: "Palermo, CABA · Hace 2 horas")
    final parts = widget.locationAndTime.split(' · ');
    final location = parts.isNotEmpty ? parts[0] : widget.locationAndTime;
    final time = parts.length > 1 ? parts[1] : 'Reciente';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.feedDivider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. Arriba del post ──────────────────────────────────────────
          // Imagen del usuario - nombre (sin el user) - etiqueta de la publicación
          // A la derecha del todo: horario - Icono de mascota (botón que abre modal con info de la mascota)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                if (isCommunity)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const YagoLogoIcon(size: 20),
                  )
                else
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundImage: widget.authorAvatar != null
                        ? (widget.authorAvatar!.startsWith('assets/')
                            ? AssetImage(widget.authorAvatar!) as ImageProvider
                            : NetworkImage(widget.authorAvatar!))
                        : null,
                    onBackgroundImageError: widget.authorAvatar != null ? (_, _) {} : null,
                    child: widget.authorAvatar == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 20,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                const SizedBox(width: 9),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          author,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCommunity) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                YagoStatusBadge(status: widget.status),
                const Spacer(),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.twitterHandle,
                  ),
                ),
                if (widget.optionsMenu != null) ...[
                  const SizedBox(width: 4),
                  widget.optionsMenu!,
                ],
              ],
            ),
          ),

          // ─── 2. Detalle y texto del post ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              left: 14.0,
              right: 14.0,
              bottom: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.details,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (widget.description != null &&
                    widget.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.description!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                // Chip de ubicación: fondo totalmente negro, icono y texto totalmente blanco
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── 3. [Imagen] que ocupa TODO el ancho de la pantalla ─────────
          // Con contador de cuántas imágenes tiene la publicación superpuesto abajo al centro
          GestureDetector(
            onTap: widget.onTap,
            child: Stack(
              children: [
                YagoPetImage(
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholderHeight: 220,
                ),
                // Contador de cuántas imágenes superpuesto abajo en el centro
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '1/${widget.imagesCount}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── 4. Abajo de la imagen: botones de acción ─────────────────────
          // Comentarios, Me gusta, Mensaje directo para contactar, Compartir
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Comentarios
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: _formatCount(widget.commentsCount),
                  color: AppColors.twitterAction,
                  onTap: widget.onCommentTap,
                ),

                // Apoyo / Like
                _buildActionButton(
                  icon: _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: _formatCount(_likes),
                  color: _liked ? AppColors.likeRed : AppColors.twitterAction,
                  onTap: _handleLike,
                ),

                // Contactar con el dueño por mensaje directo (icono DM)
                Tooltip(
                  message: 'Enviar mensaje directo al dueño',
                  child: GestureDetector(
                    onTap: widget.onContactTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Icon(
                        Icons.mail_outline_rounded,
                        size: 20,
                        color: AppColors.twitterAction,
                      ),
                    ),
                  ),
                ),

                // Compartir
                Tooltip(
                  message: 'Compartir publicación',
                  child: GestureDetector(
                    onTap: widget.onShareTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Icon(
                        Icons.ios_share_rounded,
                        size: 19,
                        color: AppColors.twitterAction,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

