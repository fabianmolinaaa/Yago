# Sistema de Diseño — Yago (Design System v1.0)

Este documento define el **Design System oficial de Yago**, extraído y formalizado a partir del diseño de la aplicación móvil. Proporciona las directrices visuales, tokens de diseño y componentes fundamentales para garantizar coherencia, simplicidad y una experiencia de usuario premium (iOS-first, moderna y limpia).

---

## 1. Principios de Diseño

1. **Claridad y Enfoque Humano**: La búsqueda de mascotas requiere urgencia, serenidad y claridad visual. La interfaz prioriza información relevante (foto, estado, ubicación y tiempo transcurrido).
2. **Estética iOS-first & Minimalista**: Fondos predominantemente blancos y grises tenues (`#FFFFFF`, `#F5F5F7`), tipografía limpia inspirada en Apple/Inter, bordes hairline sutiles (`#E5E5EA`) y sombras imperceptibles.
3. **Color como Señal de Atención**: El naranja cálido (`#FF6B35`) se reserva para la identidad y acciones primarias (CTA). Los colores semánticos (rojo para "Perdida", verde para "Encontrada", celeste para "Reunida", morado para "Comunidad") indican el estado instantáneamente.
4. **Escala de Espaciado Modular (Base 4px)**: Todo elemento sigue múltiplos de 4px para preservar armonía visual y ritmos consistentes.
5. **Esquinas Suaves**: Radios controlados de `8px` (chips), `12px` (botones e inputs), `16px` (tarjetas y sheets), `20px` (hero) y píldora `9999px`.

---

## 2. Paleta de Colores y Tokens

### 2.1 Colores Base de Marca

| Token | Hex | Nombre / Rol | Uso Principal |
| :--- | :--- | :--- | :--- |
| `primary` | `#FF6B35` | Yago Orange | Acciones principales, botones primarios, estados activos, FAB central |
| `foreground` | `#1D1D1F` | Negro Tipográfico | Títulos, textos principales, iconos activos |
| `muted` | `#6E6E73` | Gris Medio | Texto secundario, descripciones, subtítulos, etiquetas |
| `subtle` | `#AEAEB2` | Gris Claro | Placeholders, bordes inactivos, iconos secundarios |
| `background` | `#FFFFFF` | Blanco Puro | Fondo de pantallas principales y tarjetas elevadas |
| `surface` | `#F5F5F7` | Gris Superficie | Fondos secundarios, contenedores de inputs, chips neutros |
| `border` | `#E5E5EA` | Gris Borde | Separadores hairline, bordes de tarjeta e inputs inactivos |
| `feedDivider` | `#EFF3F4` | Divisor Social | Separador horizontal hairline de publicaciones estilo Twitter |
| `twitterHandle` | `#536471` | Handle & Timestamp | Nombre de usuario (@handle), tiempos y metadatos sociales |
| `twitterAction` | `#536471` | Icono Social Inactivo | Iconos de comentarios, repost, vistas y compartir |
| `retweetGreen` | `#00BA7C` | Verde Repost | Acción activa de retweet/difusión |
| `likeRed` | `#F91880` | Rosa/Rojo Like | Estado activo del botón de Me Gusta / Apoyo |
| `viewBlue` | `#1D9BF0` | Azul Hashtag / Vistas | Hashtags clicables y métricas de visualización |

### 2.2 Estados Semánticos de Publicación

| Estado | Color Texto / Acento | Fondo Suave (Tint) | Aplicación |
| :--- | :--- | :--- | :--- |
| **Perdida** | `#FF3B30` | `#FFF2F1` | Mascota reportada como perdida (Urgencia) |
| **Encontrada** | `#34C759` | `#F1FFF5` | Mascota reportada como hallada en la vía pública |
| **Reunida** | `#5AC8FA` | `#F0FAFE` | Caso con final feliz; mascota devuelta a su hogar |
| **Comunidad** | `#AF52DE` | `#F8F0FE` | Publicaciones sociales, consejos, noticias comunitarias |
| **Nueva / Urgente**| `#FF9500` / `#FF3B30` | `#FFF8F0` / `#FFF2F1` | Alertas de publicaciones recientes de alta prioridad |

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
   - Fondo: `#FF6B35` | Texto: `#FFFFFF` | Peso: `500/600` | Radio: `12px`.
   - Uso: "Publicar mascota", "Contactar", acciones principales.
2. **Secondary**:
   - Fondo: `#F5F5F7` | Texto: `#1D1D1F` | Borde: Ninguno o sutil | Radio: `12px`.
   - Uso: "Mis mascotas", acciones alternas neutras.
3. **Outline / Ghost**:
   - Fondo: Transparente | Borde: `1.5px solid #FF6B35` o `#E5E5EA` | Texto: `#FF6B35` o `#1D1D1F`.
   - Uso: "Ver más", "Cancelar".
4. **Destructive**:
   - Fondo: `#FF3B30` | Texto: `#FFFFFF` | Radio: `12px`.
   - Uso: "Eliminar publicación", "Dar de baja".
5. **Icon Button**:
   - Tamaño: `44x44px` | Radio: `12px` o `9999px` | Fondo: `#F5F5F7` o `#FF6B35`.

### 5.2 Badges & Chips (`YagoBadge` & `YagoTag`)

1. **Status Badge**:
   - Texto en mayúsculas pequeñas o formato capitalizado, `fontSize: 11-12px`, peso `600/700`, padding `4px 10px`, radio `9999px`.
   - Colores emparejados (ej: Texto `#FF3B30` sobre fondo `#FFF2F1`).
2. **Feature Tag (Chips de características)**:
   - Texto: `#6E6E73` o `#1D1D1F`, fondo: `#F5F5F7`, borde: `1px solid #E5E5EA`.
   - Ejemplos: `Collar rojo`, `Con chip`, `Hembra`, `3 años`.

### 5.3 Formularios & Inputs (`YagoTextField`)

- **Contenedor**: Fondo `#FFFFFF`, radio `12px`, padding interno vertical `13-14px`, horizontal `16px`.
- **Borde inactivo**: `1px solid #E5E5EA`.
- **Borde enfocado (Focus)**: `1.5px solid #FF6B35` con efecto ring difuminado `rgba(255, 107, 53, 0.15)`.
- **Borde de error**: `1.5px solid #FF3B30` y fondo con tinte suave `#FFF2F1`.
- **Label superior**: `fontSize: 13px`, peso `500`, color `#1D1D1F`.
- **Texto de ayuda/error**: `fontSize: 12px`, color `#6E6E73` (normal) o `#FF3B30` (error).

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
     - 💬 **Comentarios**: Contador de comentarios.
     - ❤️ **Me Gusta**: Toggle interactivo con contador.
     - ✉️ **Mensaje Directo**: Icono DM (`Icons.mail_outline_rounded`) para contactar al dueño.
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
  1. **Inicio**: `Icons.home_outlined` / `Icons.home_rounded`
  2. **Buscar**: `Icons.search_rounded`
  3. **Publicar**: Botón minimalista de trazo fino redondeado con `Icons.add_rounded`
  4. **Mapa**: `Icons.map_outlined` / `Icons.map_rounded`
  5. **Perfil**: `Icons.person_outline_rounded` / `Icons.person_rounded`

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
