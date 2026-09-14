# Sistema de Diseño — Yago (Design System v2.0)

Este documento define el **Design System oficial de Yago**, extraído y formalizado a partir del nuevo lenguaje visual de la aplicación móvil (estilo nórdico, minimalista y limpio). Proporciona las directrices visuales, tokens de diseño y componentes fundamentales para garantizar coherencia, serenidad y una experiencia de usuario premium.

---

## 1. Principios de Diseño

1. **Claridad y Enfoque Humano**: La búsqueda de mascotas requiere empatía, serenidad y foco absoluto en la información esencial (fotografía, estado, ubicación y tiempo transcurrido).
2. **Estética Nórdica & Minimalista (Slate & Earthy Pastels)**: Fondos tipo porcelana (`#F7F8FA`) sobre los que destacan tarjetas blancas limpias (`#FFFFFF`), bordes hairline suaves (`#E3E6EC`) y una paleta sobria de pizarras/grafitos que sustituye el ruido visual anterior.
3. **Color Primario Sobrio (Slate Blue-Grey)**: El tono pizarra (`#5E6672` / `#2B323D`) define la marca, botones principales CTA y elementos activos, aportando elegancia y madurez a la interfaz.
4. **Estados Semánticos Terrosos y Pasteles**: Para evitar la estridencia de los colores neón, los estados emplean combinaciones armónicas de tonos pastel con acentos terrosos desaturados (Terracota/Coral para "Perdida", Verde Eucalipto/Sage para "Encontrada", Celeste Pizarra para "Reunida", e Índigo Lavanda para "Comunidad").
5. **Escala de Espaciado Modular (Base 4px)**: Todo elemento sigue múltiplos de 4px para preservar armonía visual y ritmos consistentes.
6. **Esquinas Suaves**: Radios controlados de `8px` (chips), `12px` (botones e inputs), `16px` (tarjetas y sheets), `20px` (hero) y píldora `9999px`.

---

## 2. Paleta de Colores y Tokens

### 2.1 Colores Base de Marca (Slate & Neutros)

| Token | Hex | Nombre / Rol | Uso Principal |
| :--- | :--- | :--- | :--- |
| `primary` | `#5E6672` | Slate Blue-Grey | Acciones principales, botones CTA, chips activos, botón central de huella |
| `primaryLight` | `#78818F` | Medium Slate | Estados hover/pressed, botones secundarios destacados |
| `primaryDark` | `#2B323D` | Deep Slate / Graphite | Logotipo "Yago", títulos principales, icono activo en barra de navegación |
| `primaryTint` | `#EFF2F6` | Slate Mist | Fondos de botones de acción secundarios (lupa, filtros) |
| `background` | `#F7F8FA` | Porcelain Canvas | Fondo general de todas las pantallas (login, feed, perfil) |
| `surface` | `#FFFFFF` | Pure White | Tarjetas elevadas, campos de texto (inputs), base del dock flotante |
| `surfaceSecondary` | `#F1F3F6` | Soft Ice Surface | Fondos de chips inactivos, pill de estadísticas |
| `border` | `#E3E6EC` | Hairline Slate | Separadores sutiles, bordes de inputs y tarjetas |
| `borderSubtle` | `#ECEFF3` | Subtle Divider | Líneas divisorias internas en perfiles y listas |
| `textPrimary` | `#1D232C` | Charcoal Slate | Títulos principales, nombres de mascotas, textos de alta jerarquía |
| `textSecondary` | `#737C8A` | Slate Grey | Subtítulos, descripciones secundarias, metadatos, contadores |
| `textMuted` / `subtle` | `#9AA1AC` | Cool Silver | Placeholders de inputs, bordes inactivos, iconos secundarios |
| `distanceBadgeBg` | `#FFFFFF` | Frosted White | Fondo del pill de distancia en fotos (opacidad ~88% o sólido) |
| `distanceBadgeText` | `#454E5B` | Graphite Pill | Texto e icono pin de distancia sobre fotografía |

### 2.2 Estados Semánticos de Publicación (Pasteles Terrosos)

| Estado | Badge Sólido (Sobre Foto) | Fondo Suave (Filtros/Chips) | Texto Chip / Acento | Aplicación |
| :--- | :--- | :--- | :--- | :--- |
| **Perdida** | `#D46761` *(Dusty Coral)* | `#FCECEB` | `#C45953` | Mascota reportada como perdida (Urgencia) |
| **Encontrada** | `#4FA175` *(Sage Green)* | `#EAF5EE` | `#428C63` | Mascota reportada como hallada |
| **Reunida** | `#4D88C5` *(Slate Sky Blue)*| `#EBF3FB` | `#3D76B1` | Mascota que regresó con su familia |
| **Comunidad** | `#6E7B8E` *(Muted Indigo)* | `#F2ECF7` | `#70628E` | Avisos comunitarios, tips y social |
| **Nueva / Urgente**| `#D46761` | `#FCECEB` | `#C45953` | Alertas de publicaciones recientes |

---

## 3. Tipografía

La tipografía base es **Inter** (o las fuentes de sistema como SF Pro Display / Text en iOS y Roboto en Android).

| Estilo | Tamaño | Peso | Tracking | Uso |
| :--- | :--- | :--- | :--- | :--- |
| **Display** | `34px` | Extra Light (200) | `-0.02em` | Títulos de impacto o portadas |
| **Title 1** | `28px` | Light (300) | `-0.015em` | Encabezados de secciones principales |
| **Title 2** | `22px` | Regular (400) | `-0.01em` | Nombres de pantallas, subtítulos de sección |
| **Headline** | `17px` | Semi-bold (600) | `-0.005em` | Nombres de mascotas en cards, botones destacados |
| **Body** | `17px` | Regular (400) | `0` | Textos de lectura principal, descripciones largas |
| **Callout** | `16px` | Regular (400) | `0` | Resaltados contextuales, ubicaciones |
| **Subheadline** | `15px` | Regular (400) | `+0.005em` | Datos secundarios, metadatos en feeds |
| **Footnote** | `13px` | Regular (400) | `+0.005em` | Autor, pie de foto, labels de inputs |
| **Caption** | `12px` | Regular / Medium (500) | `+0.01em` | Badges, timestamps, marcas secundarias |

---

## 4. Radios y Espaciado

### 4.1 Radios de Borde (`BorderRadius`)

- **`sm` (8px)**: Tags, chips de características, badges compactos.
- **`md` (12px)**: Botones, campos de texto, avatares cuadrados medianos.
- **`lg` (16px)**: Tarjetas de publicación, modales, bottom sheets, contenedores.
- **`xl` (20px)**: Hero cards, tarjetas destacadas.
- **`full` (9999px)**: Píldoras de estado, avatares circulares, badges flotantes.

### 4.2 Escala de Espaciado (Base 4px)

`4px`, `8px`, `12px`, `16px`, `20px`, `24px`, `32px`, `40px`, `48px`, `64px`.

---

## 5. Componentes de UI

### 5.1 Botones (`YagoButton`)

1. **Primary**:
   - Fondo: `#5E6672` | Texto: `#FFFFFF` | Peso: `500/600` | Radio: `12px`.
   - Uso: "Iniciar sesión", "Publicar mascota", CTA principal.
2. **Secondary**:
   - Fondo: `#F1F3F6` | Texto: `#1D232C` | Borde: Ninguno | Radio: `12px`.
   - Uso: Acciones alternas neutras, herramientas secundarias.
3. **Outline / Ghost**:
   - Fondo: Transparente o `#FFFFFF` | Borde: `1.5px solid #E3E6EC` | Texto: `#4B5361`.
   - Uso: "Crear una cuenta", "Ver más", "Cancelar".
4. **Destructive**:
   - Fondo: `#D46761` | Texto: `#FFFFFF` | Radio: `12px`.
   - Uso: "Eliminar publicación", "Dar de baja".
5. **Icon Button**:
   - Tamaño: `44x44px` | Radio: `12px` o `9999px` | Fondo: `#F1F3F6` con icono `#3E4652`.

### 5.2 Badges & Chips (`YagoBadge` & `YagoTag`)

1. **Status Badge (En foto)**:
   - Formato píldora `9999px`, fondo sólido semántico (`#D46761`, `#4FA175`, `#4D88C5`, `#6E7B8E`), texto e icono en `#FFFFFF`.
2. **Filter Chip (Filtros de feed)**:
   - Activo: Fondo `#5E6672`, texto e icono en `#FFFFFF`.
   - Inactivo: Fondo con tinte pastel (`#FCECEB`, `#EAF5EE`, etc.) con punto/icono y texto en el tono de contraste semántico.

### 5.3 Formularios & Inputs (`YagoTextField`)

- **Contenedor**: Fondo `#FFFFFF`, radio `12px`, padding interno vertical `13-14px`, horizontal `16px`.
- **Borde inactivo**: `1px solid #E3E6EC`.
- **Borde enfocado (Focus)**: `1.5px solid #5E6672` con efecto ring sutil `rgba(94, 102, 114, 0.15)`.
- **Borde de error**: `1.5px solid #D46761` y fondo `#FCECEB`.
- **Label superior**: `fontSize: 13px`, peso `500`, color `#1D232C`.
- **Texto de ayuda/error**: `fontSize: 12px`, color `#737C8A` (normal) o `#D46761` (error).

### 5.4 Tarjetas de Publicación (`PetCard` — Diseño Social Yago)
- **Concepto**: Formato de feed de borde a borde (edge-to-edge) con tipografía Inter, tamaños reducidos y flujo visual vertical:
- **Estructura**:
   1. **Arriba del post (Header)**:
      - **Izquierda**: Avatar circular de usuario (`radius: 17`) + Nombre del reportante (`13.5px, w700`, sin `@user`) + Badge semántico (`PERDIDA`, `ENCONTRADA`, `REUNIDA`).
      - **Derecha**: Horario de la publicación (`12px`).
   2. **Detalle y Texto**: Nombre y resumen de la mascota, descripción concisa y **chip de ubicación** (diseño monocromático de alto contraste, con `BorderRadius.circular(12)`, fondo totalmente negro `Colors.black`, e icono de pin `Icons.location_on_outlined` y tipografía totalmente blancos `Colors.white`).
   3. **[Imagen] (Ancho completo de pantalla)**: Ocupa el 100% del ancho (`width: double.infinity, fit: BoxFit.fitWidth`), con la altura adaptada a la proporción original de la foto.
       - **Botón de mascota superpuesto (Esquina superior derecha)**: Botón flotante monocromático (disco negro translúcido `rgba(0,0,0,0.55)`, borde blanco suave y sombra) con icono animado `AnimatedPawIcon`. Posee la almohadilla principal estática y una animación secuencial donde los 4 dedos van apareciendo uno a uno (`easeOutBack`), orientados apuntando hacia la esquina superior derecha (45°), cerrando el ciclo con una breve pausa antes de reiniciar. Al pulsar, despliega la ficha/modal de características de la mascota.
      - **Contador superpuesto**: Indicador abajo en el centro con fondo oscuro semitransparente (ej. `1/3`).
   4. **Abajo de la imagen (Botones de acción)**:
      - ❤️ **Me Gusta**: Toggle interactivo con contador.
      - ✉️ **Mensaje Directo**: Icono DM (`Icons.mail_outline_rounded`) para contactar al dueño o autor de forma privada.
      - 📤 **Compartir**: Icono (`ios_share`).

### 5.5 Barra de Navegación Inferior (`YagoBottomNavBar`)

- **Estética**: Floating dock con efecto *frosted glass* (vidrio esmerilado), translúcido y desenfocado.
- **Geometría y Radio**: Esquinas redondeadas con radio de curvatura de `24px` (`BorderRadius.circular(24)`) y margen flotante inferior.
- **Transparencia y Desenfoque (Blur)**:
  - Fondo con ligera transparencia: `Colors.white.withValues(alpha: 0.82)`.
  - Filtro de desenfoque gaussian: `BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18))`.
  - El contenido del feed y mapa fluye por detrás (`extendBody: true`), visualizándose opaco, censurado y difuminado elegantemente.
  - Borde perimetral translúcido (`rgba(255, 255, 255, 0.5)`) y sombra difusa suave (`blurRadius: 16`).
- **Sin texto**: Exclusivamente iconografía monocromática nítida y minimalista:
  - Activo: Negro grafito profundo (`#0F1419`) en variante rellena/sólida.
  - Inactivo: Gris neutro tenue (`#536471`) en variante lineal/outline.
- **5 Accesos simétricos**:
  1. **Publicaciones**: `Icons.home_outlined` / `Icons.home_rounded` (Feed comunitario)
  2. **Reportes**: `Icons.campaign_outlined` / `Icons.campaign_rounded` (Pérdidas y hallazgos)
  3. **Cámara IA**: Botón central con `Icons.center_focus_strong_rounded` (Analizador de mascotas en la calle)
  4. **Chat**: `Icons.chat_bubble_outline_rounded` / `Icons.chat_bubble_rounded` (Mensajes directos)
  5. **Perfil**: `Icons.person_outline_rounded` / `Icons.person_rounded` (Cuenta y gestión)

---

## 6. Referencia de Archivos en Flutter (`lib/`)

El sistema de diseño se encuentra implementado y listo para ser consumido en:
- `lib/utils/app_colors.dart`: Constantes de color (Primarios, semánticos, neutros).
- `lib/utils/app_typography.dart`: TextStyles tipográficos basados en la jerarquía oficial.
- `lib/utils/app_radius.dart`: Constantes de radio de borde (`AppRadius`).
- `lib/utils/app_spacing.dart`: Constantes y widgets de espaciado (`AppSpacing`).
- `lib/utils/app_theme.dart`: Configuración de `ThemeData` para Flutter Material 3.
- `lib/utils/design_system.dart`: Barrel file que re-exporta todo el sistema con un único import.
- `lib/widgets/common/yago_button.dart`: Botones estándar del sistema.
- `lib/widgets/common/yago_badge.dart`: Badges semánticos y tags de características.
- `lib/widgets/common/yago_text_field.dart`: Campos de texto y áreas de texto estandarizados.
- `lib/widgets/common/pet_card.dart`: Tarjeta reutilizable de mascotas.
- `lib/widgets/common/yago_bottom_nav_bar.dart`: Barra de navegación inferior oficial.
