import 'package:flutter/material.dart';
import '../../models/chat_conversation.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import 'direct_chat_screen.dart';

/// Bandeja de chats directos 1 a 1 ordenados cronológicamente (HU-S4-01, HU-S4-04, HU-S4-05).
class DirectChatsTab extends StatefulWidget {
  final VoidCallback? onGoToReports;
  final VoidCallback? onGoToFeed;

  const DirectChatsTab({
    super.key,
    this.onGoToReports,
    this.onGoToFeed,
  });

  @override
  State<DirectChatsTab> createState() => _DirectChatsTabState();
}

class _DirectChatsTabState extends State<DirectChatsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0;
  bool _isSearchVisible = false;

  static const List<String> _filters = [
    'Todos',
    'No leídos',
    'Reportes',
    'Comunidad',
    'Archivados',
  ];

  @override
  void initState() {
    super.initState();
    MockDataService().ensureUserSubscriptions();
    MockDataService().refreshFromFirestore().catchError((_) {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DirectChatConversation> _getFilteredConversations(
    List<DirectChatConversation> activeChats,
    List<DirectChatConversation> archivedChats,
  ) {
    final bool isArchivedTab = _selectedFilterIndex == 4;
    final List<DirectChatConversation> baseList =
        isArchivedTab ? archivedChats : activeChats;
    final q = _searchQuery.trim().toLowerCase();

    return baseList.where((chat) {
      if (_selectedFilterIndex == 1 && !chat.hasUnread) {
        return false;
      }
      if (_selectedFilterIndex == 2 && chat.isPostContext) {
        return false;
      }
      if (_selectedFilterIndex == 3 && !chat.isPostContext) {
        return false;
      }

      if (q.isNotEmpty) {
        final matchesContact = chat.contactName.toLowerCase().contains(q);
        final matchesPet = chat.relatedPetName.toLowerCase().contains(q);
        final matchesMsg = chat.lastMessage.toLowerCase().contains(q);
        final matchesSnippet =
            (chat.relatedPostSnippet ?? '').toLowerCase().contains(q);
        final matchesLocation =
            chat.relatedPetLocation.toLowerCase().contains(q);
        return matchesContact ||
            matchesPet ||
            matchesMsg ||
            matchesSnippet ||
            matchesLocation;
      }

      return true;
    }).toList();
  }

  String _formatChatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Ahora';
    }
    if (diff.inMinutes < 60 && now.day == dt.day) {
      return 'Hace ${diff.inMinutes}m';
    }
    if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays == 1 ||
        (diff.inHours < 48 && now.day != dt.day && (now.day - dt.day).abs() == 1)) {
      return 'Ayer';
    }
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }

  void _openConversation(DirectChatConversation chat) {
    MockDataService().markChatAsRead(chat.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DirectChatScreen(conversation: chat),
      ),
    );
  }

  void _handleChatMenuAction(String action, DirectChatConversation chat) {
    if (action == 'archive') {
      final archived = MockDataService().toggleArchiveChat(chat.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              archived ? 'Chat archivado' : 'Chat desarchivado',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
    } else if (action == 'clear') {
      MockDataService().clearChatForUser(chat.id);
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
      MockDataService().deleteChatConversation(chat.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Chat eliminado'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  ({String label, Color color, Color bgColor}) _resolveStatusMeta(
    DirectChatConversation chat,
  ) {
    if (chat.isPostContext) {
      final cat = chat.relatedPostCategory ?? 'Comunidad';
      return (
        label: cat,
        color: AppColors.communityText,
        bgColor: AppColors.communityBg,
      );
    }
    switch (chat.relatedPetStatus) {
      case YagoPetStatus.lost:
      case YagoPetStatus.urgent:
        return (
          label: 'Perdido',
          color: AppColors.lostText,
          bgColor: AppColors.lostBg,
        );
      case YagoPetStatus.found:
        return (
          label: 'Encontrado',
          color: AppColors.foundText,
          bgColor: AppColors.foundBg,
        );
      case YagoPetStatus.reunited:
        return (
          label: 'Reunido',
          color: AppColors.reunitedText,
          bgColor: AppColors.reunitedBg,
        );
      case YagoPetStatus.mating:
        return (
          label: 'Apareamiento',
          color: AppColors.matingText,
          bgColor: AppColors.matingBg,
        );
      case YagoPetStatus.community:
      case YagoPetStatus.isNew:
        return (
          label: 'Comunidad',
          color: AppColors.communityText,
          bgColor: AppColors.communityBg,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: MockDataService(),
        builder: (context, _) {
          final activeChats = MockDataService().getChatConversations();
          final archivedChats = MockDataService().getChatConversations(
            onlyArchived: true,
          );
          final filteredChats = _getFilteredConversations(
            activeChats,
            archivedChats,
          );
          final totalUnread = MockDataService().getTotalUnreadChatCount();
          final unreadConvs = MockDataService().getUnreadConversationsCount();
          final archivedCount = archivedChats.length;

          return CustomScrollView(
            slivers: [
              // ─── 1. SliverAppBar: Encabezado de Bandeja de Chats Directos ──
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: AppColors.feedDivider,
                    height: 1,
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Chat Directo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (totalUnread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        key: const Key('inbox_header_unread_badge'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.fullBorder,
                        ),
                        child: Text(
                          '$totalUnread',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  if (totalUnread > 0)
                    IconButton(
                      tooltip: 'Marcar todos como leídos',
                      icon: const Icon(
                        Icons.done_all_rounded,
                        size: 21,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        MockDataService().markAllChatsAsRead();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Todos los mensajes fueron marcados como leídos',
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  IconButton(
                    tooltip: 'Buscar conversaciones',
                    icon: Icon(
                      _isSearchVisible
                          ? Icons.search_off_rounded
                          : Icons.search_rounded,
                      size: 22,
                      color: _searchQuery.isNotEmpty
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) {
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                ],
              ),

              // ─── 2. Barra de búsqueda expandible ─────────────────────────
              if (_isSearchVisible)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por contacto, mascota o mensaje...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: AppColors.muted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                    ),
                  ),
                ),

              // ─── 3. Filtros rápidos de bandeja ───────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: AppColors.feedDivider, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_filters.length, (index) {
                        final isSelected = _selectedFilterIndex == index;
                        final label = _filters[index];
                        final showUnreadCount = index == 1 && unreadConvs > 0;
                        final showArchivedCount =
                            index == 4 && archivedCount > 0;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: AppRadius.fullBorder,
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
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
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (showUnreadCount || showArchivedCount) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                        borderRadius: AppRadius.fullBorder,
                                      ),
                                      child: Text(
                                        showUnreadCount
                                            ? '$unreadConvs'
                                            : '$archivedCount',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // ─── 4. Listado cronológico de conversaciones o estado vacío ─
              if (filteredChats.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(
                    hasAnyChats:
                        activeChats.isNotEmpty || archivedChats.isNotEmpty,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10, bottom: 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chat = filteredChats[index];
                        return _buildConversationTile(chat);
                      },
                      childCount: filteredChats.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(DirectChatConversation chat) {
    final currentUser = AuthService().currentUser;
    final currentUid = currentUser?.uid ?? 'local-user';
    final currentUserName = currentUser?.displayName;
    final resolvedContactName = chat.displayContactNameFor(
      currentUid,
      currentUserName: currentUserName,
    );
    final resolvedAvatar = chat.displayContactAvatarFor(
      currentUid,
      currentUserName: currentUserName,
    );

    final hasUnread = chat.unreadCount > 0;
    final isArchived = chat.isArchivedFor(currentUid);
    final isOfficial = resolvedContactName == 'Equipo Yago' ||
        resolvedContactName == 'Comunidad Yago';
    final isFromMe = chat.lastMessageSenderId == currentUid &&
        chat.messages.isNotEmpty;
    final isCleared = chat.lastMessage == 'Chat vacío';
    final lastMsgDisplay = isCleared
        ? 'Chat vacío'
        : (isFromMe ? 'Tú: ${chat.lastMessage}' : chat.lastMessage);
    final statusMeta = _resolveStatusMeta(chat);
    final contextTitle = chat.isPostContext
        ? (chat.relatedPostSnippet ?? 'Publicación comunitaria')
        : chat.relatedPetName;

    return Container(
      key: Key('chat_tile_${chat.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: hasUnread
            ? AppColors.primaryTint.withValues(alpha: 0.45)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasUnread
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openConversation(chat),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ─── Avatar con miniatura superpuesta de la mascota/post ───
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (isOfficial)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.all(7),
                          child: const YagoLogoIcon(size: 28),
                        )
                      else if (resolvedAvatar != null &&
                          resolvedAvatar.isNotEmpty)
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryTint,
                          backgroundImage: NetworkImage(resolvedAvatar),
                          onBackgroundImageError: (_, _) {},
                        )
                      else
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            resolvedContactName.isNotEmpty
                                ? resolvedContactName.characters.first
                                    .toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (chat.relatedPetImage.isNotEmpty)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: YagoPetImage(
                                imageUrl: chat.relatedPetImage,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // ─── Bloque central ordenado en 3 niveles ──────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nivel 1: Nombre del contacto + Hora + Menú (3 puntitos)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    resolvedContactName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: hasUnread
                                          ? FontWeight.w800
                                          : FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isOfficial) ...[
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
                          const SizedBox(width: 6),
                          Text(
                            _formatChatTimestamp(chat.lastMessageAt),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              fontWeight:
                                  hasUnread ? FontWeight.w700 : FontWeight.w500,
                              color: hasUnread
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            width: 28,
                            height: 24,
                            child: PopupMenuButton<String>(
                              tooltip: 'Opciones de conversación',
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.mdBorder,
                              ),
                              onSelected: (val) =>
                                  _handleChatMenuAction(val, chat),
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
                                        isArchived
                                            ? 'Desarchivar chat'
                                            : 'Archivar chat',
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Nivel 2: Vista previa del último mensaje + Contador de no leídos
                      Row(
                        children: [
                          if (isFromMe && !isCleared) ...[
                            const Icon(
                              Icons.done_all_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              lastMsgDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontStyle: isCleared
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: hasUnread
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              key: Key('unread_badge_${chat.id}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.fullBorder,
                              ),
                              child: Text(
                                '${chat.unreadCount}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Nivel 3: Referencia limpia y compacta de la mascota o publicación (HU-S4-04)
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    chat.isPostContext
                                        ? Icons.forum_outlined
                                        : Icons.pets_rounded,
                                    size: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      contextTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusMeta.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusMeta.label,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusMeta.color,
                                    ),
                                  ),
                                  if (chat.aiSimilarityPercentage != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '· ${chat.aiSimilarityPercentage}% IA',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.reunitedText,
                                      ),
                                    ),
                                  ],
                                  if (chat.effectiveContexts.length > 1) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTint,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '+${chat.effectiveContexts.length - 1}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool hasAnyChats}) {
    final isFilteredEmpty =
        hasAnyChats && (_selectedFilterIndex != 0 || _searchQuery.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              isFilteredEmpty
                  ? Icons.filter_alt_off_outlined
                  : Icons.chat_bubble_outline_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isFilteredEmpty
                ? 'No hay conversaciones en este filtro'
                : 'Bandeja de chats directos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFilteredEmpty
                ? 'Prueba cambiando el filtro seleccionado o limpiando el término de búsqueda.'
                : 'Inicia un mensaje privado desde cualquier publicación del feed comunitario, ficha de reporte o coincidencia de la Cámara con IA para aportar pistas.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          if (isFilteredEmpty)
            YagoButton(
              text: 'Ver todas las conversaciones',
              variant: YagoButtonVariant.secondary,
              onPressed: () {
                setState(() {
                  _selectedFilterIndex = 0;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else ...[
            if (widget.onGoToReports != null)
              SizedBox(
                width: double.infinity,
                child: YagoButton(
                  text: 'Explorar reportes activos',
                  icon: const Icon(
                    Icons.campaign_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: widget.onGoToReports,
                ),
              ),
            if (widget.onGoToFeed != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: YagoButton(
                  variant: YagoButtonVariant.secondary,
                  text: 'Ir al feed comunitario',
                  icon: const Icon(
                    Icons.home_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: widget.onGoToFeed,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
