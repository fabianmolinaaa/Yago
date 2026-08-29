# Estructura del Proyecto

Este documento describe la organización de carpetas y archivos de **StandMap**, explicando el propósito y contenido esperado para cada una.

---

## Árbol de Carpetas (`lib/`)

El código fuente de la aplicación se encuentra dentro de `lib/`, organizado de forma modular para mantener el orden y la facilidad de mantenimiento:

```
lib/
├── main.dart
├── models/
│   ├── event.dart
│   └── stand.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── my_events_tab.dart
│   │   ├── create_event_tab.dart
│   │   └── profile_tab.dart
│   └── event_detail/
│       ├── event_detail_screen.dart
│       ├── stand_map_tab.dart
│       ├── stand_list_tab.dart
│       └── event_info_tab.dart
├── widgets/
│   ├── event_card.dart
│   └── stand_map_view.dart
├── services/
│   └── mock_data_service.dart
└── utils/
    ├── app_colors.dart
    └── app_theme.dart
```

---

## Descripción por Carpeta

### 1. `lib/` (Raíz de código)
* **Archivo principal:** `main.dart`
* **Qué contiene:** El punto de inicio de la aplicación Flutter. Configura el título, carga el tema visual global y define la primera pantalla que ve el usuario (`LoginScreen`).

---

### 2. `lib/models/` (Modelos de datos)
* **Propósito:** Representar los objetos y entidades principales del negocio.
* **Qué debe ir aquí:**
  * Clases que definen la estructura de la información (ej. `Event`, `Stand`).
  * Enums de estados fijos (ej. `StandStatus`: disponible, ocupado).
  * Métodos de conveniencia propios del dato (como calcular la cantidad de stands libres o clonar un objeto con cambios).

---

### 3. `lib/screens/` (Pantallas de la aplicación)
* **Propósito:** Alojar las vistas completas por las que navega el usuario. Se organizan en subcarpetas según la funcionalidad:
  * **`auth/`:** Pantallas de acceso e identificación (Login y futuro registro).
  * **`home/`:** Pantalla principal y sus secciones (Mis eventos, Crear evento y Perfil).
  * **`event_detail/`:** Vistas específicas al entrar a un evento (Mapa interactivo, Lista de stands y Ficha de información).

---

### 4. `lib/widgets/` (Componentes visuales reutilizables)
* **Propósito:** Evitar repetir código visual creando piezas de interfaz que se puedan usar en distintas pantallas.
* **Qué debe ir aquí:**
  * Tarjetas personalizadas (ej. `EventCard`).
  * El lienzo del plano interactivo (`StandMapView`).
  * Botones, diálogos o indicadores gráficos que compartan varias pantallas.

---

### 5. `lib/services/` (Servicios y acceso a datos)
* **Propósito:** Separar la interfaz visual de la lógica de datos.
* **Qué debe ir aquí:**
  * Funciones para consultar, agregar y actualizar información.
  * Actualmente: `MockDataService` (datos de prueba en memoria).
  * A futuro: Conexiones a Firebase (Authentication y Cloud Firestore) y comunicación con el asistente de IA.

---

### 6. `lib/utils/` (Utilidades y estilos)
* **Propósito:** Centralizar configuraciones globales, constantes y funciones de ayuda.
* **Qué debe ir aquí:**
  * Paleta de colores (`app_colors.dart`).
  * Configuración del tema Material 3 (`app_theme.dart`).
  * Formateadores de texto o fechas y constantes generales.

---

## Otras Carpetas del Proyecto

| Carpeta / Archivo | Descripción |
| --- | --- |
| **`docs/`** | Documentación de la cátedra: alcance, roles, tecnologías y arquitectura. |
| **`test/`** | Pruebas automáticas (como el test básico que verifica que la app arranque sin errores). |
| **`android/` / `ios/`** | Archivos de configuración nativos generados por Flutter para compilar en cada sistema. |
| **`pubspec.yaml`** | Archivo de configuración general del proyecto, donde se registran las dependencias y librerías externas. |
