# Estructura del Proyecto — Yago

Este documento describe la arquitectura de carpetas, la organización modular del código fuente y el desglose de archivos para la aplicación móvil **Yago** en Flutter.

---

## 1. Árbol de Carpetas del Proyecto (`lib/` y `docs/`)

```text
Yago/
├── docs/
│   ├── Alcance.md                      # Alcance funcional y requerimientos del proyecto
│   ├── DesignSystem.md                 # Especificación oficial del Design System (tokens, colores, componentes)
│   ├── Estructura.md                   # Arquitectura y mapa de carpetas (este documento)
│   ├── Roles.md                        # Definición de roles (Usuario y Administrador)
│   ├── Tecnologias.md                  # Stack tecnológico (Flutter, Firebase, etc.)
│   └── designSystem/                   # Referencia exportada de Figma Make (React + Vite + Tailwind v4)
│
├── lib/
│   ├── main.dart                       # Punto de entrada de la app (YagoApp con AuthGate y configuración del tema)
│   ├── firebase_options.dart           # Configuración de Firebase para Android generada por FlutterFire
│   │
│   ├── utils/                          # Tokens de diseño, constantes y configuración visual
│   │   ├── app_colors.dart             # Paleta de colores oficial de Yago y estados semánticos
│   │   ├── app_typography.dart         # Jerarquía tipográfica oficial (Display, Title, Body, Caption, etc.)
│   │   ├── app_radius.dart             # Radios de curvatura estándar (sm, md, lg, xl, full)
│   │   ├── app_spacing.dart            # Escala y espaciadores modulares en base 4px
│   │   ├── app_theme.dart              # Configuración global de ThemeData (Material 3)
│   │   └── design_system.dart          # Barrel file (exporta todos los tokens en un único import)
│   │
│   ├── widgets/                        # Componentes de UI reutilizables
│   │   └── common/                     # Componentes base del Design System
│   │       ├── yago_button.dart        # Botones (Primary, Secondary, Outline, Destructive, Icon)
│   │       ├── yago_badge.dart         # Badges de estado (Perdida, Encontrada, etc.) y tags de atributos
│   │       ├── yago_text_field.dart    # Inputs de formulario y áreas de texto con estados
│   │       ├── pet_card.dart           # Tarjeta de publicación de mascota (imagen, tags, badge flotante)
│   │       ├── yago_bottom_nav_bar.dart# Barra inferior con botón central "Publicar" en naranja
│   │       └── widgets.dart            # Barrel file (exporta todos los widgets comunes)
│   │
│   ├── models/                         # Modelos de datos del dominio
│   │   ├── pet.dart                    # Modelo de reporte y perfil de mascota (perdida, encontrada, reunida)
│   │   └── feed_post.dart              # Modelo de publicación social y comunitaria del feed
│   │
│   ├── screens/                        # Pantallas y vistas de la aplicación
│   │   ├── auth/
│   │   │   ├── auth_gate.dart          # Puerta de enlace reactiva para estado de autenticación (Firebase Auth)
│   │   │   ├── login_screen.dart       # Inicio de sesión con validación, recuperación de clave e identidad Yago
│   │   │   └── register_screen.dart    # Registro de nuevos usuarios con validaciones y Design System
│   │   ├── home/
│   │   │   ├── home_screen.dart        # Contenedor principal con YagoBottomNavBar de 5 accesos
│   │   │   ├── feed_tab.dart           # Feed de publicaciones con filtros rápidos (Perdidas, Encontradas, etc.)
│   │   │   ├── search_tab.dart         # Explorador y búsqueda reactiva con filtros de especie y estado
│   │   │   ├── create_report_screen.dart # Publicación de mascotas perdidas y encontradas con fotos y atributos
│   │   │   ├── pet_map_tab.dart        # Mapa interactivo de geolocalización de mascotas con pines
│   │   │   └── profile_tab.dart        # Perfil del usuario, estadísticas, reportes propios y logout
│   │   └── pet_detail/
│   │       └── pet_detail_screen.dart  # Ficha detallada de la mascota con atributos, mapa y contacto directo
│   │
│   └── services/                       # Integraciones con backend y APIs
│       ├── auth_service.dart           # Servicio de autenticación con Firebase Auth y traducción de errores
│       └── mock_data_service.dart      # Servicio de datos simulados de mascotas y comunidad para desarrollo
│
└── test/
    └── widget_test.dart                # Pruebas automatizadas de la app, componentes del Design System y PetCard
```

---

## 2. Detalle de Carpetas con Código Reciente

### 2.1 `lib/utils/` — Tokens y Sistema de Diseño

Esta carpeta contiene la **fundación visual** de Yago. Todo el estilo se centraliza aquí para evitar valores hardcodeados en las vistas.

| Archivo | ¿Qué contiene? | ¿Para qué sirve? |
| :--- | :--- | :--- |
| **`app_colors.dart`** | Tokens de color de marca (`primary` `#FF6B35`, `surface` `#F5F5F7`, `foreground` `#1D1D1F`, `border` `#E5E5EA`) y colores semánticos (`lost` `#FF3B30`, `found` `#34C759`, `reunited` `#5AC8FA`, `community` `#AF52DE`). | Centraliza los colores oficiales de la app para botones, textos, fondos y estados de mascotas. |
| **`app_typography.dart`** | Estilos de texto (`display`, `title1`, `title2`, `headline`, `body`, `callout`, `subheadline`, `footnote`, `caption`). | Garantiza una jerarquía tipográfica uniforme basada en Inter y directrices de iOS. |
| **`app_radius.dart`** | Radios constantes: `sm` (8px), `md` (12px), `lg` (16px), `xl` (20px) y `full` (9999px). | Estandariza las esquinas redondeadas en tarjetas, botones, inputs y avatares. |
| **`app_spacing.dart`** | Escala modular (4, 8, 12, 16, 20, 24, 32, 40, 48, 64 px) y widgets `SizedBox` (`gap4`, `gap8`, `gap12`, etc.). | Mantiene márgenes y separaciones visuales consistentes en toda la app. |
| **`app_theme.dart`** | Configuración de `ThemeData` en Material 3. | Aplica los colores, tipografía, estilo de AppBar, Inputs, Cards y Botones a nivel global. |
| **`design_system.dart`** | Archivo *barrel export*. | Permite importar todos los tokens anteriores con una sola línea: `import 'package:yago/utils/design_system.dart';`. |

---

### 2.2 `lib/widgets/common/` — Componentes UI Reutilizables

Contiene los bloques de construcción gráficos listos para ser utilizados en cualquier pantalla del proyecto:

| Archivo | Componentes Incluidos | ¿Para qué sirve? |
| :--- | :--- | :--- |
| **`yago_button.dart`** | `YagoButton`, `YagoIconButton` | Botones estándar con variantes (`primary`, `secondary`, `outline`, `destructive`), tamaños (`large`, `defaultSize`, `small`), soporte para loading e iconos. |
| **`yago_badge.dart`** | `YagoStatusBadge`, `YagoFeatureTag` | **StatusBadge**: Etiquetas de estado (`PERDIDA`, `ENCONTRADA`, `REUNIDA`, `COMUNIDAD`).<br>**FeatureTag**: Chips redondeados para atributos físicos (`Collar rojo`, `Hembra`, `Con chip`). |
| **`yago_text_field.dart`** | `YagoTextField` | Campos de formulario con etiqueta superior, placeholder, focus con halo naranja, estado de error tintado en `#FFF2F1` y soporte multilínea. |
| **`pet_card.dart`** | `PetCard` | Tarjeta completa de publicación de mascota: foto de portada, badge de estado flotante, botón de guardado (bookmark), título, datos de raza/edad, ubicación, tiempo y tags. |
| **`yago_bottom_nav_bar.dart`** | `YagoBottomNavBar` | Barra de navegación inferior con las 5 pestañas oficiales y botón central "Publicar" en naranja cálido con bordes redondeados. |
| **`widgets.dart`** | Archivo *barrel export*. | Permite importar todos los widgets comunes con: `import 'package:yago/widgets/common/widgets.dart';`. |

---

### 2.3 `lib/screens/auth/` — Autenticación

| Archivo | ¿Qué contiene? |
| :--- | :--- |
| **`auth_gate.dart`** | Puerta de enlace reactiva con `StreamBuilder<User?>` escuchando `authStateChanges`. Redirige automáticamente a `HomeScreen` si hay sesión activa, a `LoginScreen` si no la hay, o muestra un loader con la identidad de Yago. |
| **`login_screen.dart`** | Pantalla de inicio de sesión integrada con Firebase Auth: validación de correo y contraseña, indicador de carga en `YagoButton`, alertas de error en español, diálogo de recuperación de clave y enlace a registro. |
| **`register_screen.dart`** | Pantalla de registro de nuevos usuarios: campos de nombre completo, correo, contraseña y confirmación, validaciones de seguridad (mínimo 6 caracteres) e integración con `AuthService.registerWithEmailAndPassword`. |

---

### 2.4 `lib/screens/home/` & `lib/screens/pet_detail/` — Pantallas de la Aplicación

| Archivo | ¿Qué contiene? |
| :--- | :--- |
| **`home_screen.dart`** | Contenedor principal de la aplicación que orquesta la barra de navegación `YagoBottomNavBar` con sus 5 accesos (Inicio, Buscar, Publicar, Mapa y Perfil). |
| **`feed_tab.dart`** | Pestaña de inicio con feed de reportes de mascotas, selector de filtros rápidos por estado (*Perdidas*, *Encontradas*, *Reunidas*, *Comunidad*), pull-to-refresh y alertas comunitarias. |
| **`search_tab.dart`** | Buscador dinámico por texto, raza, nombre y ubicación, complementado con filtros por especie (*Perro*, *Gato*, *Otro*) y estado semántico. |
| **`create_report_screen.dart`** | Formulario completo para publicar reportes de mascotas perdidas o encontradas: selector de tipo, fotos, especie, sexo, edad, ubicación, señas particulares (`tags`) y teléfono de contacto. |
| **`pet_map_tab.dart`** | Mapa de geolocalización con pines interactivos coloreados según el estado (`AppColors.lost`, `AppColors.found`, `AppColors.reunited`) y tarjeta emergente de vista previa. |
| **`profile_tab.dart`** | Pestaña de perfil del usuario autenticado: métricas personales, gestión de reportes propios publicados y botón seguro de cierre de sesión. |
| **`pet_detail_screen.dart`** | Ficha detallada de la mascota con foto expandida, atributos físicos, ubicación del último avistamiento, descripción del caso y botón directo de contacto telefónico / mensajería. |

---

### 2.5 `lib/services/` — Servicios y Lógica de Negocio

| Archivo | ¿Qué contiene? |
| :--- | :--- |
| **`auth_service.dart`** | Servicio singleton centralizado para Firebase Authentication: métodos para login, registro con `displayName`, recuperación de contraseña, cierre de sesión, flujo `authStateChanges` y mapeo completo de `FirebaseAuthException` a mensajes amigables. |
| **`mock_data_service.dart`** | Servicio singleton de datos simulados en memoria para mascotas (perdidas, encontradas, resueltas), marcadores guardados y publicaciones del feed comunitario. |

---

### 2.6 `docs/` — Documentación del Proyecto

| Archivo / Carpeta | Propósito |
| :--- | :--- |
| **`DesignSystem.md`** | Documento canónico con la especificación completa del Design System (tokens, colores, tipografía, componentes y directrices). |
| **`designSystem/`** | Carpeta de referencia que contiene la exportación de Figma Make en React + Vite + Tailwind CSS v4 de la cual se extrajo el diseño. |
| **`Alcance.md`** | Objetivos, usuarios, funcionalidades dentro y fuera del alcance del proyecto Yago. |
| **`Estructura.md`** | Mapa arquitectónico y guía de carpetas y archivos del repositorio. |
| **`Roles.md`** | Matriz de permisos y responsabilidades de usuarios y administradores. |
| **`Tecnologias.md`** | Justificación del stack tecnológico seleccionado para el desarrollo. |

---

### 2.7 `test/` — Pruebas Automatizadas

| Archivo | Propósito |
| :--- | :--- |
| **`widget_test.dart`** | Pruebas unitarias y de widgets: validación de renderizado del login (`YagoApp`), formulario de registro (`RegisterScreen`), `PetCard` y componentes del Design System (`YagoButton`, `YagoStatusBadge`). |

---

## 3. ¿Cómo reutilizar el Design System en nuevas pantallas?

Para construir cualquier pantalla o flujo nuevo siguiendo el Design System, basta con agregar estos dos imports:

```dart
// 1. Tokens de diseño (colores, fuentes, espaciados, radios)
import 'package:yago/utils/design_system.dart';

// 2. Componentes UI reutilizables
import 'package:yago/widgets/common/widgets.dart';
```

### Ejemplo rápido de uso:

```dart
// Botón primario
YagoButton(
  text: 'Publicar mascota',
  size: YagoButtonSize.large,
  onPressed: () => print('Publicar'),
)

// Badge de estado
const YagoStatusBadge(status: YagoPetStatus.lost)

// Campo de texto con validación
YagoTextField(
  label: 'Nombre de la mascota',
  hint: 'Ej: Luna',
  controller: myController,
)

// Tarjeta de mascota
PetCard(
  name: 'Luna',
  details: 'Lhasa Apso · Hembra · 3 años',
  locationAndTime: 'Palermo, CABA · hace 2 horas',
  imageUrl: 'https://...',
  status: YagoPetStatus.lost,
  tags: ['Collar rojo', 'Con chip'],
  onTap: () => print('Ver detalle'),
)
```
