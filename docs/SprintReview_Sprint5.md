# Acta de Sprint Review — Sprint 5

**Proyecto:** Yago — Red comunitaria para la búsqueda y reencuentro de mascotas  
**Sprint N°:** 5  
**Duración del sprint:** 2 semanas  

---

## Revisión de objetivos

| Ítem | Descripción | Estado |
| :--- | :--- | :--- |
| **Objetivo del sprint** | Desarrollar el módulo integral de moderación comunitaria, reporte de contenido falso o indebido, bloqueo automático en chat y herramientas de administración y seguridad. | Completado |
| **Historias de usuario comprometidas** | • **HU-S5-01:** Denunciar publicaciones falsas, mensajes indebidos o spam.<br>• **HU-S5-02:** Bandeja de moderación para revisar reportes.<br>• **HU-S5-03:** Dar de baja publicaciones y reportes infractores.<br>• **HU-S5-04:** Advertir o suspender temporalmente a usuarios infractores. | • `HU-S5-01`: **Terminada**<br>• `HU-S5-02`: **Terminada**<br>• `HU-S5-03`: **Terminada**<br>• `HU-S5-04`: **Terminada** |
| **Historias realmente completadas** | `HU-S5-01`, `HU-S5-02`, `HU-S5-03`, `HU-S5-04` | 4 de 4 completadas (100% DoD cumplida) |

---

## Demo / Entregables presentados

| Entregable | Descripción breve | Observaciones |
| :--- | :--- | :--- |
| **Modal Oficial de Denuncias** | Diálogo accesible para denunciar reportes, publicaciones del feed y conversaciones de chat por estafa, maltrato o spam. | 100% anónimo para el usuario; incluye razones tipificadas del ámbito animal. |
| **Bloqueo Automático en Chat** | Al enviar una denuncia contra un usuario o chat, el sistema bloquea inmediatamente a la persona, quita la conversación de la bandeja y rechaza mensajes futuros. | Integrado en la lógica de negocio y reglas de seguridad de la base de datos. |
| **Bandeja Administrativa de Moderación** | Panel para consultar denuncias pendientes ordenadas cronológicamente con previsualización del contenido acusado. | Permite inspeccionar motivos, usuario denunciante y detalles aportados. |
| **Acciones de Moderación y Sanción** | Herramientas para dar de baja contenido infractor y aplicar suspensiones temporales a usuarios reincidentes. | Preserva la trazabilidad y la integridad de la base comunitaria. |

---

## Próximos pasos

* Ejecutar pruebas integrales de regresión sobre todas las suites de pruebas unitarias y de interfaz.
* Implementar en la fase de mantenimiento la historia `HU-S4-06` (Notificaciones Push mediante servicio de mensajería en la nube).
* Preparar la presentación final de la aplicación y la documentación de cierre de la cátedra.
