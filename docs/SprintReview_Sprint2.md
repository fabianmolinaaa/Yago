# Acta de Sprint Review — Sprint 2

**Proyecto:** Yago — Red comunitaria para la búsqueda y reencuentro de mascotas  
**Sprint N°:** 2  
**Duración del sprint:** 2 semanas  

---

## Revisión de objetivos

| Ítem | Descripción | Estado |
| :--- | :--- | :--- |
| **Objetivo del sprint** | Implementar el feed especializado de reportes de mascotas perdidas/encontradas, geolocalización contextual en mapa interactivo y cierre de casos resueltos (Cierre del MVP). | Mayormente completado |
| **Historias de usuario comprometidas** | • **HU-S2-01:** Feed dedicado a reportes con badges oficiales.<br>• **HU-S2-02:** Visualizar zona aproximada de extravío en mapa.<br>• **HU-S2-03:** Publicar alerta de mascota perdida o encontrada.<br>• **HU-S2-04:** Selector interactivo de ubicación y GPS.<br>• **HU-S2-05:** Marcar reporte como "Caso resuelto".<br>• **HU-S2-06:** Filtrar reportes por ciudad / localidad. | • `HU-S2-01`: Terminada<br>• `HU-S2-02`: Terminada<br>• `HU-S2-03`: Terminada<br>• `HU-S2-04`: Terminada<br>• `HU-S2-05`: Terminada<br>• `HU-S2-06`: **En pruebas** |
| **Historias realmente completadas** | `HU-S2-01`, `HU-S2-02`, `HU-S2-03`, `HU-S2-04`, `HU-S2-05` | 5 de 6 completadas (DoD cumplida) |

---

## Demo / Entregables presentados

| Entregable | Descripción breve | Observaciones |
| :--- | :--- | :--- |
| **Feed de Reportes Prioritarios** | Vista panorámica en dos columnas con etiquetas oficiales (Perdida, Encontrada, Apareamiento). | Prioridad visual clara; adaptada para reconocimiento rápido de rasgos. |
| **Visor Contextual de Zona** | Modal con mapa contextual que muestra el barrio y radio aproximado de avistamiento. | Protege la privacidad evitando mostrar la dirección exacta del usuario. |
| **Alta de Reportes con GPS** | Formulario accesible con especie neutral, edad flexible y selector de mapa interactivo. | Detección por GPS y sugerencias automáticas de barrios de la localidad. |
| **Cierre de Casos Resueltos** | Diálogo de confirmación para que el autor archive su reporte indicando motivo (reencuentro, adopción o fallecimiento). | Al marcar resuelto, actualiza el estado en la base de datos a Reunido. |
| **Filtro por Localidad (En pruebas)** | Selector desplegable estilo marketplace para alternar entre ciudades. | Funcional en entorno de pruebas; en validación de no regresión sobre la localidad. |

---

## Próximos pasos

* Completar la suite de pruebas automatizadas y validación final de `HU-S2-06` (Filtro por ciudad).
* Congelar formalmente la entrega del MVP con el tag de cierre correspondiente.
* Iniciar el **Sprint 3: Cámara para Análisis con Inteligencia Artificial**, desarrollando el modelo de visión neuronal para cotejar fotos de animales con reportes activos.
