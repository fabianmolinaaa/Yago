import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../services/auth_service.dart';
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
              backgroundColor: AppColors.lost,
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

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : 'Fabián';
    final userEmail = user?.email ?? 'usuario@yago.app';
    final userPhoto = user?.photoURL ?? MockDataService().userCustomPhotoUrl;
    final userBio = MockDataService().userBio;
    final userLocation = MockDataService().userLocation;
    final myReports = MockDataService().getMyReports();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
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
                      Icon(Icons.share_outlined, size: 18, color: AppColors.textPrimary),
                      SizedBox(width: 10),
                      Text('Compartir perfil'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: AppColors.lost),
                      SizedBox(width: 10),
                      Text('Cerrar sesión', style: TextStyle(color: AppColors.lost)),
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
              _buildPostsTab(context, userName, userPhoto, myReports, bottomInset),
              _buildReportsTab(context, myReports, bottomInset),
              _buildSavedTab(context, bottomInset),
            ],
          ),
        ),
      ),
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
          ),
          const SizedBox(height: 8),

          // Biografía descriptiva
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

          // Metadatos: Ubicación y Fecha de registro
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
          const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 5),
              Text(
                'Se unió en febrero de 2024',
                style: TextStyle(
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
                          initialPhone: MockDataService().userPhone,
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

  /// Pestaña 1 (Posts - Predeterminada): feed unificado con publicaciones de todo tipo.
  /// Mantiene exactamente el mismo diseño de publicación normal tanto para posts
  /// cotidianos como para reportes, agregando la etiqueta de estado al lado del nombre.
  Widget _buildPostsTab(
    BuildContext context,
    String userName,
    String? userPhoto,
    List<Pet> myReports,
    double bottomInset,
  ) {
    return ListView(
      padding: EdgeInsets.only(bottom: 96.0 + bottomInset),
      children: [
        // Publicación cotidiana normal del usuario
        _buildPostCard(
          context: context,
          postId: 'user-post-1',
          authorName: userName,
          authorPhoto: userPhoto,
          timeAgo: 'Hace 2 h',
          content:
              'Paseando por la costanera con mi compañero fiel. Siempre atentos por si vemos a alguna mascota extraviada de los reportes del barrio 🐾🐶',
          imageUrl: 'assets/images/IMG_5667.JPG',
          commentsCount: 4,
        ),

        // Publicación de reporte de mascota del usuario:
        // Mismo diseño exacto de post normal, solo con la etiqueta de estado al lado del nombre.
        if (myReports.isNotEmpty)
          _buildPostCard(
            context: context,
            postId: 'user-report-1',
            authorName: userName,
            authorPhoto: userPhoto,
            statusBadge: myReports.first.status,
            timeAgo: 'Ayer',
            content:
                '¡Buscamos a ${myReports.first.name}! ${myReports.first.description}',
            imageUrl: myReports.first.imageUrl,
            pet: myReports.first,
            commentsCount: 12,
          ),

        // Resto de reportes del usuario si hubiera más
        for (int i = 1; i < myReports.length; i++)
          _buildPostCard(
            context: context,
            postId: 'user-report-${myReports[i].id}',
            authorName: userName,
            authorPhoto: userPhoto,
            statusBadge: myReports[i].status,
            timeAgo: myReports[i].timeAgo,
            content: myReports[i].description,
            imageUrl: myReports[i].imageUrl,
            pet: myReports[i],
            commentsCount: 3,
          ),
      ],
    );
  }

  /// Pestaña 2: Reportes de mascotas publicados por el usuario
  Widget _buildReportsTab(
    BuildContext context,
    List<Pet> myReports,
    double bottomInset,
  ) {
    if (myReports.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            bottom: 96.0 + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 56,
                color: AppColors.subtle.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sin reportes activos',
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
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 96.0 + bottomInset),
      itemCount: myReports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pet = myReports[index];
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
              child: pet.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      pet.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.surfaceSecondary,
                        child: const Icon(Icons.pets, color: AppColors.subtle),
                      ),
                    )
                  : Image.network(
                      pet.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.surfaceSecondary,
                        child: const Icon(Icons.pets, color: AppColors.subtle),
                      ),
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
              '${pet.breed} · ${pet.location}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: YagoStatusBadge(status: pet.status),
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

  /// Pestaña 3: Publicaciones y reportes guardados
  Widget _buildSavedTab(BuildContext context, double bottomInset) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 32.0,
          right: 32.0,
          bottom: 96.0 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 56,
              color: AppColors.subtle.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            const Text(
              'No tienes elementos guardados',
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
    required String timeAgo,
    required String content,
    String? imageUrl,
    Pet? pet,
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
                // Cabecera: Nombre + Etiqueta opcional (si es reporte) + Tiempo (sin @, sin correo, sin candado)
                Row(
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
                    ],
                    const SizedBox(width: 6),
                    Text(
                      '· $timeAgo',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: AppColors.twitterAction,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Texto de la publicación
                Text(
                  content,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),

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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: imageUrl.startsWith('assets/')
                          ? Image.asset(
                              imageUrl,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox.shrink(),
                            ),
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
