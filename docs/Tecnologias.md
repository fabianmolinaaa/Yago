# Tecnologías del Proyecto - Yago

Este documento resume las tecnologías, frameworks y herramientas seleccionadas para el desarrollo y soporte de la plataforma **Yago**.

---

## 1. Aplicación Móvil

* **Flutter & Dart**
  * *Uso:* Framework multiplataforma para el desarrollo de la aplicación móvil (Android e iOS), garantizando una experiencia visual fluida y reactiva.
* **Entorno de Desarrollo (IDE)**
  * *Uso:* Android Studio / Visual Studio Code para la codificación, emulación y depuración del proyecto.

---

## 2. Backend, Servicios en la Nube y Base de Datos

* **Firebase (Proyecto `yago-21b28`)**
  * *Uso:* Plataforma Backend-as-a-Service (BaaS) para simplificar la infraestructura, autenticación y persistencia en tiempo real.
  * *Configuración:* Sincronizado para Android con Application ID / Package Name `com.example.yago` a través de `google-services.json` y `firebase_options.dart`.
* **Firebase Authentication (`firebase_auth: ^6.6.1`) — *Implementado***
  * *Uso:* Gestión segura de usuarios. Cuenta con:
    * Registro de nuevas cuentas con correo, contraseña y nombre de usuario (`displayName`).
    * Inicio de sesión reactivo con `AuthGate` y persistencia automática de sesión.
    * Recuperación de contraseñas mediante correo electrónico (`sendPasswordResetEmail`).
    * Cierre de sesión seguro (`signOut`).
    * Traducción y mapeo localizado de excepciones de Firebase a mensajes claros en español.
* **Cloud Firestore**
  * *Uso:* Base de datos NoSQL para perfiles de usuarios, publicaciones del feed social, reportes de mascotas (atributos, coordenadas geográficas, fechas y estados) y **conversaciones del chat directo en tiempo real** con suscripciones reactivas.
* **Firebase Cloud Storage (`firebase_storage: ^13.6.0`) — *Implementado***
  * *Uso:* Almacenamiento seguro y optimizado de las fotografías de los animales reportados y fotos compartidas en el feed social o chat.
  * *Servicio:* `StorageService` (`lib/services/storage_service.dart`) con compresión automática y control de tipos MIME.
* **Firebase Cloud Messaging (FCM)**
  * *Uso (Tentativo):* Envío de notificaciones push ante mensajes nuevos de chat o alertas de extravío.

---

## 3. Geolocalización y Mapas Contextuales

* **Visor Contextual de Zona (Google Maps / Mapbox / Flutter Map)**
  * *Uso:* Visualización de la zona o barrio específico de extravío o avistamiento dentro de cada publicación de reporte (descartando la pantalla de mapa exploratorio global e integrando la geolocalización contextual a la ficha de la mascota).
* **Geolocator / Geocoding (Plugins Flutter)**
  * *Uso:* Obtención de la ubicación actual del dispositivo para sugerir el barrio/zona al crear reportes y conversión de coordenadas a direcciones legibles.

---

## 4. Inteligencia Artificial y Visión Computacional

* **API Multimodal / Visión (Gemini Multimodal API / Google Cloud Vision)**
  * *Uso:* Reconocimiento visual y extracción de rasgos físicos (especie, raza aparente, colores y señas particulares) a partir de fotos tomadas con la cámara analizadora en la calle. Comparación automatizada contra la base de datos de mascotas perdidas para alertar coincidencias instantáneas y derivar al chat con el dueño.

---

## 5. Control de Versiones y Gestión del Proyecto

* **Git + GitHub**
  * *Uso:* Control de versiones, ramas de trabajo, revisión de código y resguardo seguro del repositorio.
* **Herramientas de Gestión (Trello / Jira / Notion)**
  * *Uso:* Tablero Kanban para el seguimiento de tareas, épicas y entregas de la cátedra.

---

## Matriz Resumen de Tecnologías

| Componente | Tecnología | Estado / Implementación | Propósito |
| :--- | :--- | :---: | :--- |
| **Frontend Móvil** | Flutter & Dart | Activo | Interfaz de usuario, Design System oficial, navegación y lógica cliente |
| **Autenticación** | Firebase Authentication (`firebase_auth`) | **Implementado** | Inicio de sesión, registro, recuperación de contraseña y AuthGate reactivo |
| **Configuración Android** | Gradle (`com.example.yago`) + Google Services | **Implementado** | Vinculación nativa de la app móvil con Firebase |
| **Base de Datos & Chat**| Cloud Firestore | Próximo paso | Reportes, feed comunitario y chat directo 1 a 1 en tiempo real |
| **Almacenamiento Multimedia** | Cloud Storage (`firebase_storage`) + `image_picker` | **Implementado** | Subida, compresión y optimización de fotos de mascotas |
| **Mapas Contextuales** | SDK de Mapas / Map View | Planificado | Visualización de zona de extravío/avistamiento por reporte |
| **Cámara & Análisis IA**| Gemini Multimodal / Cloud Vision API | Planificado | Análisis fenotípico de fotos en la calle y cotejo contra BD de perdidos |
| **Control de Versiones** | Git + GitHub | Activo | Gestión del código fuente |
