import 'package:flutter/material.dart';
import '../../utils/design_system.dart';

/// Opción normalizada de raza o apariencia con sinónimos/alias de búsqueda
/// para prevenir errores ortográficos y estandarizar el cotejo con la IA.
class BreedOption {
  final String name;
  final String species; // 'Perro', 'Gato', 'Otro'
  final List<String> searchAliases;

  const BreedOption(
    this.name, {
    required this.species,
    this.searchAliases = const [],
  });
}

/// Campo interactivo de selección y autocompletado de raza para Yago.
///
/// A medida que la persona usuaria escribe (o al desplegar la lista), sugiere
/// las razas correspondientes a la especie seleccionada (`Perro`, `Gato`, `Otro`),
/// evitando errores de tipeo y alineando los nombres con el motor de visión de IA.
/// A la vez, permite conservar texto libre si se trata de una cruza o raza particular.
class YagoBreedSelectorField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String species;
  final int? maxLength;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const YagoBreedSelectorField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.species = 'Perro',
    this.maxLength = 60,
    this.prefixIcon,
    this.onChanged,
  });

  static const List<BreedOption> catalog = [
    // ─── Perros ──────────────────────────────────────────────────────────
    BreedOption(
      'Mestizo',
      species: 'Perro',
      searchAliases: ['cruza', 'callejero', 'criollo', 'sin raza'],
    ),
    BreedOption(
      'Caniche',
      species: 'Perro',
      searchAliases: ['poodle', 'caniche toy', 'caniche mini', 'caniche micro toy'],
    ),
    BreedOption(
      'Labrador Retriever',
      species: 'Perro',
      searchAliases: ['labrador', 'retriever'],
    ),
    BreedOption(
      'Golden Retriever',
      species: 'Perro',
      searchAliases: ['golden', 'retriever dorado'],
    ),
    BreedOption(
      'Cane Corso',
      species: 'Perro',
      searchAliases: ['corso', 'cane corzo', 'mastin italiano'],
    ),
    BreedOption(
      'Ovejero Alemán',
      species: 'Perro',
      searchAliases: ['pastor aleman', 'ovejero', 'alsaciano', 'policia'],
    ),
    BreedOption(
      'Bull Terrier',
      species: 'Perro',
      searchAliases: ['bullterrier', 'ingles'],
    ),
    BreedOption(
      'Pitbull',
      species: 'Perro',
      searchAliases: ['pit bull', 'american pitbull', 'staffordshire', 'amstaff', 'american bully'],
    ),
    BreedOption(
      'Dogo Argentino',
      species: 'Perro',
      searchAliases: ['dogo', 'dogo blanco'],
    ),
    BreedOption(
      'Rottweiler',
      species: 'Perro',
      searchAliases: ['rotweiler', 'rottwailer', 'rotwailer'],
    ),
    BreedOption(
      'Bulldog Francés',
      species: 'Perro',
      searchAliases: ['frenchie', 'buldog frances', 'bulldog'],
    ),
    BreedOption(
      'Bulldog Inglés',
      species: 'Perro',
      searchAliases: ['buldog ingles', 'bulldog'],
    ),
    BreedOption(
      'Perro Salchicha',
      species: 'Perro',
      searchAliases: ['dachshund', 'teckel', 'salchicha'],
    ),
    BreedOption(
      'Chihuahua',
      species: 'Perro',
      searchAliases: ['chiuaua', 'chihuahueño'],
    ),
    BreedOption(
      'Pug',
      species: 'Perro',
      searchAliases: ['carlino', 'mops'],
    ),
    BreedOption(
      'Schnauzer',
      species: 'Perro',
      searchAliases: ['schnauzer miniatura', 'schnauzer gigante', 'esnauzer'],
    ),
    BreedOption(
      'Beagle',
      species: 'Perro',
      searchAliases: ['bigle', 'sabueso'],
    ),
    BreedOption(
      'Bóxer',
      species: 'Perro',
      searchAliases: ['boxer'],
    ),
    BreedOption(
      'Husky Siberiano',
      species: 'Perro',
      searchAliases: ['husky', 'siberiano', 'lobo', 'malamute'],
    ),
    BreedOption(
      'Border Collie',
      species: 'Perro',
      searchAliases: ['collie', 'pastor escoces'],
    ),
    BreedOption(
      'Maltés',
      species: 'Perro',
      searchAliases: ['bichon maltes', 'bichon', 'maltes'],
    ),
    BreedOption(
      'Shih Tzu',
      species: 'Perro',
      searchAliases: ['shitzu', 'shihtzu', 'shi tzu'],
    ),
    BreedOption(
      'Yorkshire Terrier',
      species: 'Perro',
      searchAliases: ['yorkie', 'yorkshire', 'terrier'],
    ),
    BreedOption(
      'Cocker Spaniel',
      species: 'Perro',
      searchAliases: ['cocker', 'spaniel'],
    ),
    BreedOption(
      'Doberman',
      species: 'Perro',
      searchAliases: ['dobermann'],
    ),
    BreedOption(
      'Pinscher Miniatura',
      species: 'Perro',
      searchAliases: ['pinscher', 'pincher', 'mini pincher'],
    ),
    BreedOption(
      'Galgo',
      species: 'Perro',
      searchAliases: ['greyhound', 'whippet', 'galgo criollo'],
    ),
    BreedOption(
      'Pastor Belga Malinois',
      species: 'Perro',
      searchAliases: ['malinois', 'pastor belga', 'ovejero belga'],
    ),
    BreedOption(
      'Boyero de Berna',
      species: 'Perro',
      searchAliases: ['boyero', 'bernes'],
    ),
    BreedOption(
      'Dálmata',
      species: 'Perro',
      searchAliases: ['dalmata', 'manchado'],
    ),
    BreedOption(
      'Pomerania',
      species: 'Perro',
      searchAliases: ['spitz', 'lulú'],
    ),
    BreedOption(
      'Pekinés',
      species: 'Perro',
      searchAliases: ['pekines', 'pequines'],
    ),
    BreedOption(
      'Samoyedo',
      species: 'Perro',
      searchAliases: ['samoyed'],
    ),
    BreedOption(
      'San Bernardo',
      species: 'Perro',
      searchAliases: ['sanbernardo'],
    ),
    BreedOption(
      'Gran Danés',
      species: 'Perro',
      searchAliases: ['gran danes', 'dogo aleman'],
    ),
    BreedOption(
      'Braco Alemán',
      species: 'Perro',
      searchAliases: ['braco', 'pointer'],
    ),
    BreedOption(
      'Weimaraner',
      species: 'Perro',
      searchAliases: ['weimaraner', 'braco de weimar'],
    ),
    BreedOption(
      'Fox Terrier',
      species: 'Perro',
      searchAliases: ['jack russell', 'terrier'],
    ),
    BreedOption(
      'Chow Chow',
      species: 'Perro',
      searchAliases: ['chow', 'lengua azul'],
    ),
    BreedOption(
      'Basset Hound',
      species: 'Perro',
      searchAliases: ['basset', 'hush puppies'],
    ),
    BreedOption(
      'Raza desconocida',
      species: 'Perro',
      searchAliases: ['no se', 'desconocido', 'sin especificar'],
    ),

    // ─── Gatos ───────────────────────────────────────────────────────────
    BreedOption(
      'Gato mestizo',
      species: 'Gato',
      searchAliases: ['comun europeo', 'domestico', 'cruza', 'sin raza'],
    ),
    BreedOption(
      'Gato mestizo bicolor',
      species: 'Gato',
      searchAliases: ['bicolor', 'blanco y negro', 'blanco y naranja', 'manchado'],
    ),
    BreedOption(
      'Gato Atigrado',
      species: 'Gato',
      searchAliases: ['romano', 'tabby', 'rayado', 'gris atigrado', 'naranja atigrado'],
    ),
    BreedOption(
      'Gato Siamés',
      species: 'Gato',
      searchAliases: ['siames', 'ojos azules'],
    ),
    BreedOption(
      'Gato Persa',
      species: 'Gato',
      searchAliases: ['persa', 'pelo largo'],
    ),
    BreedOption(
      'Gato Tricolor / Carey',
      species: 'Gato',
      searchAliases: ['tricolor', 'carey', 'calico'],
    ),
    BreedOption(
      'Gato Angora',
      species: 'Gato',
      searchAliases: ['angora', 'blanco pelo largo'],
    ),
    BreedOption(
      'Maine Coon',
      species: 'Gato',
      searchAliases: ['maine', 'gato gigante'],
    ),
    BreedOption(
      'Raza desconocida',
      species: 'Gato',
      searchAliases: ['no se', 'desconocido'],
    ),

    // ─── Otros animales comunitarios (Regla 4) ───────────────────────────
    BreedOption(
      'Conejo doméstico',
      species: 'Otro',
      searchAliases: ['conejo', 'liebre', 'mini lop', 'cabeza de leon'],
    ),
    BreedOption(
      'Loro / Cotorra',
      species: 'Otro',
      searchAliases: ['loro', 'cotorra', 'amazona', 'loro hablador', 'ave'],
    ),
    BreedOption(
      'Cacatúa / Cocotilla',
      species: 'Otro',
      searchAliases: ['cacatua', 'ninfa', 'cocotilla', 'periquito'],
    ),
    BreedOption(
      'Canario',
      species: 'Otro',
      searchAliases: ['pajaro', 'ave amarilla'],
    ),
    BreedOption(
      'Tortuga terrestre',
      species: 'Otro',
      searchAliases: ['tortuga', 'quelonio'],
    ),
    BreedOption(
      'Cobayo / Cuis',
      species: 'Otro',
      searchAliases: ['cobayo', 'conejillo de indias', 'cuis'],
    ),
    BreedOption(
      'Hámster',
      species: 'Otro',
      searchAliases: ['hamster', 'roedor'],
    ),
    BreedOption(
      'Hurón',
      species: 'Otro',
      searchAliases: ['huron'],
    ),
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

  static List<BreedOption> getSuggestions({
    required String species,
    required String query,
  }) {
    final normSpecies = _normalize(species);
    final speciesItems = catalog.where((item) {
      final itemSp = _normalize(item.species);
      if (normSpecies.contains('perro')) return itemSp == 'perro';
      if (normSpecies.contains('gato')) return itemSp == 'gato';
      if (normSpecies.contains('otro')) return itemSp == 'otro';
      return true;
    }).toList();

    final normQuery = _normalize(query);
    if (normQuery.isEmpty) {
      return speciesItems.take(8).toList();
    }

    // Ordenar: primero los que empiezan con el texto, luego los que lo contienen en nombre o alias
    final startsWithMatches = <BreedOption>[];
    final containsMatches = <BreedOption>[];

    for (final option in speciesItems) {
      final normName = _normalize(option.name);
      if (normName.startsWith(normQuery)) {
        startsWithMatches.add(option);
      } else if (normName.contains(normQuery) ||
          option.searchAliases.any((a) => _normalize(a).contains(normQuery))) {
        containsMatches.add(option);
      }
    }

    return [...startsWithMatches, ...containsMatches].take(6).toList();
  }

  @override
  State<YagoBreedSelectorField> createState() => _YagoBreedSelectorFieldState();
}

class _YagoBreedSelectorFieldState extends State<YagoBreedSelectorField> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant YagoBreedSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _selectBreed(String breedName) {
    widget.controller.text = breedName;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: breedName.length),
    );
    widget.onChanged?.call(breedName);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.controller.text;
    final suggestions = YagoBreedSelectorField.getSuggestions(
      species: widget.species,
      query: query,
    );

    // Ocultar si ya seleccionó exactamente la única sugerencia coincidente y no desplegó manualmente
    final isExactSingleMatch = suggestions.length == 1 &&
        YagoBreedSelectorField._normalize(suggestions.first.name) ==
            YagoBreedSelectorField._normalize(query);

    final shouldDisplayPanel =
        _showSuggestions && suggestions.isNotEmpty && !isExactSingleMatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTypography.footnoteMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLength: widget.maxLength,
          onChanged: (val) {
            if (!_showSuggestions) {
              setState(() => _showSuggestions = true);
            }
            widget.onChanged?.call(val);
          },
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            hintStyle: AppTypography.subheadline.copyWith(color: AppColors.subtle),
            prefixIcon: widget.prefixIcon,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    tooltip: 'Borrar raza',
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                      setState(() => _showSuggestions = true);
                    },
                  ),
                IconButton(
                  icon: Icon(
                    _showSuggestions
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Ver sugerencias de razas',
                  onPressed: () {
                    setState(() {
                      _showSuggestions = !_showSuggestions;
                    });
                  },
                ),
              ],
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border, width: 1.1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border, width: 1.1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (shouldDisplayPanel) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 210),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.feedDivider,
                ),
                itemBuilder: (context, index) {
                  final option = suggestions[index];
                  final isCurrent = YagoBreedSelectorField._normalize(option.name) ==
                      YagoBreedSelectorField._normalize(query);

                  return InkWell(
                    onTap: () => _selectBreed(option.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: 16,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              option.name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
