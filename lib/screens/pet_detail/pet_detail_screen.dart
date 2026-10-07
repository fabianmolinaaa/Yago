import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

/// Icono vectorial minimalista oficial para representar especie Felina / Gato.
class CatIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CatIcon({
    super.key,
    this.size = 20,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CatIconPainter(color),
      ),
    );
  }
}

class _CatIconPainter extends CustomPainter {
  final Color color;

  _CatIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final path = Path();
    // Silueta de cabeza de gato estilizada con orejas triangulares
    path.moveTo(12.0, 7.0);
    path.lineTo(15.5, 7.0);
    path.lineTo(19.5, 2.5); // Oreja derecha
    path.lineTo(19.2, 9.8);
    path.cubicTo(21.8, 12.8, 20.8, 17.5, 17.5, 20.2); // Mejilla derecha
    path.cubicTo(14.5, 22.2, 9.5, 22.2, 6.5, 20.2); // Mentón
    path.cubicTo(3.2, 17.5, 2.2, 12.8, 4.8, 9.8); // Mejilla izquierda
    path.lineTo(4.5, 2.5); // Oreja izquierda
    path.lineTo(8.5, 7.0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late Pet _pet;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _isBookmarked = MockDataService().isBookmarked(_pet.id);
  }

  void _toggleBookmark() {
    setState(() {
      MockDataService().toggleBookmark(_pet.id);
      _isBookmarked = !_isBookmarked;
    });
  }

  void _showContactDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (_pet.status == YagoPetStatus.community)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const YagoLogoIcon(size: 28),
                  )
                else
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
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
                              _pet.status == YagoPetStatus.community
                                  ? 'Equipo Yago'
                                  : _pet.contactName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_pet.status == YagoPetStatus.community) ...[
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
                        _pet.status == YagoPetStatus.community
                            ? 'Equipo oficial de la comunidad Yago'
                            : (_pet.isUserOwner
                                ? 'Dueño de la mascota'
                                : 'Persona que reportó'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorder,
                side: const BorderSide(color: AppColors.border),
              ),
              leading: const Icon(Icons.phone_rounded, color: AppColors.primary),
              title: const Text('Llamar por teléfono', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_pet.contactPhone),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Marcando a ${_pet.contactPhone}...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorder,
                side: const BorderSide(color: AppColors.border),
              ),
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              title: const Text('Enviar mensaje directo', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Chat interno en la comunidad'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Iniciando chat con el contacto...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmMarkAsResolved() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: const Text(
          '¿Marcar como recuperada?',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que deseas marcar esta mascota como recuperada? El caso se dará por resuelto y el reporte dejará de mostrarse en los feeds.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.reunited,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, marcar como recuperada'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _markAsResolved();
    }
  }

  void _markAsResolved() {
    MockDataService().markAsReunited(_pet.id);
    setState(() {
      _pet = _pet.copyWith(status: YagoPetStatus.reunited);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Caso resuelto! La mascota fue marcada como recuperada y retirada de los feeds.'),
        backgroundColor: AppColors.reunited,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Widget _getSpeciesIcon(String species) {
    final s = species.toLowerCase().trim();
    if (s.contains('perro') || s.contains('canino') || s.contains('dog')) {
      return const Icon(Icons.pets_rounded, size: 20, color: AppColors.primary);
    } else if (s.contains('gato') || s.contains('felino') || s.contains('cat')) {
      return const CatIcon(size: 20, color: AppColors.primary);
    } else {
      // 'Otro' (aves, tortugas, conejos, etc.)
      return const Icon(Icons.cruelty_free_rounded, size: 20, color: AppColors.primary);
    }
  }

  Widget _getGenderIcon(String gender) {
    final g = gender.toLowerCase().trim();
    if (g.contains('macho')) {
      return const Icon(Icons.male_rounded, size: 20, color: AppColors.primary);
    } else if (g.contains('hembra')) {
      return const Icon(Icons.female_rounded, size: 20, color: AppColors.primary);
    } else {
      return const Icon(Icons.transgender_rounded, size: 20, color: AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final isOwner = _pet.isUserOwner ||
        (currentUser != null && _pet.ownerId == currentUser.uid) ||
        (currentUser?.displayName != null &&
            currentUser!.displayName!.isNotEmpty &&
            _pet.contactName.trim().toLowerCase() ==
                currentUser.displayName!.trim().toLowerCase());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar con foto expandida estilo iOS
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 20,
                      color: _isBookmarked ? AppColors.primary : Colors.white,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  YagoPetImage(
                    imageUrl: _pet.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Colors.black26,
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido de la ficha de mascota
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. Nombre y Raza a la izquierda, Estado y Horario a la derecha ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pet.name,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pet.species.isNotEmpty && _pet.species != 'Otro'
                                  ? '${_pet.species} · ${_pet.breed}'
                                  : _pet.breed,
                              style: AppTypography.subheadline.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          YagoStatusBadge(status: _pet.status),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.muted),
                              const SizedBox(width: 4),
                              Text(
                                _pet.timeAgo,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── 2. Ficha de Atributos (Sexo, Edad aproximada, Especie) ───
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAttributeItem('Sexo', _pet.gender, _getGenderIcon(_pet.gender)),
                        Container(width: 1, height: 32, color: AppColors.border),
                        _buildAttributeItem(
                          'Edad',
                          _pet.age,
                          const Icon(Icons.cake_rounded, size: 20, color: AppColors.primary),
                        ),
                        Container(width: 1, height: 32, color: AppColors.border),
                        _buildAttributeItem('Especie', _pet.species, _getSpeciesIcon(_pet.species)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ─── 3. Última ubicación registrada (Clickable -> abre mapa) ───
                  const Text(
                    'Última ubicación registrada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.white,
                    borderRadius: AppRadius.mdBorder,
                    child: InkWell(
                      borderRadius: AppRadius.mdBorder,
                      onTap: () {
                        ContextualZoneModal.show(context, _pet);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.smBorder,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pet.location,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Toca para ver zona en el mapa · (${_pet.latitude.toStringAsFixed(4)}, ${_pet.longitude.toStringAsFixed(4)})',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.map_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ─── 4. Señas particulares ───
                  if (_pet.tags.isNotEmpty) ...[
                    const Text(
                      'Señas particulares',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pet.tags.map((tag) => YagoFeatureTag(label: tag)).toList(),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // ─── 5. Descripción ───
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pet.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── 6. Botón de Marcar como recuperada (si es dueño y caso activo) ───
                  if (isOwner && _pet.status != YagoPetStatus.reunited) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.reunitedBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.reunited.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _confirmMarkAsResolved,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.reunited, size: 20),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Marcar como recuperada',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.reunitedText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ─── 7. Botón principal de contacto ───
                  YagoButton(
                    text: 'Contactar',
                    variant: YagoButtonVariant.primary,
                    size: YagoButtonSize.large,
                    isFullWidth: true,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
                    onPressed: _showContactDialog,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(String label, String value, Widget iconWidget) {
    return Column(
      children: [
        SizedBox(
          height: 22,
          child: Center(child: iconWidget),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
