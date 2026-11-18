# Tecnologías del Proyecto — Yago

Resumen de las tecnologías, frameworks y servicios utilizados en el desarrollo de la plataforma **Yago**.

---

## 1. Aplicación Móvil
* **Flutter & Dart:** Desarrollo de la aplicación móvil multiplataforma (Android e iOS).
* **Entornos de Desarrollo:** Android Studio / Visual Studio Code.

---

## 2. Backend y Servicios en la Nube
* **Firebase Authentication:** Registro, inicio de sesión, recuperación de contraseña y gestión de usuarios.
* **Cloud Firestore:** Base de datos NoSQL para reportes de mascotas, feed comunitario, perfiles y mensajería directa en tiempo real.
* **Firebase Cloud Storage:** Almacenamiento y gestión de fotografías de reportes, publicaciones y chats.

---

## 3. Notificaciones y Servicios Nativos
* **Notificaciones del Sistema (Android):** Notificaciones push locales/nativas para avisos en el celular de nuevos mensajes directos acumulados.

---

## 4. Geolocalización y Mapas
* **Flutter Map:** Visualización de la zona contextual aproximada de avistamiento o extravío y selector de coordenadas en mapa.
* **Geolocator & Geocoding:** Detección de ubicación actual por GPS y conversión de coordenadas a direcciones legibles.

---

## 5. Inteligencia Artificial y Visión Computacional
* **Google Gemini AI & Google ML Kit / TensorFlow Lite:** Análisis visual de fotografías para detección de especie, raza aparente, colores y rasgos físicos, junto al cotejo automático contra reportes de la base de datos.

---

## 6. Control de Versiones y Gestión
* **Git & GitHub:** Control de versiones y resguardo del repositorio.
* **Trello:** Gestión ágil del proyecto mediante tablero Kanban.

---

## Matriz Resumen

| Componente | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Frontend Móvil** | Flutter & Dart | Interfaz de usuario y lógica cliente |
| **Autenticación** | Firebase Authentication | Inicio de sesión y seguridad de usuarios |
| **Base de Datos** | Cloud Firestore | Almacenamiento de reportes, feed y chats en tiempo real |
| **Almacenamiento** | Cloud Storage | Guardado y optimización de fotos |
| **Notificaciones** | Android Native Notifications | Avisos en el celular de mensajes entrantes |
| **Mapas y GPS** | Flutter Map + Geolocator | Ubicación de reportes y visualización de zona |
| **Inteligencia Artificial** | Gemini AI + ML Kit / TFLite | Identificación de mascotas y búsqueda de coincidencias |
| **Gestión y Versiones** | Git, GitHub y Trello | Control de versiones y seguimiento del proyecto |
