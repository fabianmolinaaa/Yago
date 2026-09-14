# Yago

> Aplicación móvil comunitaria orientada a facilitar la búsqueda y el reencuentro de mascotas perdidas con sus dueños, promoviendo la colaboración ciudadana a través de alertas geolocalizadas, identificación asistida por Inteligencia Artificial y comunicación directa y segura.

---

## 📌 Descripción del Proyecto

**Yago** es una aplicación móvil desarrollada en **Flutter** que combina el compromiso comunitario con herramientas tecnológicas modernas para dar respuesta rápida ante pérdidas y hallazgos de animales domésticos.

El sistema se estructura en torno a **4 pilares fundamentales**:

1. **Feed de publicaciones (Muro comunitario):** Espacio social para compartir novedades cotidianas, fotografías, historias de final feliz, avisos de adopción responsable y consejos de cuidado animal. Incluye interacciones mediante "me gusta", compartir y contacto directo privado con el autor.
2. **Feed de reportes (Pérdidas y hallazgos):** Pantalla optimizada y priorizada para la difusión de mascotas perdidas (con alertas urgentes) y encontradas. Cada caso cuenta con ficha detallada, estado semántico (*Perdida*, *Encontrada*, *Reunida*) y **visualización contextual de zona en mapa** (barrio y radio aproximado del hecho).
3. **Cámara para análisis con Inteligencia Artificial:** Herramienta para identificar animales en la vía pública mediante visión computacional multimodal. Analiza rasgos físicos (especie, raza aparente, colores y patrones de pelaje) y los coteja automáticamente contra la base de datos de mascotas perdidas para conectar al instante con su dueño.
4. **Chat directo entre personas (1 a 1):** Mensajería privada y en tiempo real para coordinar el reencuentro, aportar pistas, enviar fotos de avistamientos o pactar la entrega de forma confidencial y segura.

---

## 🛡️ Enfoque de Seguridad y Decisiones de Alcance

Para salvaguardar la confianza de la comunidad y prevenir malas prácticas habituales en plataformas de búsqueda de mascotas:

* **Sin comentarios públicos:** Se descartan los hilos de comentarios abiertos en publicaciones y reportes para evitar estafas (ej. pedidos fraudulentos de rescates/recompensas), spam y desinformación. Todo dato o avistamiento se canaliza exclusivamente por chat privado.
* **Mapas contextuales por reporte:** Se prescinde de un mapa exploratorio global independiente para concentrar la atención en la zona relevante de cada caso puntual.
* **Sin roles obligatorios de rescate:** Quien encuentra o ve a un animal colabora voluntariamente sin asumir compromisos legales ni operativos formales.
* **Fuera del alcance inicial:** Rastreo GPS satelital por collar, transacciones económicas/recompensas, marketplace de productos veterinarios y sistema de seguidores.

---

## 📚 Documentación del Proyecto

Toda la especificación técnica, funcional y de diseño se encuentra disponible en la carpeta [`docs/`](docs/):

* [**Alcance del Proyecto**](docs/Alcance.md): Descripción general, objetivos, los 4 pilares (4.1 a 4.6) y funcionalidades fuera del alcance.
* [**Roles del Sistema**](docs/Roles.md): Definición de roles (Usuario y Administrador) y matriz de responsabilidades.
* [**Historias de Usuario**](docs/HistoriasDeUsuario.md): Plan de trabajo dividido en 5 sprints con prioridades y criterios de aceptación.
* [**Tecnologías**](docs/Tecnologias.md): Stack tecnológico detallado (Flutter, Firebase Auth, Cloud Firestore, Cloud Storage, Gemini AI).
* [**Estructura del Proyecto**](docs/Estructura.md): Organización modular del código fuente en `lib/` y guía de arquitectura.
* [**Base de Datos**](docs/BaseDeDatos.md): Modelo entidad-relación en Firestore, estrategia de desnormalización, índices y reglas de seguridad.
* [**Design System**](docs/DesignSystem.md): Identidad visual, paleta cromática, tipografías, componentes interactivos (`PetCard`, `YagoBottomNavBar`).
* [**Políticas de GitHub**](docs/PoliticasGitHub.md): Directivas de visibilidad, prefijado de commits por historia de usuario y etiquetado de sprints (`tags`).
* [**Gestión en Trello**](docs/GestionTrello.md): Estructura de listas, ciclo de vida de historias, gestión de evidencias y entrega por sprint.

---

## 🛠️ Stack Tecnológico

* **Frontend Móvil:** Flutter & Dart (multiplataforma iOS / Android).
* **Autenticación:** Firebase Authentication (`firebase_auth`) con persistencia de sesión y recuperación por correo.
* **Base de Datos & Tiempo Real:** Cloud Firestore (almacenamiento NoSQL reactivo).
* **Almacenamiento Multimedia:** Firebase Cloud Storage (fotografías de mascotas y adjuntos de chat).
* **Inteligencia Artificial:** Gemini Multimodal API / Cloud Vision (análisis fenotípico y cotejo de imágenes).
* **Geolocalización:** Plugins Flutter (Geolocator / Geocoding / visores contextuales de mapas).
* **Control de Versiones:** Git & GitHub.
