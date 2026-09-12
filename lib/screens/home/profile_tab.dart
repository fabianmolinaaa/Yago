import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../auth/login_screen.dart';
import '../pet_detail/pet_detail_screen.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onGoToCreateReport;

  const ProfileTab({super.key, this.onGoToCreateReport});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
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

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Usuario de la Comunidad';
    final userEmail = user?.email ?? 'usuario@yago.app';
    final myReports = MockDataService().getMyReports();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // Avatar de usuario
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.found,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Nombre y correo
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            // Rol del usuario
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Rol: Usuario de la Comunidad',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tarjetas de estadísticas de usuario
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Mis Reportes', '${myReports.length}', Icons.campaign_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Guardados', '3', Icons.bookmark_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Reunidos', '1', Icons.favorite_rounded),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Mis publicaciones activas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis reportes publicados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.onGoToCreateReport != null)
                  TextButton.icon(
                    onPressed: widget.onGoToCreateReport,
                    icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    label: const Text(
                      'Nuevo',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (myReports.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: const Text(
                  'Aún no has publicado reportes de mascotas.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else
              ...myReports.map((pet) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBorder,
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: AppRadius.smBorder,
                      child: pet.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              pet.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 48,
                                height: 48,
                                color: AppColors.surface,
                                child: const Icon(Icons.pets, size: 24, color: AppColors.subtle),
                              ),
                            )
                          : Image.network(
                              pet.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 48,
                                height: 48,
                                color: AppColors.surface,
                                child: const Icon(Icons.pets, size: 24, color: AppColors.subtle),
                              ),
                            ),
                    ),
                    title: Text(
                      pet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      '${pet.breed} · ${pet.location}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  ),
                );
              }),
            const SizedBox(height: 24),

            // Tarjeta informativa del Proyecto
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pets_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Acerca de Yago',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Plataforma colaborativa para el reencuentro de mascotas perdidas y encontradas con la comunidad.\nLaboratorio de Desarrollo de Software',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.lost),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.lost, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.lost.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
