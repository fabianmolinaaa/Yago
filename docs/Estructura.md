# Estructura del Proyecto - Yago

Este documento describe la arquitectura de carpetas y la organización modular del código fuente para la aplicación móvil **Yago** en Flutter.

---

## Árbol de Carpetas (`lib/`)

La estructura dentro de `lib/` está pensada para desacoplar la interfaz de usuario, la lógica de negocio y las capas de acceso a datos:

```text
lib/
├── main.dart
├── models/
│   ├── pet_report.dart
│   ├── user_profile.dart
│   └── filter_criteria.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── tabs/
│   │       ├── feed_tab.dart
│   │       ├── map_tab.dart
│   │       ├── my_reports_tab.dart
│   │       └── profile_tab.dart
│   ├── reports/
│   │   ├── create_report_screen.dart
│   │   ├── report_detail_screen.dart
│   │   └── edit_report_screen.dart
│   └── common/
│       └── not_found_screen.dart
├── widgets/
│   ├── pet_card.dart
│   ├── map_preview.dart
│   ├── status_badge.dart
│   ├── image_picker_field.dart
│   └── custom_button.dart
├── services/
│   ├── auth_service.dart
│   ├── pet_report_service.dart
│   ├── location_service.dart
│   └── storage_service.dart
└── utils/
    ├── app_colors.dart
    ├── app_constants.dart
    ├── app_theme.dart
    └── formatters.dart
```

---

## Descripción por Carpeta

### 1. `lib/` (Raíz de Código)
* **Archivo principal:** `main.dart`
* **Propósito:** Punto de entrada de la aplicación. Inicializa Firebase y servicios base, define el tema global y configura la pantalla inicial o el enrutador de autenticación.

---

### 2. `lib/models/` (Modelos de Dominio)
* **Propósito:** Definir las entidades y estructuras de datos del negocio.
* **Contenido esperado:**
  * `PetReport`: Representa el reporte de un animal (id, fotos, especie, estado [perdido, encontrado, resuelto], coordenadas, fecha, datos de contacto).
  * `UserProfile`: Datos del usuario registrado (nombre, teléfono, correo, foto).
  * Enums de estados, tipos de animal (perro, gato, otro) y rangos de tamaño.
  * Métodos `toMap()` y `fromMap()` para serialización con Firestore.

---

### 3. `lib/screens/` (Vistas y Pantallas)
* **Propósito:** Alojar las interfaces gráficas y flujos de navegación del usuario.
* **Subcarpetas:**
  * **`auth/`:** Pantallas de inicio de sesión, registro y recuperación de contraseña.
  * **`home/`:** Pantalla principal contenedor con barra de navegación inferior (feed de publicaciones, mapa, mis reportes y perfil).
  * **`reports/`:** Flujos para crear un nuevo reporte (con carga de fotos y selección en mapa), visualización detallada de la mascota y edición.

---

### 4. `lib/widgets/` (Componentes Reutilizables)
* **Propósito:** Componentes modulares compartidos entre múltiples pantallas para evitar duplicación de código.
* **Contenido esperado:**
  * Tarjetas de presentación de reportes (`PetCard`).
  * Indicadores visuales de estado (`StatusBadge` para Perdido/Encontrado/En Tránsito).
  * Campos para seleccionar o capturar fotografías (`ImagePickerField`).
  * Botones y diálogos con estilos comunes de la aplicación.

---

### 5. `lib/services/` (Servicios y Capa de Datos)
* **Propósito:** Aislar las llamadas a APIs externas, base de datos y sensores de la interfaz de usuario.
* **Contenido esperado:**
  * `AuthService`: Integración con Firebase Authentication.
  * `PetReportService`: Operaciones CRUD sobre Firestore para reportes de animales.
  * `LocationService`: Detección de coordenadas GPS actuales del usuario.
  * `StorageService`: Subida de imágenes a Cloud Storage.

---

### 6. `lib/utils/` (Constantes, Estilos y Utilidades)
* **Propósito:** Centralizar la configuración de diseño y funciones auxiliares.
* **Contenido esperado:**
  * Paleta cromática corporativa (`AppColors`).
  * Tema visual Material 3 (`AppTheme`).
  * Formateadores de fechas relativas (ej. "hace 2 horas") y validadores de campos.

---

## Otras Carpetas del Proyecto

| Directorio / Archivo | Propósito |
| :--- | :--- |
| **`docs/`** | Documentación del proyecto: alcance, requerimientos, roles, tecnologías y arquitectura. |
| **`test/`** | Pruebas unitarias, de integración y de widgets. |
| **`android/` / `ios/`** | Configuraciones y manifiestos nativos para compilación móvil. |
| **`pubspec.yaml`** | Declaración de dependencias (Firebase, Maps, Geolocator, etc.) y assets. |
