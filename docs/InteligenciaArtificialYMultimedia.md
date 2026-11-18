# Arquitectura de Visión Artificial, Matching y Procesamiento de Imágenes — Yago

Este documento describe el funcionamiento técnico del motor de **Identificación de Mascotas y Matching por IA** de Yago (`lib/services/ai_vision_service.dart` y `lib/screens/home/ai_camera_screen.dart`), la calibración del umbral de similitud (50%), el funcionamiento sin conexión (*On-Device*) y el pipeline de compresión de imágenes de la aplicación.

---

## 1. ¿Cómo funciona la identificación de mascotas? (Arquitectura Híbrida)

Cuando el usuario saca una foto o sube una imagen de la galería, Yago analiza la fotografía para cumplir tres pasos:
1. **Verificar** que sea un animal real (`isAnimal`).
2. **Extraer sus rasgos físicos:** especie (`Perro`, `Gato` u `Otro`), raza aparente (`apparentBreed`), colores predominantes (`colors`) y señas particulares (`distinctiveTraits`).
3. **Buscar coincidencias (*matches*)** en los reportes activos (`Perdidos` y `Encontrados`).

Para garantizar alta precisión y disponibilidad continua sin costos operativos, combina dos motores:

### 1.1. Con Internet (IA Multimodal en la Nube)
* Envía la fotografía (redimensionada previamente si supera los `900 KB`) al modelo multimodal **`qwen/qwen3.8-27b`** mediante la API de Groq (con soporte compatible para Google Gemini Multimodal).
* Identifica con alta precisión si hay un animal real, su especie (`Perro`, `Gato`, `Otro`), su raza específica en español (*Bull Terrier, Rottweiler, Dogo Argentino, Caniche, Ovejero Alemán, Gato Siamés*, etc.), los colores reales ignorando el fondo y las señas visibles (collares, manchas, porte).

### 1.2. Sin Internet / Fallback en el Celular (On-Device AI)
Si no hay conexión a internet o falla la red, el análisis corre directamente en el procesador del teléfono combinando tres herramientas locales:
1. **Google ML Kit Base:** Verifica que en la foto haya un animal real y descarta fotos de objetos, muebles, vehículos, personas o paisajes.
2. **Modelo Neuronal TFLite (`assets/ml/imagenet_breeds.tflite`):** Red neuronal liviana (*EfficientNet-Lite0* entrenada sobre las 1.000 clases de ImageNet) integrada en la app que reconoce más de **120 razas específicas** de perros (`151..268`), gatos (`281..285`) y otros animales comunitarios (conejos, loros, aves, tortugas, roedores, hurones).
3. **Muestreo de Color HSV (`_sampleSubjectColorsFromFile`):** Analiza una grilla de $48 \times 48$ píxeles sobre el centro de la imagen (donde se ubica el animal) e ignora los bordes y colores de fondo (verde de pasto o azul de cielo) para detectar los colores predominantes del pelaje (*Blanco, Negro, Marrón, Dorado/Naranja, Gris* o *Bicolor*).

---

## 2. ¿Cómo se calcula y calibra el umbral de similitud (50%)?

Una vez extraídos los rasgos del animal, el método `evaluateMatch` los compara contra todos los reportes activos (`lost` y `found`) sumando puntos en una escala de **0% a 96%**:

| Criterio | Puntaje / Penalización | Regla aplicada |
| :--- | :---: | :--- |
| **1. Especie** | **Filtro excluyente** o **+20%** | Si la especie no coincide (*ej. Perro vs. Gato*), se descarta con **0%**. Si coincide, suma una base de **+20%**. |
| **2. Raza o Tipo** | Hasta **+28%** (o **-12%**) | Suma **+28%** si coinciden en una raza específica o grupo equivalente (*ej. Bull Terrier con Bull Terrier*); **+14%** si ambos son mestizos; resta **-12%** si son razas específicas distintas (*ej. Caniche vs. Rottweiler*). |
| **3. Colores del pelaje** | Hasta **+28%** (o **-12%**) | Suma **+20%** si coincide el color principal y **+8%** extra si coincide el secundario (contemplando sinónimos como *Naranja = Dorado = Rubio* o *Marrón = Chocolate*). Si no comparten ningún color, resta **-12%**. |
| **4. Señas particulares** | Hasta **+18%** | Suma **+7%** por cada coincidencia en etiquetas (`tags`) o descripción (*ej. collar verde, pecho blanco, moño rosa*). |
| **5. Fisonomía visual** | **+24%** | Bonificación cuando coincide la referencia visual directa (con tope global en **96%**). |

### ¿Por qué el umbral es del 50%?
Se calibró en **50%** (`defaultMinSimilarityThreshold = 50`) para mostrar únicamente coincidencias relevantes:
* **Debajo del 50% (Descartado):** Dos animales que solo comparten la especie pero tienen distinta raza o color quedan entre **8% y 26%**, evitando llenar la pantalla de falsos positivos.
* **50% o más (Match válido):** Para superar el 50%, el animal fotografiado debe coincidir obligatoriamente en **especie** y además compartir **raza + color** ($20\% + 28\% + 20\% = \mathbf{68\%}$) o **tipo mestizo + color + seña particular** ($20\% + 14\% + 20\% + 7\% = \mathbf{61\%}$).

---

## 3. Flujo de Resultados en Pantalla

1. **Validación de animal:** Si la imagen no corresponde a un animal, muestra una pantalla de aviso pidiendo tomar otra foto.
2. **Matches primero:** Si es un animal, muestra en primer lugar los reportes que alcanzan o superan el **50% de similitud** (ordenados de mayor a menor) con fotos comparativas lado a lado y botón de **Chat Directo** con el dueño.
3. **Rasgos extraídos y Nuevo Reporte:** Debajo muestra los rasgos detectados por la IA (editables manualmente por el usuario) y un botón para **generar un nuevo reporte** que reutiliza automáticamente la foto y los datos extraídos, reiniciando el escáner una vez publicado.

---

## 4. Compresión y Optimización de Imágenes en la App

Para reducir el consumo de datos móviles, acelerar la carga del feed y optimizar el espacio en **Firebase Cloud Storage** sin sacrificar la nitidez visual necesaria para reconocer mascotas, Yago implementa un motor centralizado de **compresión no agresiva de alta fidelidad** en [`lib/utils/image_compressor.dart`](../lib/utils/image_compressor.dart) e integrado en [`lib/services/storage_service.dart`](../lib/services/storage_service.dart).

### 4.1. Perfiles de Compresión Calibrados (`ImageCompressionPreset`)

| Perfil (`ImageCompressionPreset`) | Módulos donde se aplica | Dimensión Máxima (`maxDimension`) | Calidad JPEG (`quality`) | Umbral de Omisión Inteligente (*Smart Skip*) | Peso Típico Resultante |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **`postAndReport`** | • Crear Reporte (`CreateReportScreen`)<br>• Crear Publicación / Apareamiento / Consejo (`CreatePostScreen`)<br>• Captura desde Cámara IA (`AiCameraScreen`) | **1600 px** (Full HD+ proporcional) | **85%** | `<= 350 KB` | **220 KB – 480 KB** *(ahorro del 85%–92% frente a fotos de 5–10 MB)* |
| **`avatar`** | • Foto de Perfil (`EditProfileScreen`) | **800 px** (Retina 3x circular) | **85%** | `<= 150 KB` | **55 KB – 120 KB** |
| **`aiCloudPayload`** | • Inferencia Multimodal en la Nube (`AiVisionService._prepareImageForCloud`) | **1024 px** | **82%** | `<= 300 KB` | **140 KB – 320 KB** |

### 4.2. Reglas de Calidad y Seguridad del Pipeline (`ImageCompressor`)

1. **Compresión Hardware-Accelerated (`flutter_image_compress`):**
   * Convierte fotografías pesadas (incluyendo capturas crudas del sensor de cámara, PNG o HEIC de galería) a formato estándar **JPEG (`.jpg`)** al **85% de calidad**, conservando intactos los detalles finos del pelaje, ojos, manchas y collares.
2. **Corrección de Orientación y Privacidad EXIF:**
   * Activa `autoCorrectionAngle: true` para enderezar automáticamente fotografías tomadas en orientación vertical u horizontal con la cámara del celular.
   * Define `keepExif: false` para limpiar metadatos sensibles del dispositivo (coordenadas GPS crudas incrustadas en el archivo original y datos de serie del teléfono) antes de subir la imagen a la nube pública.
3. **Omisión Inteligente (*Smart Skip*) y Guardia de No-Inflado (*Size Guard*):**
   * Si el usuario selecciona una imagen JPEG que ya es liviana (menor a `350 KB` en publicaciones/reportes o `150 KB` en avatares) y sus dimensiones no superan el máximo del perfil, **no se vuelve a recomprimir**, evitando cualquier pérdida generacional de calidad.
   * Si por las características de una imagen ya comprimida el resultado procesado pesara igual o más que el archivo original, se conserva automáticamente el archivo más liviano.
4. **Doble Punto de Control (Selección + Subida):**
   * La compresión actúa tanto al seleccionar/capturar la imagen (`StorageService.pickImage` y `AiCameraScreen._handleShutterTap`) como antes de transmitir el archivo a Firebase Cloud Storage (`StorageService.uploadImage`), garantizando que ningún módulo de la aplicación pueda subir fotografías sin optimizar.
