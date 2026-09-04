# Alcance del Proyecto — Yago

## 1. Descripción del proyecto

**Yago** es una aplicación móvil destinada a facilitar la búsqueda y el reencuentro de mascotas perdidas con sus dueños, promoviendo la colaboración entre los usuarios de la comunidad.

La aplicación permitirá publicar y consultar información sobre mascotas perdidas o encontradas, visualizar casos cercanos y establecer contacto entre las personas involucradas.

Además, contará con un **feed de publicaciones sobre mascotas**, donde los usuarios podrán compartir diferentes situaciones, novedades, fotografías y contenido relacionado con sus mascotas.

---

## 2. Objetivo

Facilitar el proceso de búsqueda y reencuentro de mascotas perdidas mediante una plataforma móvil que conecte a dueños y usuarios de la comunidad.

---

## 3. Usuarios

### Usuario
Todos los usuarios tendrán el mismo tipo de cuenta y podrán utilizar las funcionalidades de la aplicación independientemente de su situación.

Un usuario podrá:
* Registrar sus mascotas.
* Publicar una mascota perdida.
* Publicar una mascota encontrada.
* Consultar publicaciones.
* Aportar información sobre una publicación.
* Contactar con otros usuarios.
* Crear publicaciones para el feed.
* Interactuar con las publicaciones.

### Administrador
Será responsable de tareas de gestión y moderación de la plataforma.

---

## 4. Funcionalidades dentro del alcance

### 4.1 Gestión de usuarios
* **Registro de usuarios:** Creación de cuenta con nombre completo, correo electrónico y contraseña (mínimo 6 caracteres) con validación de formularios y guardado de `displayName`. *(Implementado con Firebase Authentication)*
* **Inicio de sesión:** Autenticación segura mediante correo electrónico y contraseña, con mensajes de error amigables y manejo de estados de carga. *(Implementado con Firebase Authentication)*
* **Control reactivo de sesión (AuthGate):** Detección automática de sesión abierta o cerrada para dirigir al usuario sin parpadeos ni navegación forzada. *(Implementado)*
* **Recuperación de contraseña:** Envío de enlaces de restablecimiento de contraseña vía email. *(Implementado)*
* **Cierre de sesión:** Salida segura de la aplicación que revoca la sesión activa. *(Implementado)*
* **Gestión de información del perfil:** Visualización de nombre, correo y estado del usuario autenticado en la interfaz. *(En desarrollo / Sincronizado)*

### 4.2 Gestión de mascotas
* **Registro de mascotas:** Creación de reportes y perfiles de mascotas con especie, sexo, edad y raza. *(Interfaz y modelo implementados)*
* **Carga de fotografías:** Selector y vista previa de imágenes de mascotas. *(Implementado en CreateReportScreen)*
* **Registro de características:** Inclusión de señas particulares (`tags` dinámicos: chips, collar, marcas). *(Implementado)*
* **Consulta de mascotas:** Visualización en feed, búsqueda y ficha completa (`PetDetailScreen`). *(Implementado)*

### 4.3 Mascotas perdidas
* **Publicación de mascotas perdidas:** Formulario de búsqueda urgente con ubicación y fecha. *(Implementado)*
* **Registro de ubicación y fecha:** Campo descriptivo y coordenadas geográficas. *(Implementado)*
* **Marcado de mascota como encontrada / caso resuelto:** Botón en detalle para dueños con confirmación visual. *(Implementado)*

### 4.4 Mascotas encontradas
* **Publicación de mascotas encontradas:** Formulario diferenciado para reportar animales hallados en la vía pública con estado `found` en verde. *(Implementado)*
* **Consulta de publicaciones:** Filtros rápidos en feed y explorador. *(Implementado)*

### 4.5 Búsqueda y ubicación
* **Consulta y filtrado:** Buscador en tiempo real por nombre, raza o barrio con filtros por especie (*Perro*, *Gato*, *Otro*) y estado semántico. *(Implementado en SearchTab)*
* **Visualización en mapa:** Mapa con pines geolocalizados por color de estado (`PetMapTab`). *(Implementado)*

### 4.6 Contacto entre usuarios
* **Contacto directo:** Hoja modal en la ficha de mascota con opciones para llamar por teléfono o iniciar mensaje directo con el dueño o rescatista. *(Implementado en PetDetailScreen)*
* **Aporte de datos:** Diálogo para reportar avistamientos recientes a la familia. *(Implementado)*

### 4.7 Feed de la comunidad
* Feed principal con pestañas de filtro (*Todas*, *Perdidas*, *Encontradas*, *Reunidas*, *Comunidad*), visualización de publicaciones con `PetCard` y consejos comunitarios. *(Implementado en FeedTab)*

### 4.8 Inteligencia Artificial
La aplicación incorporará una funcionalidad basada en **inteligencia artificial**, cuya implementación concreta será definida durante el desarrollo del proyecto.

Esta funcionalidad deberá estar relacionada con el objetivo principal de Yago y aportar valor al proceso de búsqueda, identificación o gestión de mascotas.

### 4.9 Administración
* Gestión y moderación de publicaciones.
* Gestión de reportes realizados por los usuarios.
* Gestión de usuarios cuando sea necesario.

---

## 5. Fuera del alcance

Inicialmente, Yago no contemplará:
* Seguimiento GPS en tiempo real de una mascota.
* Sistema de pagos o recompensas económicas.
* Tienda de productos para mascotas.
* Reserva de servicios veterinarios.
* Funcionamiento como red social general.
* Sistema de seguidores.
* Compartir publicaciones dentro de la aplicación.
* Funciones avanzadas de mensajería similares a aplicaciones de mensajería instantánea.

Estas funcionalidades podrán ser consideradas como futuras ampliaciones, pero no forman parte del alcance inicial del proyecto.

---

## 6. Resultado esperado

El proyecto tendrá como resultado una **aplicación móvil funcional** que permita a los usuarios registrar sus mascotas, publicar y consultar casos de mascotas perdidas o encontradas, facilitar el contacto entre usuarios y participar de una comunidad relacionada con las mascotas.