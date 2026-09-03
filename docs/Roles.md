# Roles del Sistema — Yago

Este documento describe los roles de usuario contemplados en la plataforma **Yago**, basados en el alcance oficial del proyecto.

---

## 1. Usuario

Todos los usuarios cuentan con el mismo tipo de cuenta y tienen acceso a todas las funcionalidades principales de la aplicación, independientemente de su situación (dueños de mascotas, personas que avistaron o encontraron un animal, o miembros de la comunidad).

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
  * Crear publicaciones para el feed (novedades de búsquedas, mascotas recuperadas, fotos cotidianas o contenido de la comunidad).
  * Consultar e interactuar con publicaciones del feed.
* **Búsqueda e interacción:**
  * Consultar y filtrar publicaciones por cercanía y características físicas.
  * Aportar información relevante en una publicación existente.
  * Contactar de forma directa dentro de la aplicación con el usuario responsable de una publicación.

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
| Marcar mascota como encontrada | Propias | Sí |
| Crear publicaciones e interactuar en el feed | Sí | Sí |
| Contactar con otros usuarios por una publicación | Sí | Sí |
| Moderar y dar de baja publicaciones ajenas | No | Sí |
| Gestionar denuncias y reportes de la comunidad | No | Sí |
| Gestionar y sancionar cuentas de usuario | No | Sí |
