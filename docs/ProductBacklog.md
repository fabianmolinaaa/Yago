# Product Backlog — Yago

Este documento constituye el **Product Backlog oficial y estructurado** del proyecto **Yago**, adaptado a los lineamientos de la cátedra **(2138) Laboratorio de Desarrollo de Software (2026)** y sincronizado con la metodología de gestión en **Trello** y el control de versiones en **GitHub**.

---

## 📌 Principio Rector de Estado y Definición de Terminado (DoD)

> 🛑 **Criterio estricto de completitud (No Hardcoding):**
> * Ninguna Historia de Usuario se considera **Terminada** únicamente con la interfaz visual o maquetación con datos simulados (`MockDataService`).
> * Para que una historia pase a `TERMINADO`, debe contar con persistencia real en **Cloud Firestore**, subida de archivos en **Cloud Storage**, autenticación con **Firebase Auth**, criterios de aceptación verificados al 100% y evidencia trazable en commit.

---

## 🗺️ Mapa de Ubicación en Listas de Trello

De acuerdo con la estructura oficial del tablero ([docs/GestionTrello.md](GestionTrello.md)):

| Lista en Trello | Historias asignadas actualmente | Estado real en el proyecto |
| :--- | :--- | :--- |
| **`SPRINT 1 · EN DESARROLLO`** | `HU-S1-01`, `HU-S1-02`, `HU-S1-03`, `HU-S1-04`, `HU-S1-05` | UI avanzada / maquetada con `MockDataService`. **Pendiente:** Integración con Firestore (`USERS`, `FEED_POSTS`, `POST_LIKES`). |
| **`PRODUCT BACKLOG`** | `HU-S2-01` a `HU-S2-06` (Sprint 2)<br>`HU-S3-01` a `HU-S3-06` (Sprint 3)<br>`HU-S4-01` a `HU-S4-05` (Sprint 4)<br>`HU-S5-01` a `HU-S5-04` (Sprint 5) | Historias priorizadas sin iniciar en el sprint actual. Pasan a `SPRINT N · POR HACER` durante el Sprint Planning correspondiente. |
| **`SPRINT 1 · TERMINADO`** | *(Vacía temporalmente)* | Ninguna historia alcanza aún el 100% del DoD por falta de integración en base de datos. |
| **`BUGS / MEJORAS`** | Mejoras técnicas colaterales | Tareas de refactor o issues detectados que no bloquean historias directamente. |

---

## 🚀 SPRINT 1: Feed de Publicaciones Comunitarias y Cuentas
**Ubicación actual en Trello:** `SPRINT 1 · EN DESARROLLO`  
**Objetivo del Sprint:** Permitir a los usuarios registrarse, autenticarse y gestionar su cuenta, así como interactuar en un muro social comunitario con publicaciones, fotos y me gusta conectados a la base de datos en tiempo real.

---

### `HU-S1-01` – Registro e inicio de sesión seguro
* **Tarjeta Trello:** `HU-S1-01 – Registro e inicio de sesión`
* **Etiquetas:** `Sprint 1`, `Prioridad Alta`
* **Descripción:**
  ```text
  Como usuario de Yago,
  quiero registrarme e iniciar sesión con email y contraseña,
  para acceder de forma segura y personalizada a las funciones de la app.
  ```
* **Estado actual:** 🟡 **En Desarrollo (75%)** — Auth con Firebase funcional en `AuthService`, pero falta sincronizar la creación automática del perfil en la colección `USERS` de Firestore.
* **Criterios de Aceptación (Checklist Trello):**
  - [x] Formulario de login y registro con validaciones de email y longitud de clave.
  - [x] Integración con Firebase Authentication (`createUserWithEmailAndPassword`, `signInWithEmailAndPassword`).
  - [x] Flujo de recuperación de contraseña por correo electrónico.
  - [ ] Al registrar un nuevo usuario, crear su documento en la colección `USERS` de Firestore con su `uid`, `email`, `displayName` y `role: 'user'`.
  - [ ] Persistencia de sesión entre reinicios de la aplicación.
* **Descomposición de Tareas:**
  - [x] Diseñar UI de Onboarding, Login y Registro.
  - [x] Implementar servicio `AuthService` conectado a Firebase Auth.
  - [ ] Crear servicio `UserService` para leer y escribir en la colección `USERS` de Firestore.
  - [ ] Probar validaciones de errores de Firebase (email en uso, clave incorrecta, etc.).

---

### `HU-S1-02` – Muro social comunitario con datos en tiempo real
* **Tarjeta Trello:** `HU-S1-02 – Feed social comunitario`
* **Etiquetas:** `Sprint 1`, `Prioridad Alta`
* **Descripción:**
  ```text
  Como usuario de Yago,
  quiero consultar un feed social comunitario con relatos, historias de reencuentro y consejos de cuidado,
  para mantenerme informado y colaborar con la comunidad animalista.
  ```
* **Estado actual:** 🟡 **En Desarrollo (50%)** — Pantalla de Feed maquetada con `PetCard` y lista visual, pero alimentada desde datos locales (`MockDataService`).
* **Criterios de Aceptación (Checklist Trello):**
  - [x] Pantalla visual de feed con scroll fluido y navegación oficial de Yago.
  - [x] Renderizado de tarjetas con autor, foto de mascota, contenido textual y badges.
  - [ ] Conexión reactiva en tiempo real (`StreamBuilder`) a la colección `FEED_POSTS` de Cloud Firestore.
  - [ ] Deserialización del modelo `FeedPost.fromFirestore` ordenado cronológicamente desc (`createdAt`).
  - [ ] Estados visuales de carga (shimmer/loading), error y lista vacía.
* **Descomposición de Tareas:**
  - [x] Diseñar componentes UI de publicaciones en `feed_tab.dart`.
  - [ ] Implementar `FeedService` con método `streamCommunityPosts()`.
  - [ ] Sustituir llamadas a `MockDataService` por consultas reales a Firestore.
  - [ ] Verificar índices compuestos si se requiere ordenamiento y filtrado conjunto.

---

### `HU-S1-03` – Creación y publicación de historias en el feed comunitario
* **Tarjeta Trello:** `HU-S1-03 – Crear publicaciones en el feed`
* **Etiquetas:** `Sprint 1`, `Prioridad Alta`
* **Descripción:**
  ```text
  Como usuario registrado,
  quiero redactar una publicación adjuntando foto y categoría temática,
  para compartir experiencias, buenas noticias o consejos en el muro comunitario.
  ```
* **Estado actual:** 🟡 **En Desarrollo (40%)** — Formulario modal maquetado, sin persistencia ni subida multimedia real.
* **Criterios de Aceptación (Checklist Trello):**
  - [x] Formulario con campos de texto, selección de tipo de publicación y botón de adjuntar foto.
  - [ ] Selección de imagen desde galería o cámara usando `image_picker`.
  - [ ] Subida de la imagen a **Firebase Cloud Storage** bajo la ruta `posts/{uid}/{timestamp}.jpg`.
  - [ ] Creación de documento en Firestore `FEED_POSTS` con `authorId`, `authorName`, `imageUrl`, `content` y `createdAt`.
  - [ ] Retroalimentación al usuario (diálogo de éxito / feedback de progreso de subida).
* **Descomposición de Tareas:**
  - [x] Maquetar modal/pantalla de creación de post.
  - [ ] Configurar servicio de almacenamiento en `StorageService`.
  - [ ] Implementar función `createPost(FeedPost post, File imageFile)` en `FeedService`.
  - [ ] Validar que no se permita publicar contenido vacío o sin usuario autenticado.

---

### `HU-S1-04` – Interacción con "Me gusta" y contacto directo seguro
* **Tarjeta Trello:** `HU-S1-04 – Reaccionar y contactar al autor`
* **Etiquetas:** `Sprint 1`, `Prioridad Media`
* **Descripción:**
  ```text
  Como usuario de la comunidad,
  quiero reaccionar con "me gusta" y abrir un contacto directo con el autor de una publicación,
  para expresar apoyo o solicitar más información de forma privada.
  ```
* **Estado actual:** 🟡 **En Desarrollo (30%)** — El botón de "Me gusta" cambia de color en memoria local, sin persistencia en Firestore.
* **Criterios de Aceptación (Checklist Trello):**
  - [x] Botón interactivo de "Me gusta" con animación y contador.
  - [ ] Registro transaccional en Firestore: crear/eliminar documento en subcolección `POST_LIKES` y actualizar `likesCount` con `FieldValue.increment`.
  - [ ] Comportamiento consistente: el estado del "me gusta" del usuario persiste al reiniciar la app.
  - [ ] Botón "Contactar al autor" que verifique la autenticación y prepare la acción de chat 1 a 1 (según Alcance, sin comentarios públicos).
* **Descomposición de Tareas:**
  - [x] Implementar widget visual de reacción en tarjeta de post.
  - [ ] Crear método `togglePostLike(String postId, String userId)` con transacción en Firestore.
  - [ ] Verificar que un usuario no pueda dar múltiples likes a un mismo post.

---

### `HU-S1-05` – Perfil de usuario y gestión de mis aportes
* **Tarjeta Trello:** `HU-S1-05 – Perfil y datos del usuario`
* **Etiquetas:** `Sprint 1`, `Prioridad Media`
* **Descripción:**
  ```text
  Como usuario registrado,
  quiero consultar y editar mis datos personales (nombre, teléfono, avatar) y ver mis publicaciones,
  para mantener mi información de contacto al día ante cualquier aviso de mascotas.
  ```
* **Estado actual:** 🟡 **En Desarrollo (30%)** — Pestaña `profile_tab.dart` maquetada con información estática.
* **Criterios de Aceptación (Checklist Trello):**
  - [x] Pantalla de perfil con campos de avatar, nombre, teléfono y correo.
  - [ ] Carga dinámica desde el documento `USERS/{uid}` en Firestore.
  - [ ] Formulario de edición con persistencia de cambios en Firestore.
  - [ ] Pestaña/lista de "Mis publicaciones" filtrando `FEED_POSTS` donde `authorId == currentUser.uid`.
  - [ ] Opción para cerrar sesión segura (`AuthService.signOut`).
* **Descomposición de Tareas:**
  - [x] Maquetar `profile_tab.dart`.
  - [ ] Conectar edición de perfil con Firestore `updateUser()`.
  - [ ] Permitir actualización de foto de avatar con subida a Firebase Cloud Storage.

---

## 🗃️ SPRINT 2: Feed de Reportes y Visualización de Zona en Mapa
**Ubicación actual en Trello:** `PRODUCT BACKLOG` (historias listas para Sprint Planning de Sprint 2)  
**Objetivo del Sprint:** Implementar el módulo prioritario de búsqueda de mascotas perdidas y encontradas, con fichas estructuradas, alertas de urgencia, badges de estado y visualización contextual de mapa de zona.

| ID | Título de la tarjeta | Descripción (Como... quiero... para...) | Estado en Código | Dependencia BD |
| :--- | :--- | :--- | :---: | :--- |
| **`HU-S2-01`** | **Feed dedicado de reportes con badges** | Como usuario, quiero ver un feed exclusivo de mascotas perdidas y encontradas con tarjetas visuales priorizadas, para enfocar mi atención en búsquedas urgentes. | 🟡 UI en `feed_tab` / `PetCard` maquetada | Requiere colección `PETS` en Firestore filtrando `status != 'community'`. |
| **`HU-S2-02`** | **Ver zona contextual en mapa** | Como usuario, quiero pulsar "Ver zona en mapa" en un reporte, para visualizar el radio aproximado del extravío sin perder el contexto del caso. | 🟡 Pantalla base `pet_map_tab.dart` | Requiere campos `geoPoint` y `zoneRadiusMeters` de Firestore. |
| **`HU-S2-03`** | **Publicar alerta de mascota perdida** | Como dueño, quiero publicar una alerta con foto, señas, fecha y zona de extravío, para que la comunidad empiece la búsqueda de inmediato. | 🟡 Maquetada en `create_report_screen.dart` | Requiere guardar en `PETS` con `status: 'lost'` y fotos en Storage. |
| **`HU-S2-04`** | **Publicar reporte de mascota encontrada** | Como vecino que retiene o avista una mascota, quiero reportar su hallazgo con foto y ubicación, para facilitar que su familia la reconozca. | 🟡 Formulario en `create_report_screen.dart` | Requiere guardar en `PETS` con `status: 'found'`. |
| **`HU-S2-05`** | **Marcar caso como Reunido / Resuelto** | Como autor del reporte, quiero cambiar el estado a "Reunida" cuando mi mascota regrese, para informar a la comunidad del final feliz. | 🔴 No iniciado en backend | Requiere actualización transaccional de `status: 'reunited'` y `isResolved: true`. |
| **`HU-S2-06`** | **Filtros por estado de reporte** | Como usuario, quiero filtrar por perdidas, encontradas o resueltas, para agilizar la navegación según lo que busco. | 🟡 Filtro visual en memoria | Requiere queries dinámicas con `where('status', isEqualTo: ...)` en Firestore. |

---

## 🤖 SPRINT 3: Cámara para Análisis con Inteligencia Artificial
**Ubicación actual en Trello:** `PRODUCT BACKLOG`  
**Objetivo del Sprint:** Desarrollar el servicio en la vía pública donde un usuario fotografía a un animal callejero y el modelo multimodal de IA identifica sus características y lo compara con las mascotas reportadas como perdidas en la base de datos.

| ID | Título de la tarjeta | Descripción (Como... quiero... para...) | Estado en Código | Dependencia BD / API |
| :--- | :--- | :--- | :---: | :--- |
| **`HU-S3-01`** | **Acceso central a cámara con IA** | Como usuario, quiero pulsar el botón central de la barra de navegación, para abrir al instante la cámara de reconocimiento en la calle. | 🟡 Botón maquetado en `YagoBottomNavBar` | Requiere permisos de cámara y visor en tiempo real. |
| **`HU-S3-02`** | **Captura y extracción fenotípica con IA** | Como usuario, quiero capturar una foto para que Gemini AI extraiga especie, raza aparente, colores y señas particulares. | 🔴 No iniciado | Integración con **Google Gemini Multimodal API** (`google_generative_ai`). |
| **`HU-S3-03`** | **Cotejo automático contra BD de perdidas** | Como usuario, quiero que el sistema compare el análisis visual contra las mascotas con estado `lost` en Firestore. | 🔴 No iniciado | Algoritmo de comparación contra atributos de la colección `PETS`. |
| **`HU-S3-04`** | **Pantalla de resultados y similitud** | Como usuario, quiero ver el porcentaje de coincidencia y fotos comparativas, para evaluar si se trata del mismo animal. | 🔴 No iniciado | UI de resultados con ranking de similitud visual. |
| **`HU-S3-05`** | **Iniciar chat directo ante coincidencia** | Como usuario, quiero abrir un chat con el dueño de la mascota coincidente desde el resultado de IA, para avisarle de inmediato. | 🔴 No iniciado | Integración con módulo de Chat (Sprint 4). |
| **`HU-S3-06`** | **Crear reporte rápido si no hay coincidencia** | Como usuario, quiero que si la IA no halla coincidencias me permita crear el reporte de hallazgo reutilizando la foto tomada. | 🔴 No iniciado | Redirección con payload a `create_report_screen.dart`. |

---

## 💬 SPRINT 4: Chat Directo entre Personas (1 a 1)
**Ubicación actual en Trello:** `PRODUCT BACKLOG`  
**Objetivo del Sprint:** Facilitar la comunicación privada y segura en tiempo real entre dueños y reportantes para coordinar reencuentros sin intermediarios ni comentarios públicos.

| ID | Título de la tarjeta | Descripción (Como... quiero... para...) | Estado en Código | Dependencia BD |
| :--- | :--- | :--- | :---: | :--- |
| **`HU-S4-01`** | **Bandeja de mensajes directos** | Como usuario, quiero ver la lista de mis conversaciones activas ordenadas por el último mensaje recibido, para no perder contacto. | 🔴 No iniciado | Colección `CHATS` filtrando por `participants contains currentUser.uid`. |
| **`HU-S4-02`** | **Iniciar conversación desde reporte o IA** | Como usuario, quiero tocar "Contactar dueño" en un reporte o resultado de IA, para iniciar una conversación privada vinculada a la mascota. | 🔴 No iniciado | Creación transaccional de sala en `CHATS` con `petId`. |
| **`HU-S4-03`** | **Mensajería instantánea en tiempo real** | Como usuario, quiero enviar y recibir mensajes de texto al instante en la sala de chat, para coordinar el lugar de entrega de la mascota. | 🔴 No iniciado | Subcolección `CHAT_MESSAGES` con streams reactivos de Firestore. |
| **`HU-S4-04`** | **Contexto de mascota en cabecera de chat** | Como usuario, quiero ver una mini-tarjeta de la mascota en el encabezado del chat, para saber de qué caso estamos hablando en todo momento. | 🔴 No iniciado | Desnormalización de foto, nombre y estado en el documento del chat. |
| **`HU-S4-05`** | **Notificaciones e indicador de no leídos** | Como usuario, quiero ver badges de mensajes no leídos, para responder rápido ante pistas urgentes sobre mi mascota extraviada. | 🔴 No iniciado | Campo `unreadCounts` por participante en el documento del chat. |

---

## 🛡️ SPRINT 5: Moderación y Seguridad de la Plataforma
**Ubicación actual en Trello:** `PRODUCT BACKLOG`  
**Objetivo del Sprint:** Proveer mecanismos de reporte comunitario y herramientas para el rol de administrador, asegurando la veracidad y confianza comunitaria.

| ID | Título de la tarjeta | Descripción (Como... quiero... para...) | Estado en Código | Dependencia BD |
| :--- | :--- | :--- | :---: | :--- |
| **`HU-S5-01`** | **Denunciar publicación o reporte indebido** | Como usuario, quiero denunciar publicaciones fraudulentas o spam, para que los administradores revisen el contenido. | 🔴 No iniciado | Creación de registros en `MODERATION_REPORTS`. |
| **`HU-S5-02`** | **Bandeja administrativa de denuncias** | Como administrador, quiero acceder a un panel con los reportes pendientes de revisión, para tomar acciones preventivas. | 🔴 No iniciado | Consulta con reglas de seguridad Firestore reservadas para `role == 'admin'`. |
| **`HU-S5-03`** | **Ocultar o dar de baja contenido infractor** | Como administrador, quiero despublicar publicaciones o alertas falsas, para proteger a la comunidad de engaños. | 🔴 No iniciado | Actualización de campo `isDeleted: true` o borrado lógico en Firestore. |
| **`HU-S5-04`** | **Gestión de sanciones a usuarios** | Como administrador, quiero advertir o suspender cuentas infractoras, para salvaguardar la confianza de la aplicación. | 🔴 No iniciado | Actualización de `isActive: false` en documento del usuario en Firestore. |

---

## 📊 Matriz Resumen de Estados

```
[Total Historias: 27]
├── En Desarrollo (UI Maquetada, pendiente Firestore): 5 (HU-S1-01 a HU-S1-05)
├── UI Parcial maquetada (Pendiente integración): 4 (HU-S2-01 a HU-S2-04, HU-S3-01)
├── Por Hacer (Sprint 2 a 5): 18 historias
└── Terminadas (100% DoD con Base de Datos): 0 historias
```
