# Acta de Sprint Review — Sprint 3

**Proyecto:** Yago — Red comunitaria para la búsqueda y reencuentro de mascotas  
**Sprint N°:** 3  
**Duración del sprint:** 2 semanas  

---

## Revisión de objetivos

| Ítem | Descripción | Estado |
| :--- | :--- | :--- |
| **Objetivo del sprint** | Desarrollar el escáner de visión computacional con IA para la extracción automática de rasgos físicos de animales y su cotejo contra reportes de la base de datos. | Parcialmente completado |
| **Historias de usuario comprometidas** | • **HU-S3-01:** Acceso al escáner de animales desde la barra central.<br>• **HU-S3-02:** Identificación de rasgos físicos mediante IA (especie, raza, colores).<br>• **HU-S3-03:** Búsqueda automática de coincidencias en base de datos.<br>• **HU-S3-04:** Visualización de coincidencias con porcentaje de similitud.<br>• **HU-S3-05:** Contacto directo con el responsable desde el resultado IA.<br>• **HU-S3-06:** Creación asistida de reporte a partir de la foto analizada. | • `HU-S3-01`: Terminada<br>• `HU-S3-02`: **En pruebas**<br>• `HU-S3-03`: **En pruebas**<br>• `HU-S3-04`: **En pruebas**<br>• `HU-S3-05`: **Por hacer**<br>• `HU-S3-06`: **Por hacer** |
| **Historias realmente completadas** | `HU-S3-01` | 1 de 6 completadas; 3 en etapa final de pruebas |

---

## Demo / Entregables presentados

| Entregable | Descripción breve | Observaciones |
| :--- | :--- | :--- |
| **Acceso a Cámara IA** | Botón central prominente en la barra de navegación que abre la vista de captura/escaneo. | Acceso inmediato desde cualquier pestaña de la aplicación. |
| **Motor de Extracción Fenotípica** | Servicio híbrido de visión artificial que combina modelo neuronal local y análisis multimodal en la nube. | En pruebas; detecta especie, raza aparente, colores y señas visibles. |
| **Algoritmo de Coincidencias** | Algoritmo que compara los rasgos del animal fotografiado contra reportes activos de extravíos y hallazgos. | En pruebas; evalúa umbrales de coincidencia (mínimo 50% de similitud). |
| **Pantalla de Resultados de Similitud** | Interfaz comparativa de fotos lado a lado con tarjeta de porcentaje de similitud. | En pruebas visuales y de rendimiento con imágenes reales. |
| **Pantalla de Error "No es un animal"** | Manejo de excepción cuando se fotografía un objeto o paisaje sin revelar detalles confidenciales. | Mensaje amigable y neutral para volver a intentar. |

---

## Próximos pasos

* Finalizar la certificación de pruebas de `HU-S3-02`, `HU-S3-03` y `HU-S3-04` para pasarlas a Terminadas.
* Desarrollar `HU-S3-05` (Iniciar conversación directa desde el resultado de similitud).
* Desarrollar `HU-S3-06` (Generar reporte de hallazgo reutilizando la foto analizada cuando no existan matches).
* Conectar estos flujos de contacto con el **Sprint 4: Chat Directo entre Personas**.
