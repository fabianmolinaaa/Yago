import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';
import 'create_report_screen.dart';

class CitySuggestion {
  final String name;
  final String province;

  const CitySuggestion(this.name, this.province);
}

/// Pestaña oficial del Feed de Reportes (Pantalla 2 de Yago - HU-S2-01).
///
/// Diseñada exclusivamente para reportes de mascotas perdidas y encontradas.
/// Implementa una distribución uniforme de 2 columnas con tarjetas de tamaño definido (180px)
/// y fotografías limpias sin deformaciones, permitiendo una visualización inmediata
/// y armoniosa sin scrolls extensivos ni saltos desproporcionados.
///
/// La filtración se gestiona a través del selector de ciudad con sugerencias en tiempo real
/// estilo Facebook Marketplace y el botón de filtros avanzados en el header (HU-S2-06).
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

  // Filtro de raza (HU-S2)
  String _selectedBreed = 'Todas';

  // Catálogo de razas populares para filtrado rápido
  static const List<String> _popularBreeds = [
    'Todas',
    'Mestizo',
    'Caniche',
    'Labrador',
    'Golden Retriever',
    'Siamés',
    'Ovejero Alemán',
  ];

  // Filtro de ciudad (HU-S2-06 estilo Facebook Marketplace)
  String _defaultUserCity = 'Caleta Olivia';
  String _selectedCity = 'Caleta Olivia';

  // Catálogo integral de ciudades de Santa Cruz, Chubut, Patagonia y Argentina para sugerencias instantáneas
  static const List<CitySuggestion> _argentinaCities = [
    // Santa Cruz
    CitySuggestion('Caleta Olivia', 'Santa Cruz'),
    CitySuggestion('Pico Truncado', 'Santa Cruz'),
    CitySuggestion('Puerto Deseado', 'Santa Cruz'),
    CitySuggestion('Las Heras', 'Santa Cruz'),
    CitySuggestion('Río Gallegos', 'Santa Cruz'),
    CitySuggestion('El Calafate', 'Santa Cruz'),
    CitySuggestion('Perito Moreno', 'Santa Cruz'),
    CitySuggestion('Los Antiguos', 'Santa Cruz'),
    CitySuggestion('El Chaltén', 'Santa Cruz'),
    CitySuggestion('Río Turbio', 'Santa Cruz'),
    CitySuggestion('28 de Noviembre', 'Santa Cruz'),
    CitySuggestion('Puerto San Julián', 'Santa Cruz'),
    CitySuggestion('Puerto Santa Cruz', 'Santa Cruz'),
    CitySuggestion('Comandante Luis Piedrabuena', 'Santa Cruz'),
    CitySuggestion('Gobernador Gregores', 'Santa Cruz'),

    // Chubut
    CitySuggestion('Comodoro Rivadavia', 'Chubut'),
    CitySuggestion('Rada Tilly', 'Chubut'),
    CitySuggestion('Trelew', 'Chubut'),
    CitySuggestion('Puerto Madryn', 'Chubut'),
    CitySuggestion('Rawson', 'Chubut'),
    CitySuggestion('Esquel', 'Chubut'),
    CitySuggestion('Sarmiento', 'Chubut'),
    CitySuggestion('Gaiman', 'Chubut'),
    CitySuggestion('Dolavon', 'Chubut'),
    CitySuggestion('Trevelin', 'Chubut'),
    CitySuggestion('Lago Puelo', 'Chubut'),
    CitySuggestion('El Hoyo', 'Chubut'),

    // Río Negro y Neuquén
    CitySuggestion('San Carlos de Bariloche', 'Río Negro'),
    CitySuggestion('General Roca', 'Río Negro'),
    CitySuggestion('Cipolletti', 'Río Negro'),
    CitySuggestion('Viedma', 'Río Negro'),
    CitySuggestion('Las Grutas', 'Río Negro'),
    CitySuggestion('Villa Regina', 'Río Negro'),
    CitySuggestion('El Bolsón', 'Río Negro'),
    CitySuggestion('Neuquén', 'Neuquén'),
    CitySuggestion('San Martín de los Andes', 'Neuquén'),
    CitySuggestion('Villa La Angostura', 'Neuquén'),
    CitySuggestion('Zapala', 'Neuquén'),
    CitySuggestion('Cutral Có', 'Neuquén'),
    CitySuggestion('Plaza Huincul', 'Neuquén'),
    CitySuggestion('Junín de los Andes', 'Neuquén'),

    // Tierra del Fuego
    CitySuggestion('Ushuaia', 'Tierra del Fuego'),
    CitySuggestion('Río Grande', 'Tierra del Fuego'),
    CitySuggestion('Tolhuin', 'Tierra del Fuego'),

    // La Pampa
    CitySuggestion('Santa Rosa', 'La Pampa'),
    CitySuggestion('General Pico', 'La Pampa'),

    // Principales ciudades de Argentina
    CitySuggestion('Buenos Aires', 'CABA'),
    CitySuggestion('La Plata', 'Buenos Aires'),
    CitySuggestion('Mar del Plata', 'Buenos Aires'),
    CitySuggestion('Bahía Blanca', 'Buenos Aires'),
    CitySuggestion('Tandil', 'Buenos Aires'),
    CitySuggestion('Pergamino', 'Buenos Aires'),
    CitySuggestion('San Nicolás', 'Buenos Aires'),
    CitySuggestion('Córdoba', 'Córdoba'),
    CitySuggestion('Villa Carlos Paz', 'Córdoba'),
    CitySuggestion('Río Cuarto', 'Córdoba'),
    CitySuggestion('Villa María', 'Córdoba'),
    CitySuggestion('Rosario', 'Santa Fe'),
    CitySuggestion('Santa Fe', 'Santa Fe'),
    CitySuggestion('Rafaela', 'Santa Fe'),
    CitySuggestion('Venado Tuerto', 'Santa Fe'),
    CitySuggestion('Mendoza', 'Mendoza'),
    CitySuggestion('San Rafael', 'Mendoza'),
    CitySuggestion('Godoy Cruz', 'Mendoza'),
    CitySuggestion('San Juan', 'San Juan'),
    CitySuggestion('San Luis', 'San Luis'),
    CitySuggestion('Villa Mercedes', 'San Luis'),
    CitySuggestion('Salta', 'Salta'),
    CitySuggestion('San Miguel de Tucumán', 'Tucumán'),
    CitySuggestion('San Salvador de Jujuy', 'Jujuy'),
    CitySuggestion('Santiago del Estero', 'Santiago del Estero'),
    CitySuggestion('Corrientes', 'Corrientes'),
    CitySuggestion('Posadas', 'Misiones'),
    CitySuggestion('Resistencia', 'Chaco'),
    CitySuggestion('Formosa', 'Formosa'),
    CitySuggestion('Paraná', 'Entre Ríos'),
    CitySuggestion('Catamarca', 'Catamarca'),
    CitySuggestion('La Rioja', 'La Rioja'),
  ];

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .trim();
  }

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

  final List<String> _speciesFilters = [
    'Todos',
    'Perros',
    'Gatos',
    'Otros',
  ];

  Widget _getSpeciesIcon(String species, bool isSelected, {double size = 15}) {
    final s = species.toLowerCase().trim();
    final color = isSelected ? Colors.white : AppColors.primary;
    if (s.contains('perro')) {
      return Icon(Icons.pets_rounded, size: size, color: color);
    } else if (s.contains('gato')) {
      return CatIcon(size: size, color: color);
    } else if (s.contains('otro')) {
      return Icon(Icons.cruelty_free_rounded, size: size + 1, color: color);
    } else {
      return Icon(Icons.apps_rounded, size: size, color: color);
    }
  }

  Widget _getStatusIcon(int index, bool isSelected, {double size = 15}) {
    final color = isSelected
        ? Colors.white
        : (index == 1
            ? AppColors.error
            : (index == 2 ? AppColors.success : AppColors.textSecondary));
    if (index == 1) {
      return Icon(Icons.search_rounded, size: size, color: color);
    } else if (index == 2) {
      return Icon(Icons.check_circle_outline_rounded, size: size, color: color);
    } else {
      return Icon(Icons.dashboard_outlined, size: size, color: color);
    }
  }

  @override
  void initState() {
    super.initState();
    _initUserCity();
    MockDataService().refreshFromFirestore().catchError((_) {});
  }

  Future<void> _initUserCity() async {
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      try {
        final profile = await FirestoreService().getUserProfile(currentUser.uid);
        if (profile?.location != null && profile!.location!.trim().isNotEmpty) {
          final city = _extractCity(profile.location!);
          if (mounted && city.isNotEmpty) {
            setState(() {
              _defaultUserCity = city;
              _selectedCity = city;
            });
            return;
          }
        }
      } catch (_) {}
    }

    if (MockDataService().userLocation.trim().isNotEmpty) {
      final city = _extractCity(MockDataService().userLocation);
      if (mounted && city.isNotEmpty) {
        setState(() {
          _defaultUserCity = city;
          _selectedCity = city;
        });
      }
    }
  }

  String _extractCity(String location) {
    final clean = location.trim();
    if (clean.isEmpty) return 'Caleta Olivia';
    final parts = clean.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return parts[1];
    }
    return parts.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedStatusIndex != 0 ||
      _selectedSpecies != 'Todos' ||
      _selectedBreed != 'Todas' ||
      _selectedCity != _defaultUserCity;

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

    // 4. Filtrar por raza específica (HU-S2)
    if (_selectedBreed != 'Todas' && _selectedBreed.trim().isNotEmpty) {
      final breedTarget = _normalize(_selectedBreed);
      filtered = filtered.where((pet) {
        return _normalize(pet.breed).contains(breedTarget);
      }).toList();
    }

    // 5. Filtrar por ciudad / localidad geográfica (HU-S2-06 estilo Marketplace)
    if (_selectedCity != 'Todas las ciudades') {
      final cityTarget = _normalize(_selectedCity);
      filtered = filtered.where((pet) {
        return _normalize(pet.location).contains(cityTarget);
      }).toList();
    }

    // 5. Filtrar por término de búsqueda (raza, nombre, ubicación, señas particulares)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _normalize(_searchQuery);
      filtered = filtered.where((pet) {
        return _normalize(pet.name).contains(q) ||
            _normalize(pet.breed).contains(q) ||
            _normalize(pet.location).contains(q) ||
            _normalize(pet.description).contains(q) ||
            pet.tags.any((tag) => _normalize(tag).contains(q));
      }).toList();
    }

    // 6. Orden cronológico estricto (más recientes arriba)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  List<CitySuggestion> _getAvailableCitySuggestions() {
    final allReports = MockDataService().getAllPets().where((p) =>
        p.status == YagoPetStatus.lost || p.status == YagoPetStatus.found);

    final seen = <String>{};
    final result = <CitySuggestion>[];

    // 1. Ciudades presentes en los reportes existentes
    for (final pet in allReports) {
      final city = _extractCity(pet.location);
      if (city.isNotEmpty && !seen.contains(_normalize(city))) {
        seen.add(_normalize(city));
        final match = _argentinaCities
            .where((c) => _normalize(c.name) == _normalize(city))
            .firstOrNull;
        result.add(
          CitySuggestion(city, match?.province ?? 'Con reportes activos'),
        );
      }
    }

    // 2. Ciudad del usuario si aún no está
    if (_defaultUserCity.isNotEmpty &&
        !seen.contains(_normalize(_defaultUserCity))) {
      seen.add(_normalize(_defaultUserCity));
      final match = _argentinaCities
          .where((c) => _normalize(c.name) == _normalize(_defaultUserCity))
          .firstOrNull;
      result.add(
        CitySuggestion(
            _defaultUserCity, match?.province ?? 'Tu ciudad de residencia'),
      );
    }

    // 3. Catálogo amplio de ciudades argentinas
    for (final city in _argentinaCities) {
      if (!seen.contains(_normalize(city.name))) {
        seen.add(_normalize(city.name));
        result.add(city);
      }
    }

    return result;
  }

  int _countReportsInCity(String city) {
    final allReports = MockDataService().getAllPets().where((p) =>
        p.status == YagoPetStatus.lost || p.status == YagoPetStatus.found);
    if (city == 'Todas las ciudades') {
      return allReports.length;
    }
    final target = _normalize(city);
    return allReports
        .where((p) => _normalize(p.location).contains(target))
        .length;
  }

  Widget _buildLocationBar() {
    final isAllCities = _selectedCity == 'Todas las ciudades';
    final isDefaultCity = _selectedCity == _defaultUserCity;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.feedDivider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Pill interactivo estilo Facebook Marketplace
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openCitySelectorSheet,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAllCities ? AppColors.surface : AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAllCities
                        ? AppColors.border
                        : AppColors.primary.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: isAllCities
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _selectedCity,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isAllCities
                            ? AppColors.textPrimary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isAllCities
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Acción rápida de alternar ciudad
          if (!isAllCities)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCity = 'Todas las ciudades';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else if (!isDefaultCity)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCity = _defaultUserCity;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Mi ciudad ($_defaultUserCity)',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openCitySelectorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _CitySelectorSheetContent(
          selectedCity: _selectedCity,
          defaultUserCity: _defaultUserCity,
          getAvailableCitySuggestions: _getAvailableCitySuggestions,
          countReportsInCity: _countReportsInCity,
          extractCity: _extractCity,
          onCitySelected: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
        );
      },
    );
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
      pageBuilder: (dialogContext, anim1, anim2) {
        return _FilterDialogContent(
          initialStatusIndex: _selectedStatusIndex,
          initialSpecies: _selectedSpecies,
          initialBreed: _selectedBreed,
          initialCity: _selectedCity,
          defaultUserCity: _defaultUserCity,
          statusFilters: _statusFilters,
          speciesFilters: _speciesFilters,
          popularBreeds: _popularBreeds,
          getSpeciesIcon: _getSpeciesIcon,
          getStatusIcon: _getStatusIcon,
          normalize: _normalize,
          onOpenCitySelector: _openCitySelectorSheet,
          onApplyFilters: ({
            required int statusIndex,
            required String species,
            required String breed,
            required String city,
          }) {
            setState(() {
              _selectedStatusIndex = statusIndex;
              _selectedSpecies = species;
              _selectedBreed = breed;
              _selectedCity = city;
            });
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

                  // ─── 3. Barra de ubicación estilo Marketplace (HU-S2-06) ───
                  SliverToBoxAdapter(
                    child: _buildLocationBar(),
                  ),

                  // ─── 4. Contenido: Distribución Estilo Pinterest (Masonry) ──
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
                            Text(
                              _selectedCity != 'Todas las ciudades'
                                  ? 'No hay reportes en $_selectedCity'
                                  : 'No se encontraron reportes coincidentes',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedCity != 'Todas las ciudades'
                                  ? 'Prueba consultando reportes en Todas las ciudades o cambia tu localidad.'
                                  : 'Prueba ajustando los filtros de estado o especie en el botón superior.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_selectedCity != 'Todas las ciudades') ...[
                              YagoButton(
                                text: 'Ver todas las ciudades',
                                onPressed: () {
                                  setState(() {
                                    _selectedCity = 'Todas las ciudades';
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              YagoButton(
                                variant: YagoButtonVariant.secondary,
                                text: 'Cambiar de ciudad',
                                onPressed: _openCitySelectorSheet,
                              ),
                            ] else if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                              YagoButton(
                                text: 'Restablecer filtros',
                                variant: YagoButtonVariant.secondary,
                                onPressed: () {
                                  setState(() {
                                    _selectedStatusIndex = 0;
                                    _selectedSpecies = 'Todos';
                                    _selectedCity = _defaultUserCity;
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

class _CitySelectorSheetContent extends StatefulWidget {
  final String selectedCity;
  final String defaultUserCity;
  final List<CitySuggestion> Function() getAvailableCitySuggestions;
  final int Function(String) countReportsInCity;
  final String Function(String) extractCity;
  final ValueChanged<String> onCitySelected;

  const _CitySelectorSheetContent({
    required this.selectedCity,
    required this.defaultUserCity,
    required this.getAvailableCitySuggestions,
    required this.countReportsInCity,
    required this.extractCity,
    required this.onCitySelected,
  });

  @override
  State<_CitySelectorSheetContent> createState() =>
      _CitySelectorSheetContentState();
}

class _CitySelectorSheetContentState extends State<_CitySelectorSheetContent> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;
  List<CityResult> _liveApiSuggestions = [];
  bool _isSearchingLive = false;
  bool _isDetectingGps = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    setState(() {});
    _debounceTimer?.cancel();
    final q = text.trim();
    if (q.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
        if (!mounted) return;
        setState(() => _isSearchingLive = true);
        try {
          final results = await LocationService().searchCities(q);
          if (!mounted) return;
          setState(() {
            _liveApiSuggestions = results;
            _isSearchingLive = false;
          });
        } catch (_) {
          if (!mounted) return;
          setState(() => _isSearchingLive = false);
        }
      });
    } else {
      setState(() {
        _liveApiSuggestions = [];
        _isSearchingLive = false;
      });
    }
  }

  Widget _buildCityTile({
    required String cityName,
    String? subtitle,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              cityName,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count ${count == 1 ? "reporte" : "reportes"}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 20,
            )
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _ReportsFeedTabState._normalize(_searchController.text);
    final allSuggestions = widget.getAvailableCitySuggestions();

    final localSuggestions = query.isEmpty
        ? allSuggestions.take(8).toList()
        : allSuggestions.where((c) {
            final normName = _ReportsFeedTabState._normalize(c.name);
            final normProv = _ReportsFeedTabState._normalize(c.province);
            return normName.contains(query) || normProv.contains(query);
          }).toList();

    // Combinar sugerencias locales y reportes existentes con los resultados en vivo de Nominatim/Maps
    final suggestions = <CitySuggestion>[];
    final seenNames = <String>{};

    for (final item in localSuggestions) {
      final key = _ReportsFeedTabState._normalize(item.name);
      if (!seenNames.contains(key)) {
        seenNames.add(key);
        suggestions.add(item);
      }
    }

    for (final apiCity in _liveApiSuggestions) {
      final key = _ReportsFeedTabState._normalize(apiCity.cityName);
      if (!seenNames.contains(key)) {
        seenNames.add(key);
        final prov = apiCity.province.isNotEmpty
            ? apiCity.province
            : (apiCity.country.isNotEmpty ? apiCity.country : 'Ubicación');
        suggestions.add(CitySuggestion(apiCity.cityName, prov));
      }
    }

    final hasExactMatch = suggestions.any(
        (c) => _ReportsFeedTabState._normalize(c.name) == query);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Manija superior
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Encabezado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.place_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubicación de reportes',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Filtra las mascotas perdidas y encontradas por ciudad',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Botón para usar GPS actual
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: _isDetectingGps
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          setState(() => _isDetectingGps = true);
                          try {
                            final loc =
                                await LocationService().getCurrentLocation();
                            final city = widget.extractCity(loc.locationName);
                            if (!mounted) return;
                            widget.onCitySelected(city);
                            if (navigator.canPop()) {
                              navigator.pop();
                            }
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Ubicación actualizada a $city'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isDetectingGps = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        _isDetectingGps
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.my_location_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usar mi ubicación actual',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Detectar ciudad automáticamente por GPS',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Buscador de ciudad con sugerencias reactivas en tiempo real
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ciudad o localidad...',
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
                              _debounceTimer?.cancel();
                              _searchController.clear();
                              setState(() {
                                _liveApiSuggestions = [];
                                _isSearchingLive = false;
                              });
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
                  onChanged: _onSearchChanged,
                  onSubmitted: (customVal) {
                    final clean = customVal.trim();
                    if (clean.isNotEmpty) {
                      widget.onCitySelected(clean);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              if (_isSearchingLive)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  ),
                )
              else
                const SizedBox(height: 8),

              const Divider(color: AppColors.feedDivider, height: 1),

              // Lista de opciones y sugerencias dinámicas
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    if (query.isEmpty) ...[
                      // Opción "Todas las ciudades"
                      _buildCityTile(
                        cityName: 'Todas las ciudades',
                        subtitle: 'Ver reportes de todo el país',
                        icon: Icons.public_rounded,
                        isSelected: widget.selectedCity == 'Todas las ciudades',
                        count: widget.countReportsInCity('Todas las ciudades'),
                        onTap: () {
                          widget.onCitySelected('Todas las ciudades');
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Ciudades sugeridas',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'Sugerencias para "${_searchController.text.trim()}"',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],

                    // Sugerencias dinámicas (locales + servicio de mapas en vivo)
                    ...suggestions.map((item) {
                      final count = widget.countReportsInCity(item.name);
                      final isSelected =
                          _ReportsFeedTabState._normalize(widget.selectedCity) ==
                              _ReportsFeedTabState._normalize(item.name);

                      return _buildCityTile(
                        cityName: item.name,
                        subtitle: item.province,
                        icon: Icons.location_on_rounded,
                        isSelected: isSelected,
                        count: count,
                        onTap: () {
                          widget.onCitySelected(item.name);
                          Navigator.pop(context);
                        },
                      );
                    }),

                    // Si se buscó una localidad personalizada que no figura en las sugerencias
                    if (query.isNotEmpty && !hasExactMatch) ...[
                      const Divider(color: AppColors.feedDivider, height: 16),
                      _buildCityTile(
                        cityName: _searchController.text.trim(),
                        subtitle: 'Buscar reportes en esta localidad',
                        icon: Icons.search_rounded,
                        isSelected:
                            _ReportsFeedTabState._normalize(widget.selectedCity) ==
                                query,
                        count: widget
                            .countReportsInCity(_searchController.text.trim()),
                        onTap: () {
                          widget.onCitySelected(_searchController.text.trim());
                          Navigator.pop(context);
                        },
                      ),
                    ],

                    if (query.isNotEmpty &&
                        suggestions.isEmpty &&
                        !_isSearchingLive) ...[
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No se encontraron ciudades sugeridas',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Píldora interactiva de filtrado oficial para modales de Yago.
///
/// Garantiza centrado horizontal y vertical estricto del texto e iconos
/// sin los desajustes métricos de los emojis ni el padding asimétrico de los ChoiceChips de Material 3.
class _FilterPill extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _FilterPill({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
          decoration: BoxDecoration(
            color: isSelected ? effectiveActiveColor : const Color(0xFFF1F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? effectiveActiveColor
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDialogContent extends StatefulWidget {
  final int initialStatusIndex;
  final String initialSpecies;
  final String initialBreed;
  final String initialCity;
  final String defaultUserCity;
  final List<String> statusFilters;
  final List<String> speciesFilters;
  final List<String> popularBreeds;
  final Widget Function(String species, bool isSelected, {double size})
      getSpeciesIcon;
  final Widget Function(int index, bool isSelected, {double size})
      getStatusIcon;
  final String Function(String input) normalize;
  final VoidCallback onOpenCitySelector;
  final void Function({
    required int statusIndex,
    required String species,
    required String breed,
    required String city,
  }) onApplyFilters;

  const _FilterDialogContent({
    required this.initialStatusIndex,
    required this.initialSpecies,
    required this.initialBreed,
    required this.initialCity,
    required this.defaultUserCity,
    required this.statusFilters,
    required this.speciesFilters,
    required this.popularBreeds,
    required this.getSpeciesIcon,
    required this.getStatusIcon,
    required this.normalize,
    required this.onOpenCitySelector,
    required this.onApplyFilters,
  });

  @override
  State<_FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<_FilterDialogContent> {
  late int _tempStatus;
  late String _tempSpecies;
  late String _tempBreed;
  late String _tempCity;
  late final TextEditingController _breedTextController;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.initialStatusIndex;
    _tempSpecies = widget.initialSpecies;
    _tempBreed = widget.initialBreed;
    _tempCity = widget.initialCity;
    _breedTextController = TextEditingController(
      text: widget.initialBreed == 'Todas' ? '' : widget.initialBreed,
    );
  }

  @override
  void dispose() {
    _breedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cabecera superior fija
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtrar reportes',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Personaliza tu búsqueda de mascotas',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.feedDivider, height: 1),
                  const SizedBox(height: 12),

                  // Contenido scrollable
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Tipo de reporte (Estado)
                          const Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Tipo de reporte',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                                widget.statusFilters.length, (idx) {
                              final isSelected = _tempStatus == idx;
                              return _FilterPill(
                                label: widget.statusFilters[idx],
                                icon: widget.getStatusIcon(idx, isSelected,
                                    size: 14),
                                isSelected: isSelected,
                                activeColor: idx == 1
                                    ? AppColors.error
                                    : (idx == 2
                                        ? AppColors.success
                                        : AppColors.primary),
                                onTap: () => setState(() => _tempStatus = idx),
                              );
                            }),
                          ),
                          const SizedBox(height: 18),

                          // 2. Especie del animal
                          const Row(
                            children: [
                              Icon(
                                Icons.pets_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Especie del animal',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.speciesFilters.map((sp) {
                              final isSelected = _tempSpecies == sp;
                              return _FilterPill(
                                label: sp,
                                icon: widget.getSpeciesIcon(sp, isSelected,
                                    size: 14),
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _tempSpecies = sp),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // 3. Raza del animal (Filtro por raza)
                          Row(
                            children: [
                              const Icon(
                                Icons.fingerprint_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Raza del animal',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_tempBreed != 'Todas') ...[
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    _breedTextController.clear();
                                    setState(() => _tempBreed = 'Todas');
                                  },
                                  child: const Text(
                                    'Quitar filtro',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Campo de búsqueda directa de raza
                          TextField(
                            controller: _breedTextController,
                            decoration: InputDecoration(
                              hintText:
                                  'Buscar o escribir raza (ej. Caniche, Mestizo...)',
                              hintStyle: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: AppColors.muted,
                              ),
                              suffixIcon:
                                  _breedTextController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            size: 16,
                                            color: AppColors.muted,
                                          ),
                                          onPressed: () {
                                            _breedTextController.clear();
                                            setState(() => _tempBreed = 'Todas');
                                          },
                                        )
                                      : null,
                              filled: true,
                              fillColor: const Color(0xFFF6F8F9),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _tempBreed =
                                    val.trim().isEmpty ? 'Todas' : val.trim();
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // Píldoras de razas populares
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.popularBreeds.map((breed) {
                              final isSelected =
                                  widget.normalize(_tempBreed) ==
                                      widget.normalize(breed);
                              return _FilterPill(
                                label:
                                    breed == 'Todas' ? 'Todas las razas' : breed,
                                icon: breed == 'Todas'
                                    ? Icon(
                                        Icons.tune_rounded,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                      )
                                    : null,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _tempBreed = breed;
                                    _breedTextController.text =
                                        breed == 'Todas' ? '' : breed;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // 4. Ciudad o localidad
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Ciudad o localidad',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterPill(
                                label: widget.defaultUserCity,
                                icon: Icon(
                                  Icons.near_me_rounded,
                                  size: 14,
                                  color: _tempCity == widget.defaultUserCity
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                isSelected:
                                    _tempCity == widget.defaultUserCity,
                                onTap: () => setState(
                                    () => _tempCity = widget.defaultUserCity),
                              ),
                              _FilterPill(
                                label: 'Todas las ciudades',
                                icon: Icon(
                                  Icons.public_rounded,
                                  size: 14,
                                  color: _tempCity == 'Todas las ciudades'
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                isSelected:
                                    _tempCity == 'Todas las ciudades',
                                onTap: () => setState(
                                    () => _tempCity = 'Todas las ciudades'),
                              ),
                              if (_tempCity != widget.defaultUserCity &&
                                  _tempCity != 'Todas las ciudades')
                                _FilterPill(
                                  label: _tempCity,
                                  icon: const Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  isSelected: true,
                                  onTap: () {},
                                ),
                              _FilterPill(
                                label: 'Más ciudades...',
                                icon: const Icon(
                                  Icons.explore_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                isSelected: false,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  widget.onOpenCitySelector();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: AppColors.feedDivider, height: 1),
                  const SizedBox(height: 14),

                  // Botones de acción inferiores perfectamente centrados y responsivos
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: YagoButton(
                            variant: YagoButtonVariant.secondary,
                            text: 'Restablecer',
                            isFullWidth: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onApplyFilters(
                                statusIndex: 0,
                                species: 'Todos',
                                breed: 'Todas',
                                city: widget.defaultUserCity,
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: YagoButton(
                          text: 'Aplicar filtros',
                          isFullWidth: true,
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onApplyFilters(
                              statusIndex: _tempStatus,
                              species: _tempSpecies,
                              breed: _tempBreed,
                              city: _tempCity,
                            );
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
  }
}

