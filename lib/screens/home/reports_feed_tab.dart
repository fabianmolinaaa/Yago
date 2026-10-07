import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/pet.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';
import 'create_report_screen.dart';

/// Pestaña oficial del Feed de Reportes (Pantalla 2 de Yago - HU-S2-01).
///
/// Diseñada exclusivamente para reportes de mascotas perdidas y encontradas.
/// Implementa una distribución estilo Pinterest (Masonry Grid de 2 columnas) con
/// fotografías limpias donde el tamaño de cada tarjeta depende de la propia imagen,
/// permitiendo un panorama visual inmediato y orgánico sin scrolls extensivos.
///
/// La filtración se gestiona exclusivamente a través del botón de filtros en el header.
class ReportsFeedTab extends StatefulWidget {
  final VoidCallback? onGoToCreateReport;

  const ReportsFeedTab({
    super.key,
    this.onGoToCreateReport,
  });

  @override
  State<ReportsFeedTab> createState() => _ReportsFeedTabState();
}

class _ReportsFeedTabState extends State<ReportsFeedTab> {
  // Filtro de estado: 0 = Todos (Perdidas y Encontradas), 1 = Solo Perdidas, 2 = Solo Encontradas
  int _selectedStatusIndex = 0;

  // Filtro de especie: 'Todos', 'Perros', 'Gatos', 'Otros'
  String _selectedSpecies = 'Todos';

  // Búsqueda textual
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Control de FAB animado
  bool _isFabVisible = true;

  final List<String> _statusFilters = [
    'Todos',
    'Perdidas',
    'Encontradas',
  ];

  final List<Map<String, String>> _speciesFilters = [
    {'label': 'Todos', 'icon': '🐾'},
    {'label': 'Perros', 'icon': '🐶'},
    {'label': 'Gatos', 'icon': '🐱'},
    {'label': 'Otros', 'icon': '🐰'},
  ];

  @override
  void initState() {
    super.initState();
    MockDataService().refreshFromFirestore().catchError((_) {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedStatusIndex != 0 || _selectedSpecies != 'Todos';

  /// Retorna exclusivamente reportes activos de mascotas perdidas y encontradas
  List<Pet> _getFilteredReports() {
    final allPets = MockDataService().getAllPets();

    // 1. Filtrar solo mascotas activas con estado PERDIDA o ENCONTRADA
    final reportsOnly = allPets.where((pet) {
      return pet.status == YagoPetStatus.lost ||
          pet.status == YagoPetStatus.found;
    }).toList();

    // 2. Filtrar por estado semántico
    List<Pet> filtered = reportsOnly;
    if (_selectedStatusIndex == 1) {
      filtered = filtered
          .where((pet) => pet.status == YagoPetStatus.lost)
          .toList();
    } else if (_selectedStatusIndex == 2) {
      filtered = filtered
          .where((pet) => pet.status == YagoPetStatus.found)
          .toList();
    }

    // 3. Filtrar por especie
    if (_selectedSpecies != 'Todos') {
      final target = _selectedSpecies.toLowerCase();
      filtered = filtered.where((pet) {
        final sp = pet.species.toLowerCase();
        if (target == 'perros') return sp.contains('perro');
        if (target == 'gatos') return sp.contains('gato');
        if (target == 'otros') {
          return !sp.contains('perro') && !sp.contains('gato');
        }
        return sp.contains(target);
      }).toList();
    }

    // 4. Filtrar por término de búsqueda (raza, nombre, ubicación, señas particulares)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((pet) {
        return pet.name.toLowerCase().contains(q) ||
            pet.breed.toLowerCase().contains(q) ||
            pet.location.toLowerCase().contains(q) ||
            pet.description.toLowerCase().contains(q) ||
            pet.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    // 5. Orden cronológico estricto (más recientes arriba)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void _openCreateReport() {
    if (widget.onGoToCreateReport != null) {
      widget.onGoToCreateReport!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          onReportCreated: () => setState(() {}),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openDetail(Pet pet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PetDetailScreen(pet: pet),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openZoneModal(Pet pet) {
    ContextualZoneModal.show(
      context,
      pet,
      onOpenFullDetail: () => _openDetail(pet),
    );
  }

  void _showPetOptionsSheet(Pet pet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isBookmarked = MockDataService().isBookmarked(pet.id);
        final isLost = pet.status == YagoPetStatus.lost;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Ver zona en mapa',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Radio aproximado en ${pet.location}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openZoneModal(pet);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.pets_rounded,
                    color: AppColors.textPrimary,
                  ),
                  title: const Text(
                    'Ver ficha completa',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${pet.breed} · ${isLost ? "Mascota perdida" : "Mascota encontrada"}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openDetail(pet);
                  },
                ),
                ListTile(
                  leading: Icon(
                    isBookmarked
                        ? Icons.bookmark_remove_rounded
                        : Icons.bookmark_add_outlined,
                    color: isBookmarked ? AppColors.primary : AppColors.textPrimary,
                  ),
                  title: Text(
                    isBookmarked ? 'Quitar de guardados' : 'Guardar reporte',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    MockDataService().toggleBookmark(pet.id);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFilterDialog() {
    int tempStatus = _selectedStatusIndex;
    String tempSpecies = _selectedSpecies;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filtros de Reportes',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 260),
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera
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
                                    'Filtrar reportes',
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

                          // Estado de la mascota
                          const Text(
                            'Estado del reporte',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: List.generate(_statusFilters.length, (idx) {
                              final isSelected = tempStatus == idx;

                              return ChoiceChip(
                                label: Text(_statusFilters[idx]),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: const Color(0xFFEFF3F4),
                                labelStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                onSelected: (_) {
                                  setModalState(() => tempStatus = idx);
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 18),

                          // Especie
                          const Text(
                            'Especie del animal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: _speciesFilters.map((sp) {
                              final isSelected = tempSpecies == sp['label'];
                              return ChoiceChip(
                                label: Text('${sp['icon']} ${sp['label']}'),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: const Color(0xFFEFF3F4),
                                labelStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                onSelected: (_) {
                                  setModalState(() => tempSpecies = sp['label']!);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),

                          // Botones de acción
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: YagoButton(
                                    variant: YagoButtonVariant.secondary,
                                    text: 'Restablecer',
                                    onPressed: () {
                                      setState(() {
                                        _selectedStatusIndex = 0;
                                        _selectedSpecies = 'Todos';
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
                                      _selectedStatusIndex = tempStatus;
                                      _selectedSpecies = tempSpecies;
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
              width: 54,
              height: 54,
              child: FloatingActionButton(
                heroTag: 'createReportFab',
                onPressed: _isFabVisible ? _openCreateReport : null,
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: const CircleBorder(),
                tooltip: 'Publicar reporte',
                child: const Icon(
                  Icons.campaign_rounded,
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
          final reports = _getFilteredReports();

          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isFabVisible) setState(() => _isFabVisible = false);
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isFabVisible) setState(() => _isFabVisible = true);
              }
              return false;
            },
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await MockDataService().refreshFromFirestore();
                if (mounted) setState(() {});
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ─── 1. AppBar flotante estilizada con Yago Branding ─────
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
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Reportes',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '${reports.length}',
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
                    actions: [
                      // Botón para desplegar campo de búsqueda
                      IconButton(
                        icon: Icon(
                          _isSearchVisible
                              ? Icons.search_off_rounded
                              : Icons.search_rounded,
                          size: 22,
                          color: _searchQuery.isNotEmpty
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        tooltip: 'Buscar por raza o zona',
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

                      // Botón modal de filtros en el header (único punto de filtración)
                      IconButton(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              size: 22,
                              color: AppColors.textPrimary,
                            ),
                            if (_hasActiveFilters)
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
                        tooltip: 'Filtrar reportes',
                        onPressed: _openFilterDialog,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),

                  // ─── 2. Barra de búsqueda expandible ─────────────────────
                  if (_isSearchVisible)
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Buscar por raza, color, zona o nombre...',
                            hintStyle: const TextStyle(
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
                            fillColor: AppColors.surface,
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

                  // ─── 3. Contenido: Distribución Estilo Pinterest (Masonry) ──
                  if (reports.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.subtle,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No se encontraron reportes coincidentes',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Prueba ajustando los filtros de estado o especie en el botón superior.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              YagoButton(
                                text: 'Restablecer filtros',
                                variant: YagoButtonVariant.secondary,
                                onPressed: () {
                                  setState(() {
                                    _selectedStatusIndex = 0;
                                    _selectedSpecies = 'Todos';
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    // Distribución Pinterest: 2 columnas con alturas variables según la foto
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 120),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          final pet = reports[index];
                          return ReportGridCard(
                            pet: pet,
                            onTap: () => _openDetail(pet),
                            onZoneTap: () => _openZoneModal(pet),
                            onOptionsTap: () => _showPetOptionsSheet(pet),
                          );
                        },
                        childCount: reports.length,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
