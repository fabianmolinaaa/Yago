# Acta de Sprint Review — Sprint 4

**Proyecto:** Yago — Red comunitaria para la búsqueda y reencuentro de mascotas  
**Sprint N°:** 4  
**Duración del sprint:** 2 semanas  

---

## Revisión de objetivos

| Ítem | Descripción | Estado |
| :--- | :--- | :--- |
| **Objetivo del sprint** | Desarrollar el sistema completo de chat directo 1 a 1 entre personas, con unificación de conversación por persona, soporte multitema, intercambio multimedia y notificaciones acumulativas en el celular. | Mayormente completado |
| **Historias de usuario comprometidas** | • **HU-S4-01:** Bandeja cronológica de chats directos.<br>• **HU-S4-02:** Iniciar chat privado desde feed, reporte o resultado IA.<br>• **HU-S4-03:** Chat en tiempo real con fotos y respuestas rápidas.<br>• **HU-S4-04:** Tarjeta resumida contextual en encabezado de chat.<br>• **HU-S4-05:** Notificaciones de mensajes acumulados en celular e indicadores de no leídos.<br>• **HU-S4-06 (Nueva):** Notificaciones push remotas con app en segundo plano/cerrada. | • `HU-S4-01`: Terminada<br>• `HU-S4-02`: Terminada<br>• `HU-S4-03`: Terminada<br>• `HU-S4-04`: Terminada<br>• `HU-S4-05`: Terminada<br>• `HU-S4-06`: **Pendiente** |
| **Historias realmente completadas** | `HU-S4-01`, `HU-S4-02`, `HU-S4-03`, `HU-S4-04`, `HU-S4-05` | 5 de 6 completadas (DoD cumplida) |

---

## Demo / Entregables presentados

| Entregable | Descripción breve | Observaciones |
| :--- | :--- | :--- |
| **Bandeja de Chats Directos** | Lista de conversaciones activas con avatares, último mensaje, marcas de tiempo y badges de mensajes no leídos. | Excluye chats bloqueados y filtra eliminados/archivados. |
| **Chat Único por Persona con Selector Multitema** | Unificación de conversaciones con una misma persona, incorporando una barra de chips superiores y separadores en la línea de tiempo si se habla por varios animales. | Resuelve de forma ordenada el seguimiento de múltiples animales con un mismo vecino. |
| **Mensajería en Tiempo Real** | Intercambio de mensajes de texto, fotografías adjuntas (cámara/galería) y respuestas rápidas contextuales. | Persistencia y mensajería reactiva en base de datos. |
| **Tarjeta Contextual en Cabecera** | Encabezado superior con foto, estado, raza y acceso directo a la ficha del reporte o publicación. | Brinda contexto inmediato al usuario durante la conversación. |
| **Notificaciones en Celular (Nativas)** | Notificación en barra de estado del celular que acumula mensajes sin exponer texto privado ("Has recibido N mensajes"). | Se limpia o actualiza automáticamente al leer la conversación. |

---

## Próximos pasos

* Planificar la implementación de la nueva historia `HU-S4-06` (Notificaciones Push mediante servicio de mensajería en la nube).
* Iniciar el **Sprint 5: Moderación y Seguridad de la Plataforma**, implementando el sistema de denuncias de contenido y bloqueo preventivo de usuarios.
