import 'package:cloud_firestore/cloud_firestore.dart';
import 'pet.dart';

/// Modelo que representa los rasgos físicos extraídos por el analizador de IA
/// a partir de una fotografía capturada con la cámara o cargada de la galería (HU-S3-02).
///
/// Cumple con la Regla 4 (Diversidad de Especies y Neutralidad de Atributos):
/// soporta perros, gatos, aves, tortugas, conejos y otros animales sin sesgos
/// biológicos cerrados.
class AiPetAnalysis {
  final String id;
  final String imageSource;
  final bool isAnimal; // Indica si la imagen contiene efectivamente un animal
  final String? nonAnimalReason; // Motivo o elemento detectado cuando no es un animal
  final String species; // 'Perro', 'Gato', 'Otro'
  final String apparentBreed; // Raza o apariencia física detectada
  final List<String> colors; // Colores predominantes del pelaje/plumaje/caparazón
  final List<String> distinctiveTraits; // Señas particulares (collar, manchas, tamaño, etc.)
  final double confidence; // Nivel de confianza del análisis (0.0 a 1.0)
  final String summary; // Descripción fenotípica generada por el modelo
  final DateTime analyzedAt;

  const AiPetAnalysis({
    required this.id,
    required this.imageSource,
    this.isAnimal = true,
    this.nonAnimalReason,
    required this.species,
    required this.apparentBreed,
    required this.colors,
    required this.distinctiveTraits,
    this.confidence = 0.94,
    required this.summary,
    required this.analyzedAt,
  });

  /// Genera una lista combinada de etiquetas para reutilizar al crear un reporte (HU-S3-06).
  List<String> get combinedTags {
    final result = <String>[];
    for (final c in colors) {
      final clean = c.trim();
      if (clean.isNotEmpty && !result.contains(clean)) {
        result.add(clean);
      }
    }
    for (final t in distinctiveTraits) {
      final clean = t.trim();
      if (clean.isNotEmpty && !result.contains(clean)) {
        result.add(clean);
      }
    }
    return result;
  }

  /// Genera una descripción sugerida lista para reutilizar en un nuevo reporte de hallazgo (HU-S3-06).
  String get suggestedReportDescription {
    final colorsText = colors.isNotEmpty ? 'Colores: ${colors.join(", ")}. ' : '';
    final traitsText = distinctiveTraits.isNotEmpty
        ? 'Señas particulares: ${distinctiveTraits.join(", ")}. '
        : '';
    return '$summary $colorsText$traitsText'
        'Analizado mediante Cámara con IA de Yago en la vía pública.';
  }

  AiPetAnalysis copyWith({
    String? id,
    String? imageSource,
    bool? isAnimal,
    String? nonAnimalReason,
    String? species,
    String? apparentBreed,
    List<String>? colors,
    List<String>? distinctiveTraits,
    double? confidence,
    String? summary,
    DateTime? analyzedAt,
  }) {
    return AiPetAnalysis(
      id: id ?? this.id,
      imageSource: imageSource ?? this.imageSource,
      isAnimal: isAnimal ?? this.isAnimal,
      nonAnimalReason: nonAnimalReason ?? this.nonAnimalReason,
      species: species ?? this.species,
      apparentBreed: apparentBreed ?? this.apparentBreed,
      colors: colors ?? this.colors,
      distinctiveTraits: distinctiveTraits ?? this.distinctiveTraits,
      confidence: confidence ?? this.confidence,
      summary: summary ?? this.summary,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageSource': imageSource,
      'isAnimal': isAnimal,
      if (nonAnimalReason != null) 'nonAnimalReason': nonAnimalReason,
      'species': species,
      'apparentBreed': apparentBreed,
      'colors': colors,
      'distinctiveTraits': distinctiveTraits,
      'confidence': confidence,
      'summary': summary,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
    };
  }

  factory AiPetAnalysis.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    if (map['analyzedAt'] is Timestamp) {
      parsedDate = (map['analyzedAt'] as Timestamp).toDate();
    } else if (map['analyzedAt'] is String) {
      parsedDate = DateTime.tryParse(map['analyzedAt'] as String) ?? DateTime.now();
    }

    return AiPetAnalysis(
      id: map['id'] as String? ?? docId,
      imageSource: map['imageSource'] as String? ?? '',
      isAnimal: map['isAnimal'] as bool? ?? true,
      nonAnimalReason: map['nonAnimalReason'] as String?,
      species: map['species'] as String? ?? 'Perro',
      apparentBreed: map['apparentBreed'] as String? ?? 'Mestizo',
      colors: List<String>.from(map['colors'] ?? const []),
      distinctiveTraits: List<String>.from(map['distinctiveTraits'] ?? const []),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.9,
      summary: map['summary'] as String? ?? '',
      analyzedAt: parsedDate,
    );
  }
}

/// Resultado de comparación entre la foto analizada por IA y un reporte activo
/// (mascota perdida o mascota encontrada) en la base de datos de Yago (HU-S3-03 y HU-S3-04).
class AiMatchResult {
  final Pet pet;
  final int similarityPercentage; // Porcentaje de similitud visual (0 a 100)
  final List<String> matchingTraits; // Rasgos específicos en los que coincidieron
  final String analyzedImageSource; // Imagen capturada/cargada por el usuario

  const AiMatchResult({
    required this.pet,
    required this.similarityPercentage,
    required this.matchingTraits,
    required this.analyzedImageSource,
  });

  /// Indica si la coincidencia tiene una similitud alta (>= 75%).
  bool get isHighSimilarity => similarityPercentage >= 75;

  /// Etiqueta descriptiva del nivel de coincidencia (umbral mínimo 50%).
  String get confidenceLabel {
    if (similarityPercentage >= 75) return 'Alta probabilidad';
    if (similarityPercentage >= 60) return 'Coincidencia media';
    return 'Coincidencia posible';
  }
}
