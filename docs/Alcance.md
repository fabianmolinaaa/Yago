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
* Aportar información o pistas sobre una publicación exclusivamente mediante mensaje privado (chat directo).
* Contactar con otros usuarios.
* Crear publicaciones para el feed.
* Reaccionar a las publicaciones ("me gusta").

### Administrador
Será responsable de tareas de gestión y moderación de la plataforma.

---

## 4. Funcionalidades dentro del alcance (Pilares Principales)

El alcance oficial de la aplicación móvil **Yago** se estructura en torno a **4 pilares y pantallas fundamentales**:

### 4.1 Feed de publicaciones (Primera pantalla)
* **Muro comunitario de publicaciones:** Espacio social y participativo donde la comunidad comparte situaciones, novedades, fotografías cotidianas de mascotas, relatos con final feliz, avisos de adopción, consejos de tenencia responsable y búsquedas de pareja o apareamiento responsable.
* **Creación de publicaciones diversas:** Formulario contextual para crear publicaciones según distintos tipos (momentos cotidianos, consejos, reencuentros, apareamiento con datos de raza/sexo o alertas directas) con carga de fotos desde cámara o galería.
* **Filtrado por categorías:** Selector rápido y panel superior para filtrar el feed por tipo de contenido (*Todos*, *Perdidas*, *Encontradas*, *Reunidas*, *Apareamiento*, *Comunidad*).
* **Interacción:** Opciones para indicar "me gusta" (reacciones), guardar en favoritos/marcadores y contactar directamente al autor mediante mensaje privado, sin hilos de comentarios públicos.

### 4.2 Feed de reportes (Segunda pantalla)
* **Visualización optimizada de pérdidas y hallazgos activos:** Pantalla especialmente dispuesta y priorizada para la difusión y consulta de reportes de mascotas perdidas (con alertas urgentes) y animales encontrados en estado activo (excluyendo casos ya resueltos para concentrar la atención en emergencias vigentes).
* **Fichas claras de reporte:** Fotografía del animal, estado semántico (*Perdida*, *Encontrada*), señas particulares (raza, edad, sexo, chips, collar), fecha y datos de contacto del reportante.
* **Visualización contextual de zona en mapa:** Cada publicación incluye una **opción directa para ver en qué zona del mapa se pudo haber perdido o visto por última vez**, desplegando un mapa contextual con el barrio, punto de referencia y radio aproximado del hecho (eliminando la necesidad de navegar por un mapa exploratorio global independiente).
* **Gestión y resolución de reportes:** Formularios dedicados para dar de alta reportes de pérdidas y hallazgos, editar información y marcar casos como resueltos especificando la causa (reencuentro con su familia, adopción/hogar definitivo, o fallecimiento).

### 4.3 Cámara para análisis con Inteligencia Artificial (Tercera pantalla)
* **Identificación inteligente en la vía pública:** Herramienta diseñada para el momento en que una persona se encuentra un animal en la calle o busca cotejar a su mascota perdida.
* **Captura fotográfica directa:** El usuario abre la cámara analizadora desde la app y captura una fotografía del animal encontrado (o carga una foto reciente de la galería).
* **Análisis visual con IA:** Mediante visión computacional y modelos multimodales, la IA analiza los rasgos físicos del animal (especie, raza, colores, patrones de pelaje y características distintivas).
* **Cotejo contra la base de datos de mascotas perdidas y encontradas:** El sistema busca de forma automática en el catálogo de reportes activos en Yago, contrastando contra casos de **mascotas perdidas** y **mascotas encontradas** para detectar coincidencias potenciales en ambas direcciones.
* **Derivación de resultados:**
  * **Con coincidencia:** Se presenta el reporte coincidente con porcentaje de similitud visual y botón directo para iniciar un **Chat directo** con el dueño o la persona que reportó el hallazgo para avisarle de inmediato.
  * **Sin coincidencia:** La app notifica que no figura como reportado actualmente y ofrece la posibilidad de generar en pocos segundos un nuevo reporte de hallazgo reutilizando la imagen analizada.

### 4.4 Chat directo entre personas (Cuarta pantalla)
* **Mensajería directa 1 a 1:** Canal de comunicación interna y en tiempo real entre usuarios dentro de la aplicación.
* **Puntos de acceso directos:** Posibilidad de abrir un chat privado directamente desde una **publicación del feed comunitario** (consultas de apareamiento, consejos, etc.), desde una **ficha del feed de reportes** (aportar pistas de avistamientos o coordinar reencuentro) o desde el **resultado de la cámara con IA**.
* **Coordinación y avistamientos:** Permite a quien vio o retuvo a un animal contactar de forma inmediata, privada y segura a la persona a cargo del reporte para aportar pistas, fotos o coordinar el reencuentro.
* **Bandeja de conversaciones:** Listado de chats activos vinculados al contexto del reporte o publicación correspondiente para evitar confusiones.

### 4.5 Base técnica transversal: Autenticación y cuentas de usuario
*(Infraestructura de soporte requerida para la autoría, seguridad y persistencia de datos, no contemplada como historias de usuario de negocio en el backlog):*
* **Autenticación:** Registro e inicio de sesión mediante Firebase Authentication, recuperación de contraseña y persistencia de sesión.
* **Perfil básico:** Datos de contacto del usuario necesarios para la autoría y coordinación en reportes y publicaciones.

### 4.6 Administración y moderación
* Panel y herramientas para moderar o dar de baja publicaciones inapropiadas, falsas o spam, y atender denuncias comunitarias.

---

## 5. Fuera del alcance

Inicialmente, Yago no contemplará:
* **Mapa interactivo exploratorio global independiente:** Se descarta la pantalla independiente de mapa general de la ciudad donde se navega explorando casos dispersos. La visualización geográfica queda integrada exclusivamente como una opción contextual de zona dentro de cada publicación de reporte.
* Seguimiento GPS en tiempo real de una mascota mediante collares satelitales.
* Sistema de pagos o recompensas económicas.
* Tienda de productos para mascotas o marketplace.
* Reserva de servicios veterinarios.
* Funcionamiento como red social generalista (no orientada a mascotas).
* Sistema de seguidores.
* Roles de "rescatistas", flujos forzados de "iniciar rescate" o vinculación obligatoria a un reporte (quien ve una publicación o encuentra a un animal ayuda voluntariamente y contacta a la persona a cargo por chat directo sin asumir compromisos legales ni operativos de rescate).
* **Comentarios públicos en publicaciones y reportes:** Se descartan los hilos de comentarios abiertos para prevenir spam, ciberacoso, desinformación o intentos de estafa sobre mascotas perdidas; todo contacto o aporte de pistas se canaliza de manera segura y confidencial a través del chat directo 1 a 1.

Estas funcionalidades podrán ser consideradas en etapas futuras de expansión.

---

## 6. Resultado esperado

El proyecto tendrá como resultado una **aplicación móvil funcional** que permita a los usuarios registrar sus mascotas, publicar y consultar casos de mascotas perdidas o encontradas, facilitar el contacto entre usuarios y participar de una comunidad relacionada con las mascotas.
