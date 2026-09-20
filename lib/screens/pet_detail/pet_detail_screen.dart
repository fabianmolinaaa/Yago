import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';

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
              leading: const Icon(Icons.phone_rounded, color: AppColors.found),
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

  void _showReportSightingDialog() {
    final sightingController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: const Text('Aportar información o avistamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿La viste recientemente o tienes algún dato certero? Tu ayuda es fundamental.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            YagoTextField(
              label: 'Detalles del avistamiento',
              hint: 'Ej: La vi hoy a las 14hs cerca de la esquina...',
              controller: sightingController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
            ),
            onPressed: () {
              if (sightingController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Gracias! Tu aviso fue notificado a la familia.'),
                    backgroundColor: AppColors.found,
                  ),
                );
              }
            },
            child: const Text('Enviar reporte'),
          ),
        ],
      ),
    );
  }

  void _markAsResolved() {
    setState(() {
      MockDataService().markAsReunited(_pet.id);
      _pet = _pet.copyWith(status: YagoPetStatus.reunited);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Felicitaciones! Mascota marcada como reunida.'),
        backgroundColor: AppColors.reunited,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _pet.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          _pet.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: Icon(Icons.pets, size: 64, color: AppColors.subtle),
                            ),
                          ),
                        )
                      : Image.network(
                          _pet.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: Icon(Icons.pets, size: 64, color: AppColors.subtle),
                            ),
                          ),
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
                  // Estado semántico y fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      YagoStatusBadge(status: _pet.status),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            _pet.timeAgo,
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Nombre de la mascota
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

                  // Raza y especie
                  Text(
                    '${_pet.species} · ${_pet.breed}',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Ficha de Atributos (Edad, Sexo, Ubicación)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAttributeItem('Sexo', _pet.gender, Icons.male_rounded),
                        Container(width: 1, height: 32, color: AppColors.border),
                        _buildAttributeItem('Edad', _pet.age, Icons.calendar_today_rounded),
                        Container(width: 1, height: 32, color: AppColors.border),
                        _buildAttributeItem('Especie', _pet.species, Icons.pets_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Ubicación
                  const Text(
                    'Última ubicación registrada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                                'Coordenadas: ${_pet.latitude.toStringAsFixed(4)}, ${_pet.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tags / Atributos físicos
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

                  // Historia o caso resuelto
                  if (_pet.storyText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.reunited.withValues(alpha: 0.08),
                        borderRadius: AppRadius.lgBorder,
                        border: Border.all(color: AppColors.reunited.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.reunited, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Historia con final feliz',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.reunited,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pet.storyText!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // Descripción detallada
                  const Text(
                    'Descripción de lo sucedido',
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
                  const SizedBox(height: 36),

                  // Si el usuario es dueño y aún está perdida, botón de resolver caso
                  if (_pet.isUserOwner && _pet.status != YagoPetStatus.reunited) ...[
                    YagoButton(
                      text: '¡Mascota recuperada! Marcar como encontrada',
                      variant: YagoButtonVariant.secondary,
                      size: YagoButtonSize.large,
                      isFullWidth: true,
                      onPressed: _markAsResolved,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Botones principales de contacto y ayuda
                  Row(
                    children: [
                      Expanded(
                        child: YagoButton(
                          text: 'Aportar dato',
                          variant: YagoButtonVariant.outline,
                          size: YagoButtonSize.large,
                          onPressed: _showReportSightingDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: YagoButton(
                          text: 'Contactar',
                          variant: YagoButtonVariant.primary,
                          size: YagoButtonSize.large,
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
                          onPressed: _showContactDialog,
                        ),
                      ),
                    ],
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

  Widget _buildAttributeItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
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
