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
  * *Uso:* Base de datos NoSQL para almacenar perfiles de usuarios, reportes de mascotas (atributos, coordenadas geográficas, fechas y estados) con suscripciones en tiempo real.
* **Firebase Cloud Storage**
  * *Uso:* Almacenamiento seguro y optimizado de las fotografías de los animales reportados.
* **Firebase Cloud Messaging (FCM)**
  * *Uso (Tentativo):* Envío de notificaciones push para alertar a los usuarios cercanos ante reportes de extravío.

---

## 3. Mapas y Servicios de Geolocalización

* **Google Maps SDK / Mapbox / Flutter Map**
  * *Uso:* Renderizado del mapa interactivo con marcadores geolocalizados de animales perdidos y encontrados.
* **Geolocator / Geocoding (Plugins Flutter)**
  * *Uso:* Obtención de la ubicación actual del dispositivo y conversión de coordenadas a direcciones legibles.

---

## 4. Inteligencia Artificial (Opcional / Por Definir)

* **Sin definir / En evaluación**
  * *Uso potencial:* Clasificación automática de imágenes, comparación de rasgos de animales o asistencia en la carga del reporte.

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
| **Base de Datos** | Cloud Firestore | Próximo paso | Almacenamiento no relacional y datos de reportes en tiempo real |
| **Almacenamiento Multimedia** | Cloud Storage | Planificado | Subida y optimización de fotos de mascotas |
| **Geolocalización** | GPS & SDK de Mapas | Planificado | Detección de posición y visualización en mapa |
| **Notificaciones** | Firebase Cloud Messaging | Tentativo | Alertas comunitarias de avistamientos |
| **Control de Versiones** | Git + GitHub | Activo | Gestión del código fuente |
