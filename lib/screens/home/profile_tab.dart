import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/feed_post.dart';
import '../../models/pet.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../auth/login_screen.dart';
import '../pet_detail/pet_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onGoToCreateReport;

  const ProfileTab({super.key, this.onGoToCreateReport});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    MockDataService().refreshFromFirestore().catchError((_) {});
  }

  // Estado para likes interactivos dentro de las publicaciones del perfil
  final Set<String> _likedPostIds = {'user-post-1'};
  final Map<String, int> _postLikesCount = {
    'user-post-1': 18,
    'user-report-1': 45,
  };

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
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
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _toggleLike(String postId) {
    setState(() {
      if (_likedPostIds.contains(postId)) {
        _likedPostIds.remove(postId);
        _postLikesCount[postId] = (_postLikesCount[postId] ?? 1) - 1;
      } else {
        _likedPostIds.add(postId);
        _postLikesCount[postId] = (_postLikesCount[postId] ?? 0) + 1;
      }
    });
  }

  String _formatJoinDate(DateTime? dateTime) {
    if (dateTime == null) return 'Miembro de la comunidad';
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final monthIndex =
        (dateTime.month >= 1 && dateTime.month <= 12) ? dateTime.month - 1 : 0;
    return 'Se unió en ${months[monthIndex]} de ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final fallbackName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user?.email != null && user!.email!.trim().isNotEmpty
                ? user.email!.split('@').first
                : 'Usuario');
    final userEmail = user?.email ?? '';
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListenableBuilder(
      listenable: MockDataService(),
      builder: (context, _) {
        return StreamBuilder<UserModel?>(
      stream: user != null
          ? FirestoreService().streamUserProfile(user.uid)
          : Stream<UserModel?>.value(null),
      builder: (context, snapshot) {
        final userModel = snapshot.data;
        final userName = (userModel?.displayName != null &&
                userModel!.displayName.trim().isNotEmpty)
            ? userModel.displayName.trim()
            : fallbackName;
        final userPhoto = userModel?.photoUrl ??
            user?.photoURL ??
            MockDataService().userCustomPhotoUrl;
        final userBio = (userModel?.bio != null &&
                userModel!.bio!.trim().isNotEmpty)
            ? userModel.bio!.trim()
            : MockDataService().userBio;
        final userLocation = (userModel?.location != null &&
                userModel!.location!.trim().isNotEmpty)
            ? userModel.location!.trim()
            : MockDataService().userLocation;
        final userPhone = (userModel?.phoneNumber != null &&
                userModel!.phoneNumber!.trim().isNotEmpty)
            ? userModel.phoneNumber!.trim()
            : MockDataService().userPhone;
        final myReports = MockDataService().getMyReports();
        final userPosts = MockDataService().getMyPosts(
          userId: user?.uid,
          userName: userName,
        );
        final joinDate = user?.metadata.creationTime ?? userModel?.createdAt;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buscador de perfil'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBorder),
                  onSelected: (val) {
                    if (val == 'logout') {
                      _handleLogout(context);
                    } else if (val == 'share') {
                      _showShareSnackbar();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined,
                              size: 18, color: AppColors.textPrimary),
                          SizedBox(width: 10),
                          Text('Compartir perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              size: 18, color: AppColors.error),
                          SizedBox(width: 10),
                          Text('Cerrar sesión',
                              style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(
                    context: context,
                    userName: userName,
                    userEmail: userEmail,
                    userBio: userBio,
                    userLocation: userLocation,
                    userPhone: userPhone,
                    userJoinDate: joinDate,
                    userPhoto: userPhoto,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      indicatorColor: AppColors.textPrimary,
                      indicatorWeight: 3.2,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: AppColors.textPrimary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_outlined, size: 18),
                              SizedBox(width: 6),
                              Text('Posts'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.campaign_outlined, size: 18),
                              SizedBox(width: 6),
                              Text('Reportes'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_border_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Guardados'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _buildPostsTab(
                    context: context,
                    userName: userName,
                    userPhoto: userPhoto,
                    userPosts: userPosts,
                    myReports: myReports,
                    bottomInset: bottomInset,
                  ),
                  _buildReportsTab(context, myReports, bottomInset),
                  _buildSavedTab(context, bottomInset),
                ],
              ),
            ),
          ),
        );
      },
    );
      },
    );
  }

  void _showShareSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace al perfil copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Helper reutilizable para el avatar del usuario:
  /// Utiliza la imagen del usuario si existe, y si no tiene imagen muestra una genérica.
  Widget _buildUserAvatar({required double radius, String? photoUrl}) {
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.10),
        border: Border.all(
          color: AppColors.border,
          width: radius > 25 ? 1.5 : 1.0,
        ),
      ),
      child: ClipOval(
        child: hasPhoto
            ? (photoUrl.startsWith('assets/')
                ? Image.asset(
                    photoUrl,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildGenericAvatarIcon(radius),
                  )
                : Image.network(
                    photoUrl,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildGenericAvatarIcon(radius),
                  ))
            : _buildGenericAvatarIcon(radius),
      ),
    );
  }

  Widget _buildGenericAvatarIcon(double radius) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: radius * 1.15,
        color: AppColors.primary,
      ),
    );
  }

  /// Encabezado superior con estilo X:
  /// - Avatar del usuario (o genérico si no posee).
  /// - Nombre del usuario con su correo al lado (sin candado, sin @).
  /// - Biografía, ubicación, fecha de registro y botones redondeados.
  Widget _buildProfileHeader({
    required BuildContext context,
    required String userName,
    required String userEmail,
    required String userBio,
    required String userLocation,
    required String userPhone,
    DateTime? userJoinDate,
    String? userPhoto,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circular grande del usuario (o genérico)
          _buildUserAvatar(radius: 39, photoUrl: userPhoto),
          const SizedBox(height: 12),

          // Nombre de usuario + Correo al lado (sin candado)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              if (userEmail.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    userEmail,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Biografía descriptiva
          if (userBio.isNotEmpty) ...[
            Text(
              userBio,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text(
              'Sin descripción.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Metadatos: Ubicación y Fecha de registro
          if (userLocation.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  userLocation,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                _formatJoinDate(userJoinDate),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones de acción: Compartir perfil y Editar perfil (Píldoras redondeadas)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showShareSnackbar,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: const Text(
                    'Compartir perfil',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          initialName: userName,
                          initialBio: userBio,
                          initialLocation: userLocation,
                          initialPhone: userPhone,
                          currentPhotoUrl: userPhoto,
                        ),
                      ),
                    ).then((_) {
                      if (context.mounted) {
                        setState(() {});
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: const Text(
                    'Editar perfil',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  /// Pestaña 1 (Posts - Predeterminada): feed unificado con publicaciones y reportes propios del usuario,
  /// ordenados cronológicamente (las más recientes arriba).
  Widget _buildPostsTab({
    required BuildContext context,
    required String userName,
    String? userPhoto,
    required List<FeedPost> userPosts,
    required List<Pet> myReports,
    required double bottomInset,
  }) {
    // Unificación y ordenamiento cronológico descendente
    final List<_ProfileFeedItem> feedItems = [
      ...userPosts.map(_ProfileFeedItem.fromPost),
      ...myReports.map(_ProfileFeedItem.fromPet),
    ];
    feedItems.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final Widget content;
    if (feedItems.isEmpty) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 96.0 + bottomInset),
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.article_outlined,
            size: 56,
            color: AppColors.subtle.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin publicaciones aún',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tus publicaciones cotidianas o alertas creadas aparecerán listadas aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    } else {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 96.0 + bottomInset),
        children: [
          for (final item in feedItems)
            if (item.post != null)
              _buildPostCard(
                context: context,
                postId: item.post!.id,
                authorName: userName,
                authorPhoto: userPhoto,
                categoryBadge: item.post!.categoryTag,
                timeAgo: formatTimeAgo(item.dateTime, fallback: item.post!.timeAgo),
                content: item.post!.displayContent,
                imageUrl: item.post!.imageUrl,
                commentsCount: item.post!.commentsCount,
                feedPost: item.post,
              )
            else if (item.pet != null)
              _buildPostCard(
                context: context,
                postId: item.pet!.id,
                authorName: userName,
                authorPhoto: userPhoto,
                statusBadge: item.pet!.status,
                timeAgo: formatTimeAgo(item.dateTime, fallback: item.pet!.timeAgo),
                content: item.pet!.description,
                imageUrl: item.pet!.imageUrl,
                pet: item.pet,
                commentsCount: 0,
              ),
        ],
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await MockDataService().refreshFromFirestore();
        if (context.mounted) {
          setState(() {});
        }
      },
      child: content,
    );
  }

  /// Pestaña 2: Reportes de mascotas publicados por el usuario (más recientes primero)
  Widget _buildReportsTab(
    BuildContext context,
    List<Pet> myReports,
    double bottomInset,
  ) {
    final sortedReports = List<Pet>.from(myReports)
      ..sort((a, b) => b.date.compareTo(a.date));

    final Widget content;
    if (sortedReports.isEmpty) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 96.0 + bottomInset),
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.campaign_outlined,
            size: 56,
            color: AppColors.subtle.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin reportes activos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tus alertas de mascotas perdidas o encontradas aparecerán listadas aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    } else {
      content = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 96.0 + bottomInset),
        itemCount: sortedReports.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final pet = sortedReports[index];
          return Material(
            color: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.mdBorder,
              side: BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: ClipRRect(
                borderRadius: AppRadius.smBorder,
                child: YagoPetImage(
                  imageUrl: pet.imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                pet.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                '${pet.breed} · ${pet.location} · ${formatTimeAgo(pet.date, fallback: pet.timeAgo)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  YagoStatusBadge(status: pet.status),
                  _buildPostOptionsMenu(
                    context: context,
                    postId: pet.id,
                    content: pet.description,
                    pet: pet,
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PetDetailScreen(pet: pet),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          );
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await MockDataService().refreshFromFirestore();
        if (context.mounted) {
          setState(() {});
        }
      },
      child: content,
    );
  }

  /// Pestaña 3: Publicaciones y reportes guardados
  Widget _buildSavedTab(BuildContext context, double bottomInset) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await MockDataService().refreshFromFirestore();
        if (context.mounted) {
          setState(() {});
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 96.0 + bottomInset),
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.bookmark_border_rounded,
            size: 56,
            color: AppColors.subtle.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'No tienes elementos guardados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Las mascotas o avisos que guardes para hacerles seguimiento se almacenarán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón de opciones para una publicación o reporte (tres puntos)
  Widget _buildPostOptionsMenu({
    required BuildContext context,
    required String postId,
    required String content,
    Pet? pet,
    FeedPost? feedPost,
  }) {
    final isReport = pet != null;

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
        if (isReport && pet.status != YagoPetStatus.reunited)
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

  void _confirmDeletePost(BuildContext context, {required String postId, Pet? pet}) {
    final isReport = pet != null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: Text(isReport ? '¿Eliminar reporte?' : '¿Eliminar publicación?'),
        content: Text(
          isReport
              ? '¿Estás seguro de que deseas eliminar este reporte? Se borrará definitivamente de tu perfil y del catálogo comunitario.'
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

  /// Tarjeta unificada de publicación:
  /// Utilizada de manera uniforme para publicaciones normales y publicaciones de reporte.
  /// Si es un reporte, simplemente añade la etiqueta (YagoStatusBadge) al lado del nombre.
  Widget _buildPostCard({
    required BuildContext context,
    required String postId,
    required String authorName,
    String? authorPhoto,
    YagoPetStatus? statusBadge,
    String? categoryBadge,
    required String timeAgo,
    required String content,
    String? imageUrl,
    Pet? pet,
    FeedPost? feedPost,
    required int commentsCount,
  }) {
    final isLiked = _likedPostIds.contains(postId);
    final likesCount = _postLikesCount[postId] ?? 0;

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
          // Avatar del autor (o genérico si no posee)
          _buildUserAvatar(radius: 20, photoUrl: authorPhoto),
          const SizedBox(width: 12),

          // Contenido de la publicación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Nombre + Etiqueta opcional (si es reporte o post temático) + Tiempo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              authorName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (statusBadge != null) ...[
                            const SizedBox(width: 6),
                            YagoStatusBadge(status: statusBadge),
                          ] else if (categoryBadge != null) ...[
                            const SizedBox(width: 6),
                            YagoPostCategoryBadge(category: categoryBadge),
                          ],
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '· $timeAgo',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPostOptionsMenu(
                      context: context,
                      postId: postId,
                      content: content,
                      pet: pet,
                      feedPost: feedPost,
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Contenido formateado según categoría
                _buildPostFormattedContent(content, categoryBadge),

                // Foto de la publicación (mismo diseño para cualquier tipo de post)
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pet != null
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PetDetailScreen(pet: pet),
                              ),
                            ).then((_) => setState(() {}));
                          }
                        : null,
                    child: YagoPetImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Barra de interacciones (comentarios, me gusta, compartir)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconAction(
                      Icons.chat_bubble_outline_rounded,
                      '$commentsCount',
                    ),
                    GestureDetector(
                      onTap: () => _toggleLike(postId),
                      child: Row(
                        children: [
                          Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                            color: isLiked
                                ? AppColors.likeRed
                                : AppColors.twitterAction,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$likesCount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: isLiked
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
                      size: 17,
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

  Widget _buildIconAction(IconData icon, String count) {
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
}

/// Delegado para mantener fijada la barra de pestañas durante el scroll
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1.0;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tabBar,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.feedDivider,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

/// Elemento unificado del feed del perfil que encapsula un FeedPost o un Pet
/// con una fecha normalizada para garantizar el ordenamiento cronológico.
class _ProfileFeedItem {
  final FeedPost? post;
  final Pet? pet;
  final DateTime dateTime;

  _ProfileFeedItem.fromPost(FeedPost p)
      : post = p,
        pet = null,
        dateTime = p.createdAt ?? extractDateFromId(p.id) ?? DateTime(2020);

  _ProfileFeedItem.fromPet(Pet p)
      : post = null,
        pet = p,
        dateTime = p.date;
}
