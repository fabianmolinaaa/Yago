# Acta de Sprint Review — Sprint 1

**Proyecto:** Yago — Red comunitaria para la búsqueda y reencuentro de mascotas  
**Sprint N°:** 1  
**Duración del sprint:** 2 semanas  

---

## Revisión de objetivos

| Ítem | Descripción | Estado |
| :--- | :--- | :--- |
| **Objetivo del sprint** | Desarrollar el feed social comunitario y la capacidad de crear y consultar publicaciones con fotografías y categorización. | Parcialmente completado |
| **Historias de usuario comprometidas** | • **HU-S1-01:** Consultar feed social comunitario.<br>• **HU-S1-02:** Crear publicación comunitaria con fotos.<br>• **HU-S1-03:** Reaccionar con "Me gusta".<br>• **HU-S1-04:** Filtrar publicaciones por categoría.<br>• **HU-S1-05:** Ficha de detalle de publicación.<br>• **HU-S1-06:** Guardar en favoritos / guardados. | • `HU-S1-01`: Terminada<br>• `HU-S1-02`: Terminada<br>• `HU-S1-03`: **Por hacer**<br>• `HU-S1-04`: Terminada<br>• `HU-S1-05`: Terminada<br>• `HU-S1-06`: **En desarrollo** |
| **Historias realmente completadas** | `HU-S1-01`, `HU-S1-02`, `HU-S1-04`, `HU-S1-05` | 4 de 6 completadas (DoD cumplida) |

---

## Demo / Entregables presentados

| Entregable | Descripción breve | Observaciones |
| :--- | :--- | :--- |
| **Feed Social Comunitario** | Pantalla principal con publicaciones cronológicas de relatos, consejos y momentos cotidianos. | Fluido y reactivo; cumple con el sistema de diseño oficial. |
| **Creación de Publicaciones** | Formulario para redactar texto, adjuntar fotos desde cámara/galería y seleccionar categoría. | Validación funcional; imágenes optimizadas en almacenamiento en la nube. |
| **Filtros por Categoría** | Barra de chips horizontales para filtrar por Consejo, Reencuentro, Apareamiento y Comunidad. | Filtrado instantáneo en memoria y sincronizado. |
| **Ficha de Detalle** | Vista extendida al tocar una publicación, con foto ampliada y datos completos del autor. | Permite visualizar el contenido completo sin cortes. |
| **Módulo de Favoritos (Parcial)** | Estructura de persistencia en base de datos para guardados de usuario. | En desarrollo; falta conectar el icono visual con el estado reactivo en perfil. |

---

## Próximos pasos

* Finalizar la implementación de `HU-S1-06` (Guardar en favoritos) y conectar el botón reactivo en el perfil de usuario.
* Desarrollar la interacción `HU-S1-03` (Me gusta con persistencia por usuario).
* Iniciar el **Sprint 2: Feed de Reportes y Visualización de Zona en Mapa**, incorporando las alertas de mascotas perdidas/encontradas con geolocalización.
