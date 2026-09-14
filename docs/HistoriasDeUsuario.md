# Historias de Usuario — Yago

## Introducción

**Yago** es una plataforma colaborativa y móvil destinada a agilizar la búsqueda, identificación y reencuentro de mascotas perdidas con sus familias, promoviendo la solidaridad y el trabajo conjunto de la comunidad.

El sistema se estructura en **4 pilares fundamentales**:
1. **Feed de publicaciones (primera pantalla):** Muro social de la comunidad para compartir novedades, historias de reencuentro, fotos cotidianas y consejos.
2. **Feed de reportes (segunda pantalla):** Publicaciones enfocadas en pérdidas y hallazgos con visualización contextual de la zona en el mapa donde fue vista o perdida la mascota.
3. **Cámara para análisis con IA (tercera pantalla):** Identificación visual en la calle para determinar si un animal encontrado coincide con alguna mascota reportada como perdida en la base de datos.
4. **Chat directo entre personas (cuarta pantalla):** Comunicación directa 1 a 1 para contactar de inmediato a dueños y coordinar reencuentros de manera privada y ágil.
5. **Módulo de moderación y administración:** Supervisión del contenido por administradores para preservar la seguridad y veracidad.

> **Principio de servicio en la vía pública:**
> Cuando una persona ve un animal en la calle y sospecha que está perdido, abre la app y utiliza la **cámara analizadora con IA** para tomarle una fotografía. El sistema analiza los rasgos y rastrea si coincide con alguna mascota reportada como perdida: si hay coincidencia, le permite iniciar un **chat directo** de inmediato con el dueño; si no coincide, le permite generar el reporte de hallazgo en pocos segundos reutilizando la foto tomada.

---

## Planificación de Sprints

El desarrollo de **Yago** se organiza en **5 Sprints**:

* **Sprint 1: Feed de Publicaciones Comunitarias y Cuentas** — Muro social, interacciones de la comunidad y gestión de perfil.
* **Sprint 2: Feed de Reportes y Visualización de Zona en Mapa** — Difusión de pérdidas y hallazgos con opción contextual de mapa de zona.
* **Sprint 3: Cámara para Análisis con Inteligencia Artificial** — Escaneo fotográfico en la calle, análisis fenotípico y cotejo contra BD de mascotas perdidas.
* **Sprint 4: Chat Directo entre Personas** — Mensajería instantánea 1 a 1 entre usuarios para coordinar reencuentros.
* **Sprint 5: Moderación y Seguridad de la Plataforma** — Denuncias comunitarias y herramientas administrativas.

---

## Sprint 1: Feed de Publicaciones Comunitarias y Cuentas

**Objetivo del Sprint:** Permitir a los miembros de la comunidad interactuar socialmente, publicar historias de sus mascotas, consejos de cuidado y gestionar sus cuentas y perfiles.

| ID       | Historia de usuario                                                                                                                                   | Prioridad |
| :------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- | :-------: |
| HU-S1-01 | Como usuario, quiero registrarme e iniciar sesión con email y contraseña para acceder de forma segura y personalizada a la app.                       |   Alta    |
| HU-S1-02 | Como usuario, quiero consultar un feed social comunitario con relatos de reencuentro, fotos cotidianas y consejos útiles de cuidado animal.          |   Alta    |
| HU-S1-03 | Como usuario, quiero crear publicaciones en el feed comunitario compartiendo fotos, anécdotas o novedades de mis mascotas.                           |   Alta    |
| HU-S1-04 | Como usuario, quiero reaccionar con "me gusta" a las publicaciones comunitarias y contactar por mensaje directo al autor para interactuar de forma segura. |   Media   |
| HU-S1-05 | Como usuario, quiero consultar y editar mi información de perfil (avatar, nombre, teléfono) y ver mis aportes desde la pestaña de perfil.            |   Media   |

---

## Sprint 2: Feed de Reportes y Visualización de Zona en Mapa

**Objetivo del Sprint:** Disponer una pantalla dedicada a reportes de pérdidas y hallazgos con información estructurada y la opción de consultar la zona en el mapa de cada caso puntual.

| ID       | Historia de usuario                                                                                                                                           | Prioridad |
| :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ | :-------: |
| HU-S2-01 | Como usuario, quiero ver un feed dedicado exclusivamente a reportes de mascotas perdidas y encontradas con tarjetas visuales priorizadas y badges de estado.   |   Alta    |
| HU-S2-02 | Como usuario, quiero pulsar en cada reporte una opción de "Ver zona en mapa" para visualizar en un mapa contextual el barrio o zona donde se extravió.       |   Alta    |
| HU-S2-03 | Como usuario, quiero publicar una alerta de mascota perdida con foto, especie, raza, características, fecha y zona de extravío para iniciar su búsqueda.      |   Alta    |
| HU-S2-04 | Como usuario, quiero publicar un reporte de mascota encontrada cuando retengo o veo a un animal en la vía pública para que su familia pueda ubicarlo.        |   Alta    |
| HU-S2-05 | Como usuario, quiero marcar mi reporte como "Reunida / Caso resuelto" cuando mi mascota regrese para informar a la comunidad que la búsqueda finalizó.         |   Alta    |
| HU-S2-06 | Como usuario, quiero filtrar los reportes por estado (perdidas, encontradas o resueltas) para enfocarme en los casos que me interesan.                       |   Media   |

---

## Sprint 3: Cámara para Análisis con Inteligencia Artificial

**Objetivo del Sprint:** Implementar la cámara inteligente para la vía pública: fotografiar a un animal encontrado, analizar sus características físicas mediante IA y contrastarlo con la base de datos de mascotas perdidas.

| ID       | Historia de usuario                                                                                                                                                           | Prioridad |
| :------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------: |
| HU-S3-01 | Como usuario, quiero acceder a la cámara analizadora desde el botón central de la barra de navegación para identificar a un animal que veo en la calle.                      |   Alta    |
| HU-S3-02 | Como usuario, quiero capturar una foto con la cámara (o cargar una imagen) para que el modelo de IA extraiga sus rasgos físicos (especie, raza aparente, colores y señas).   |   Alta    |
| HU-S3-03 | Como usuario, quiero que la IA busque y compare automáticamente la foto contra la base de datos de mascotas activamente reportadas como perdidas en Yago.                    |   Alta    |
| HU-S3-04 | Como usuario, quiero visualizar el resultado de la búsqueda con el porcentaje de similitud visual y las fotos comparativas si existe coincidencia.                           |   Alta    |
| HU-S3-05 | Como usuario, quiero abrir un chat directo con el dueño del animal coincidente desde el resultado del análisis de IA para avisarle al instante que su mascota fue avistada.   |   Alta    |
| HU-S3-06 | Como usuario, quiero que la app me permita generar un nuevo reporte de mascota encontrada si la IA no detecta coincidencias, reutilizando la foto tomada para ahorrar tiempo.|   Alta    |

---

## Sprint 4: Chat Directo entre Personas

**Objetivo del Sprint:** Proporcionar un canal de mensajería interna en tiempo real para que dueños y miembros de la comunidad coordinen avistamientos y reencuentros sin salir de la app.

| ID       | Historia de usuario                                                                                                                                           | Prioridad |
| :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ | :-------: |
| HU-S4-01 | Como usuario, quiero disponer de una bandeja de chats directos donde visualizar todas mis conversaciones activas ordenadas cronológicamente.                  |   Alta    |
| HU-S4-02 | Como usuario, quiero iniciar un chat directo con el reportante o dueño de una mascota desde su ficha de reporte o desde el resultado de la cámara con IA.    |   Alta    |
| HU-S4-03 | Como usuario, quiero intercambiar mensajes de texto en tiempo real dentro del chat para brindar información y coordinar el punto de reencuentro.             |   Alta    |
| HU-S4-04 | Como usuario, quiero ver en el encabezado del chat la tarjeta resumida de la mascota a la que hace referencia la conversación para tener contexto inmediato.  |   Media   |
| HU-S4-05 | Como usuario, quiero recibir avisos o indicadores visuales de mensajes no leídos para no demorar la respuesta ante una posible pista de mi mascota.          |   Media   |

---

## Sprint 5: Moderación y Seguridad de la Plataforma

**Objetivo del Sprint:** Mantener la seguridad, veracidad y calidad de la información en el feed comunitario y en los reportes mediante herramientas de moderación activa.

| ID       | Historia de usuario                                                                                                                                   | Prioridad |
| :------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- | :-------: |
| HU-S5-01 | Como usuario, quiero denunciar publicaciones falsas, mensajes indebidos o spam en reportes o feed para que el equipo de moderación intervenga.     |   Alta    |
| HU-S5-02 | Como administrador, quiero acceder a una bandeja de denuncias para revisar el contenido reportado y tomar decisiones informadas.                      |   Alta    |
| HU-S5-03 | Como administrador, quiero ocultar o dar de baja publicaciones y reportes que incumplan las normas comunitarias.                                      |   Alta    |
| HU-S5-04 | Como administrador, quiero advertir o suspender temporalmente a usuarios infractores para salvaguardar la confianza en la plataforma.                 |   Alta    |
