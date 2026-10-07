import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../models/feed_post.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';
import 'create_post_screen.dart';

class FeedTab extends StatefulWidget {
  final VoidCallback? onGoToSearch;
  final VoidCallback? onGoToCreateReport;

  const FeedTab({super.key, this.onGoToSearch, this.onGoToCreateReport});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  // Filtro activo: 0 = Todos, 1 = Perdidas, 2 = Encontradas, 3 = Reunidas, 4 = Apareamiento, 5 = Comunidad
  int _selectedFilterIndex = 0;
  bool _isFabVisible = true;
  final Set<String> _hiddenPostIds = {};

  final List<String> _filters = [
    'Todos',
    'Perdidas',
    'Encontradas',
    'Reunidas',
    'Apareamiento',
    'Comunidad',
  ];

  @override
  void initState() {
    super.initState();
    MockDataService().refreshFromFirestore().catchError((_) {});
  }

  DateTime _getItemDate(dynamic item) {
    if (item is Pet) {
      return item.date;
    } else if (item is FeedPost) {
      return item.createdAt ?? extractDateFromId(item.id) ?? DateTime(2020);
    }
    return DateTime(2020);
  }

  List<dynamic> _getFeedItems() {
    final allPets = MockDataService().getAllPets();
    final communityPosts = MockDataService().getCommunityPosts();

    List<dynamic> items;
    switch (_selectedFilterIndex) {
      case 1:
        items = allPets.where((pet) => pet.status == YagoPetStatus.lost).toList();
        break;
      case 2:
        items = allPets.where((pet) => pet.status == YagoPetStatus.found).toList();
        break;
      case 3:
        items = allPets.where((pet) => pet.status == YagoPetStatus.reunited).toList();
        break;
      case 4:
        items = allPets.where((pet) => pet.status == YagoPetStatus.mating).toList();
        break;
      case 5:
        // Filtrar por Comunidad: incluye tanto reportes comunitarios como publicaciones y consejos
        final communityPets = allPets
            .where((pet) => pet.status == YagoPetStatus.community)
            .toList();
        items = [...communityPets, ...communityPosts];
        break;
      default:
        // Feed principal (Todos): integra publicaciones y reportes activos (excluyendo mascotas ya recuperadas/resueltas)
        final activePets = allPets.where((pet) => pet.status != YagoPetStatus.reunited).toList();
        items = [...activePets, ...communityPosts];
        break;
    }

    // Filtrar publicaciones ocultadas temporalmente por el usuario
    if (_hiddenPostIds.isNotEmpty) {
      items.removeWhere((item) {
        final id = item is Pet ? item.id : (item is FeedPost ? item.id : '');
        return _hiddenPostIds.contains(id);
      });
    }

    // Ordenamiento estrictamente cronológico (las más recientes arriba)
    items.sort((a, b) => _getItemDate(b).compareTo(_getItemDate(a)));
    return items;
  }

  void _openCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          onPostCreated: () {
            setState(() {});
          },
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openTopFilterModal() {
    int tempFilterIndex = _selectedFilterIndex;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filtros',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Align(
              alignment: Alignment.topCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera del modal con botón de cierre
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Filtros del feed',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 22,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => Navigator.pop(modalContext),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'Categoría y Estado',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Opciones de filtro en chips interactivos
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_filters.length, (index) {
                              final isSelected = tempFilterIndex == index;
                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    tempFilterIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : const Color(0xFFEFF3F4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _filters[index],
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),

                          // Botones de acción: Aplicar y Limpiar
                          Row(
                            children: [
                              if (tempFilterIndex != 0)
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: YagoButton(
                                      variant: YagoButtonVariant.secondary,
                                      text: 'Limpiar',
                                      onPressed: () {
                                        setState(() {
                                          _selectedFilterIndex = 0;
                                        });
                                        Navigator.pop(modalContext);
                                      },
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: YagoButton(
                                  text: 'Aplicar filtros',
                                  onPressed: () {
                                    setState(() {
                                      _selectedFilterIndex = tempFilterIndex;
                                    });
                                    Navigator.pop(modalContext);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96.0),
        child: AnimatedScale(
          scale: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 240),
          curve: _isFabVisible ? Curves.easeOutBack : Curves.easeInBack,
          child: AnimatedOpacity(
            opacity: _isFabVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: SizedBox(
              width: 52,
              height: 52,
              child: FloatingActionButton(
                heroTag: 'createPostFab',
                onPressed: _isFabVisible ? _openCreatePost : null,
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: const CircleBorder(),
                tooltip: 'Crear publicación',
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: MockDataService(),
        builder: (context, _) {
          final feedItems = _getFeedItems();
          return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isFabVisible) {
              setState(() => _isFabVisible = false);
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isFabVisible) {
              setState(() => _isFabVisible = true);
            }
          }
          return false;
        },
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await MockDataService().refreshFromFirestore();
            if (mounted) {
              setState(() {});
            }
          },
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Encabezado que desaparece al hacer scroll hacia abajo
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 16,
              centerTitle: false,
              shape: const Border(
                bottom: BorderSide(color: AppColors.feedDivider, width: 1),
              ),
              title: const Row(
                children: [
                  YagoLogoIcon(size: 30),
                  SizedBox(width: 8),
                  Text(
                    'Yago',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              actions: [
                // Botón de filtros con indicador de filtro activo
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                      if (_selectedFilterIndex != 0)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'Filtrar publicaciones',
                  onPressed: _openTopFilterModal,
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Contenido según filtro
            if (feedItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets_outlined,
                        size: 56,
                        color: AppColors.subtle,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'No hay publicaciones en esta categoría',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Prueba seleccionando otro filtro o publica un nuevo reporte.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = feedItems[index];

                    // Publicaciones comunitarias / consejos
                    if (item is FeedPost) {
                      return _buildCommunityPostCard(item);
                    }

                    // Reportes y fichas de mascotas
                    final pet = item as Pet;
                    final isBookmarked =
                        MockDataService().isBookmarked(pet.id);
                    return PetCard(
                      name: pet.name,
                      details: pet.detailsSummary,
                      locationAndTime: pet.locationAndTime,
                      imageUrl: pet.imageUrl,
                      status: pet.status,
                      tags: pet.tags,
                      storyText: pet.storyText,
                      description: pet.description,
                      optionsMenu: _buildPostOptionsMenu(context, pet: pet),
                      authorName: pet.status == YagoPetStatus.community
                          ? 'Equipo Yago'
                          : (pet.contactName.isNotEmpty
                              ? pet.contactName
                              : 'Comunidad Yago'),
                      authorHandle: pet.status == YagoPetStatus.community
                          ? '@yago.app'
                          : '@${pet.contactName.toLowerCase().replaceAll(' ', '').replaceAll('.', '')}',
                      commentsCount: 8 + (pet.name.length * 2),
                      sharesCount: 15 + (pet.name.length * 3),
                      likesCount: 95 + (pet.name.length * 14),
                      viewsCount: '${15 + pet.name.length * 2} mil',
                      imagesCount: 2 + (pet.name.length % 3),
                      isBookmarked: isBookmarked,
                      onBookmarkTap: () {
                        setState(() {
                          MockDataService().toggleBookmark(pet.id);
                        });
                      },
                      onContactTap: () => _showContactModal(context, pet),
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => PetDetailScreen(pet: pet),
                              ),
                            )
                            .then((_) => setState(() {}));
                      },
                    );
                  },
                  childCount: feedItems.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 85),
            ),
          ],
          ),
        ),
      );
    },
  ),
);
}

  void _showContactModal(BuildContext context, Pet pet) {
    final isCommunity = pet.status == YagoPetStatus.community;
    final contactTitle = isCommunity
        ? 'Equipo Yago'
        : (pet.contactName.isNotEmpty ? pet.contactName : 'Dueño / Reportante');
    final contactSubtitle = isCommunity
        ? 'Equipo oficial de la comunidad Yago'
        : 'Reportante de ${pet.name}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isCommunity)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const YagoLogoIcon(size: 26),
                      )
                    else
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 26,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  contactTitle,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCommunity) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            contactSubtitle,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: YagoButton(
                    text: isCommunity
                        ? 'Enviar mensaje directo al equipo de Yago'
                        : 'Enviar mensaje directo a ${pet.contactName.isNotEmpty ? pet.contactName.split(' ').first : 'Dueño'}',
                    icon: const Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCommunity
                                ? 'Mensaje directo iniciado con el Equipo de Yago'
                                : 'Mensaje directo iniciado con ${pet.contactName}',
                          ),
                          backgroundColor: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: YagoButton(
                    variant: YagoButtonVariant.outline,
                    text: 'Llamar al teléfono (${pet.contactPhone})',
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Llamando a ${pet.contactPhone}...'),
                          backgroundColor: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityPostCard(FeedPost post) {
    final isYagoOfficial = post.authorName == 'Comunidad Yago' ||
        post.authorName == 'Equipo Yago' ||
        post.authorAvatar == null;
    final category = post.categoryTag;
    final cleanText = post.displayContent;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.feedDivider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.authorAvatar != null)
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.community.withValues(alpha: 0.12),
              backgroundImage: NetworkImage(post.authorAvatar!),
              onBackgroundImageError: (_, _) {},
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(5),
              child: const YagoLogoIcon(size: 24),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isYagoOfficial) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                          if (category != null) ...[
                            const SizedBox(width: 6),
                            YagoPostCategoryBadge(category: category),
                          ],
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '· ${formatTimeAgo(post.createdAt ?? extractDateFromId(post.id), fallback: post.timeAgo)}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.twitterHandle,
                                fontSize: 12.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildPostOptionsMenu(context, post: post),
                  ],
                ),
                const SizedBox(height: 6),
                _buildPostFormattedContent(cleanText, category),
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  YagoPetImage(
                    imageUrl: post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniAction(
                      Icons.chat_bubble_outline_rounded,
                      '${post.commentsCount}',
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          MockDataService().togglePostLike(post.id);
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                            color: post.isLiked
                                ? AppColors.likeRed
                                : AppColors.twitterAction,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: post.isLiked
                                  ? AppColors.likeRed
                                  : AppColors.twitterAction,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.ios_share_rounded,
                      size: 18,
                      color: AppColors.twitterAction,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.twitterAction),
        const SizedBox(width: 5),
        Text(
          count,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.twitterAction,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPostFormattedContent(String content, String? category) {
    if (category == 'Consejo') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.communityBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: AppColors.communityText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consejo para la comunidad',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.communityText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (category == 'Reencuentro') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.reunitedBg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.reunited.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.reunitedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 16,
                color: AppColors.reunitedText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historia de reencuentro',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.reunitedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      content,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        height: 1.35,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPostOptionsMenu(BuildContext context, {FeedPost? post, Pet? pet}) {
    final isReport = pet != null;
    final postId = pet?.id ?? post?.id ?? '';
    final content = pet?.description ?? post?.displayContent ?? post?.content ?? '';

    final currentUser = AuthService().currentUser;
    final currentUserId = currentUser?.uid;
    final currentUserName = currentUser?.displayName?.trim().toLowerCase();

    final isOwner = isReport
        ? (pet.isUserOwner ||
            (currentUserId != null && pet.ownerId == currentUserId) ||
            (currentUserName != null &&
                currentUserName.isNotEmpty &&
                pet.contactName.trim().toLowerCase() == currentUserName))
        : ((currentUserId != null && post?.authorId == currentUserId) ||
            (currentUserName != null &&
                currentUserName.isNotEmpty &&
                post?.authorName.trim().toLowerCase() == currentUserName));

    return SizedBox(
      width: 24,
      height: 24,
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_horiz_rounded,
          size: 19,
          color: AppColors.twitterAction,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 16,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        onSelected: (value) async {
          if (value == 'copy') {
            await Clipboard.setData(ClipboardData(text: content));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Texto copiado al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else if (value == 'share') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enlace copiado al portapapeles'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (value == 'reunited' && pet != null) {
            _confirmMarkReunited(context, pet);
          } else if (value == 'delete') {
            _confirmDeletePost(context, postId: postId, pet: pet);
          } else if (value == 'report') {
            _confirmReportPost(context, isReport: isReport);
          } else if (value == 'hide') {
            setState(() {
              _hiddenPostIds.add(postId);
            });
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Publicación oculta'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 2500),
                action: SnackBarAction(
                  label: 'Deshacer',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    setState(() {
                      _hiddenPostIds.remove(postId);
                    });
                  },
                ),
              ),
            );
          }
        },
        itemBuilder: (ctx) => [
          const PopupMenuItem<String>(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy_rounded, size: 18, color: AppColors.textPrimary),
                SizedBox(width: 10),
                Expanded(child: Text('Copiar texto')),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_outlined, size: 18, color: AppColors.textPrimary),
                SizedBox(width: 10),
                Expanded(child: Text('Compartir')),
              ],
            ),
          ),
          if (isOwner && isReport && pet.status != YagoPetStatus.reunited)
            const PopupMenuItem<String>(
              value: 'reunited',
              child: Row(
                children: [
                  Icon(Icons.celebration_outlined, size: 18, color: AppColors.reunited),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Marcar como caso resuelto',
                      style: TextStyle(color: AppColors.reunited, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          if (!isOwner) ...[
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'hide',
              child: Row(
                children: [
                  Icon(Icons.visibility_off_outlined, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Expanded(child: Text('Ocultar publicación')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, size: 18, color: AppColors.error),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Reportar publicación',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isOwner) ...[
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isReport ? 'Eliminar reporte' : 'Eliminar publicación',
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReportPost(BuildContext context, {required bool isReport}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: const Text('¿Reportar publicación?'),
        content: const Text(
          'Si consideras que esta publicación contiene información falsa, spam o lenguaje inapropiado, nuestro equipo de moderación la revisará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte enviado a moderación. Gracias por ayudar a cuidar la comunidad.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, {required String postId, Pet? pet}) {
    final isReport = pet != null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: Text(isReport ? '¿Eliminar reporte?' : '¿Eliminar publicación?'),
        content: Text(
          isReport
              ? '¿Estás seguro de que deseas eliminar este reporte? Se borrará definitivamente del feed comunitario.'
              : '¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                if (pet != null) {
                  await MockDataService().deletePet(pet.id);
                } else {
                  await MockDataService().deleteCommunityPost(postId);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isReport
                            ? 'Reporte eliminado correctamente.'
                            : 'Publicación eliminada correctamente.',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmMarkReunited(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: const Text('¿Marcar como caso resuelto?'),
        content: Text(
          'Se actualizará el estado de "${pet.name}" a reunida y se notificará a la comunidad.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.reunited,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              MockDataService().markAsReunited(pet.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Caso marcado como reunido con éxito! 🎉'),
                  backgroundColor: AppColors.reunited,
                ),
              );
            },
            child: const Text('Marcar reunida'),
          ),
        ],
      ),
    );
  }
}
