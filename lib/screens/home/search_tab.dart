import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../services/mock_data_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import '../pet_detail/pet_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _searchController = TextEditingController();
  String _selectedSpecies = 'Todos';
  YagoPetStatus? _selectedStatus;

  final List<String> _speciesOptions = ['Todos', 'Perro', 'Gato', 'Otro'];

  List<Pet> _getFilteredPets() {
    return MockDataService().searchPets(
      query: _searchController.text,
      species: _selectedSpecies,
      status: _selectedStatus,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = _getFilteredPets();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buscar y Filtrar'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros superiores
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                YagoTextField(
                  label: '',
                  hint: 'Buscar por nombre, raza o barrio...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.subtle),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.subtle),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Filtro por especie
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _speciesOptions.map((species) {
                      final isSelected = _selectedSpecies == species;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(species),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSpecies = species);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Filtro por estado semántico
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('Cualquier estado', null),
                      _buildStatusChip('Perdidas', YagoPetStatus.lost),
                      _buildStatusChip('Encontradas', YagoPetStatus.found),
                      _buildStatusChip('Reunidas', YagoPetStatus.reunited),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conteo de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${pets.length} ${pets.length == 1 ? 'mascota encontrada' : 'mascotas encontradas'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_searchController.text.isNotEmpty ||
                    _selectedSpecies != 'Todos' ||
                    _selectedStatus != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _selectedSpecies = 'Todos';
                        _selectedStatus = null;
                      });
                    },
                    child: const Text(
                      'Limpiar filtros',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Lista de resultados
          Expanded(
            child: pets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 56, color: AppColors.subtle),
                          const SizedBox(height: 14),
                          const Text(
                            'Sin resultados para esta búsqueda',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Prueba ajustando los filtros de especie o términos de búsqueda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      final isBookmarked = MockDataService().isBookmarked(pet.id);
                      return PetCard(
                        name: pet.name,
                        details: pet.detailsSummary,
                        locationAndTime: pet.locationAndTime,
                        imageUrl: pet.imageUrl,
                        status: pet.status,
                        tags: pet.tags,
                        storyText: pet.storyText,
                        description: pet.description,
                        authorName: pet.contactName.isNotEmpty ? pet.contactName : 'Comunidad Yago',
                        authorHandle: '@${pet.contactName.toLowerCase().replaceAll(' ', '').replaceAll('.', '')}',
                        commentsCount: 6 + (pet.name.length * 2),
                        sharesCount: 14 + (pet.name.length * 2),
                        likesCount: 88 + (pet.name.length * 11),
                        viewsCount: '${11 + pet.name.length} mil',
                        imagesCount: 2 + (pet.name.length % 3),
                        isBookmarked: isBookmarked,
                        onBookmarkTap: () {
                          setState(() {
                            MockDataService().toggleBookmark(pet.id);
                          });
                        },
                        onContactTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Contacto de ${pet.name}: ${pet.contactName} (${pet.contactPhone})'),
                              backgroundColor: AppColors.textPrimary,
                            ),
                          );
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetDetailScreen(pet: pet),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, YagoPetStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
        },
      ),
    );
  }
}
