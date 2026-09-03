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

* **Firebase**
  * *Uso:* Plataforma Backend-as-a-Service (BaaS) para simplificar la infraestructura y permitir sincronización en tiempo real.
* **Cloud Firestore**
  * *Uso:* Base de datos NoSQL para almacenar perfiles de usuarios, reportes de mascotas (atributos, coordenadas geográficas, fechas y estados) con suscripciones en tiempo real.
* **Firebase Authentication**
  * *Uso:* Gestión de autenticación segura (correo/contraseña, proveedores sociales como Google).
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

| Componente | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Frontend Móvil** | Flutter & Dart | Interfaz de usuario, navegación y lógica cliente |
| **Base de Datos** | Cloud Firestore | Almacenamiento no relacional y datos en tiempo real |
| **Autenticación** | Firebase Authentication | Inicio de sesión, registro y control de sesiones |
| **Almacenamiento Multimedia** | Cloud Storage | Subida y optimización de fotos de mascotas |
| **Geolocalización** | GPS & SDK de Mapas | Detección de posición y visualización en mapa |
| **Notificaciones** | Firebase Cloud Messaging | Alertas comunitarias de avistamientos |
| **Control de Versiones** | Git + GitHub | Gestión del código fuente |
| **Gestión y Seguimiento** | Trello / Jira | Planificación y seguimiento del equipo |
