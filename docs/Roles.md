# Roles del Sistema — Yago

Este documento describe los roles de usuario contemplados en la plataforma **Yago**, basados en el alcance oficial del proyecto.

---

## 1. Usuario

Todos los usuarios cuentan con el mismo tipo de cuenta y tienen acceso a todas las funcionalidades principales de la aplicación, independientemente de su situación (dueños de mascotas, personas que avistaron o encontraron un animal, o miembros de la comunidad).

> [!NOTE]
> **En Yago no existe la figura de "rescatista" ni la acción de "iniciar un rescate".**
> Los usuarios que navegan por la aplicación pueden ver publicaciones de forma totalmente libre y voluntaria. Quien visualiza una mascota perdida no asume ningún rol de rescate ni queda ligado a un reporte: únicamente si cuenta con algún dato o información certera, puede contactar directamente a la persona a cargo de la publicación.

### Responsabilidades y Funcionalidades:
* **Gestión de mascotas:**
  * Registrar sus mascotas con características físicas y fotografías.
  * Consultar y modificar la información registrada de sus mascotas.
* **Mascotas perdidas:**
  * Publicar reportes de mascotas perdidas (con fotos, descripción, fecha y ubicación de desaparición).
  * Actualizar la información de la publicación.
  * Marcar una mascota como encontrada / caso resuelto.
* **Mascotas encontradas:**
  * Publicar reportes de mascotas encontradas (con fotos, características, fecha y ubicación del hallazgo).
  * Consultar publicaciones de mascotas encontradas.
* **Feed y comunidad:**
  * Crear publicaciones para el feed comunitario (novedades, fotos cotidianas, relatos de final feliz y consejos).
  * Consultar e interactuar con publicaciones del feed (likes y comentarios).
* **Feed de reportes y zona en mapa:**
  * Consultar publicaciones de reportes de pérdidas y hallazgos con detalles completos.
  * Consultar en el mapa contextual la zona de extravío o último avistamiento de cualquier reporte.
* **Cámara para análisis con IA:**
  * Usar la cámara analizadora en la vía pública para fotografiar animales encontrados y detectar automáticamente si coinciden con reportes activos de mascotas perdidas.
* **Chat directo entre usuarios:**
  * Iniciar y mantener conversaciones directas 1 a 1 para aportar pistas o coordinar la entrega y reencuentro de la mascota de forma privada.

---

## 2. Administrador

Rol con privilegios de gestión y moderación, responsable de mantener el orden, la veracidad de la información y la seguridad en la plataforma.

### Responsabilidades y Funcionalidades:
* **Moderación de contenido:**
  * Gestionar, moderar, ocultar o dar de baja publicaciones inapropiadas, falsas o duplicadas tanto del feed como de mascotas perdidas/encontradas.
* **Gestión de reportes comunitarios:**
  * Atender y resolver denuncias o reportes emitidos por los usuarios sobre publicaciones o comportamientos indebidos.
* **Gestión de usuarios:**
  * Administrar cuentas de usuarios cuando sea necesario (advertencias, suspensiones temporales o bajas de cuentas infractoras).

---

## Matriz Resumen de Roles y Permisos

| Funcionalidad / Permiso | Usuario | Administrador |
| :--- | :---: | :---: |
| Registrar mascotas propias y gestionarlas | Sí | Sí |
| Publicar mascotas perdidas y encontradas | Sí | Sí |
| Marcar mascota como encontrada / resuelta | Propias | Sí |
| Crear publicaciones e interactuar en el feed social | Sí | Sí |
| Consultar feed de reportes y ver zona en mapa | Sí | Sí |
| Analizar fotos en la calle con Cámara IA | Sí | Sí |
| Chatear de forma directa 1 a 1 con otros usuarios | Sí | Sí |
| Moderar y dar de baja publicaciones ajenas | No | Sí |
| Gestionar denuncias y reportes de la comunidad | No | Sí |
| Gestionar y sancionar cuentas de usuario | No | Sí |
