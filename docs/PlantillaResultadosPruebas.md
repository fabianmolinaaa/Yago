# 📝 Plantilla de Registro de Resultados de Pruebas — Yago

Esta plantilla está diseñada para que el equipo de testing registre los resultados obtenidos durante la prueba del APK correspondiente a los **Sprints 1, 2 y 3**.

---

## 1. Datos de la Sesión de Prueba

* **Nombre del Tester:** ______________________________________
* **Dispositivo utilizado:** (Marca y modelo, ej. *Samsung Galaxy A52*) _______________________
* **Versión de Android:** (ej. *Android 12, 13, 14*) _______________________
* **Fecha de prueba:** ___ / ___ / 2026
* **Versión / Build probada:** *Yago — APK Sprint 3*

---

## 2. Resumen General

| Pruebas Totales | Aprobadas (Pasa) | Fallidas (Falla) | Bloqueadas |
| :---: | :---: | :---: | :---: |
| 24 | _____ | _____ | _____ |

**Estado general de la versión:** `[ ] Lista para entrega` `[ ] Requiere correcciones` `[ ] Bloqueada`

---

## 3. Lista de Casos de Prueba

| N° | Funcionalidad a Probar | Qué debe ocurrir (Comportamiento esperado) | Resultado | Observaciones / Comentarios |
| :---: | :--- | :--- | :---: | :--- |
| **01** | **Registro e Inicio de Sesión** | Al ingresar datos válidos, la cuenta se crea correctamente y se ingresa al feed. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **02** | **Persistencia de Sesión** | Al cerrar por completo la app y reabrirla, se entra directo sin volver a pedir datos. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **03** | **Visualización del Feed** | El feed carga publicaciones con foto, nombre, tipo de publicación, autor y descripción. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **04** | **Crear Publicación** | Al subir una foto, elegir categoría y escribir texto, la publicación aparece en el feed. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **05** | **Validación al Publicar** | Si falta la foto o el texto, la app avisa qué falta y no permite publicar vacía. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **06** | **Reaccionar con Me Gusta** | Al tocar el corazón, suma un me gusta, el icono cambia de color y el valor se mantiene. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **07** | **Filtrar Feed por Categoría** | Al elegir una categoría (ej. Consejos o Apareamiento), solo se muestran esas publicaciones. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **08** | **Ficha de Detalle** | Al tocar una publicación, se abre la vista completa con foto grande y datos del autor. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **09** | **Guardar en Favoritos** | Al tocar el icono de guardar, la publicación queda guardada en la sección de favoritos. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **10** | **Feed de Reportes** | La pestaña de reportes muestra mascotas perdidas y encontradas con sus estados claros. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **11** | **Ver Zona en Mapa** | Al pulsar "Ver zona en mapa", se abre un mapa centrado en el barrio con un pin visible. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **12** | **Crear Reporte de Mascota** | Al completar los datos y foto del animal, el reporte se publica activo en el feed. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **13** | **Cualquier Especie y Edad** | Permite reportar aves, tortugas o gatos y marcar que no se sabe la edad sin trabas. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **14** | **Ubicación GPS al Reportar** | Al presionar "Usar mi ubicación actual", el mapa ubica el pin en donde estoy y carga la zona. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **15** | **Ubicación Manual en Mapa** | Permite tocar o mover el pin en el mapa para marcar una calle o barrio distinto. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **16** | **Marcar Caso Resuelto** | El autor del reporte puede cerrarlo indicando el motivo y el reporte cambia a resuelto. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **17** | **Seguridad en Casos Ajenos** | En reportes de otras personas no aparece el botón de marcar como resuelto. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **18** | **Filtrar por Localidad** | Al filtrar por ciudad (ej. Caleta Olivia), solo se muestran los reportes de esa localidad. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **19** | **Acceso al escáner de animales (`HU-S3-01`)** | Al tocar el botón central de la barra de navegación se accede al escáner de animales. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **20** | **Identificación de características mediante IA (`HU-S3-02`)** | Al tomar una foto o seleccionar de galería, la IA identifica especie, raza aparente, colores y señas particulares. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **21** | **Búsqueda automática de coincidencias (`HU-S3-03`)** | La IA compara automáticamente las características del animal con los reportes de perdidas y encontradas en Yago. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **22** | **Visualización de posibles coincidencias (`HU-S3-04`)** | Muestra los reportes coincidentes con sus fotografías comparativas y porcentajes de similitud. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **23** | **Contacto con el responsable del reporte (`HU-S3-05`)** | Permite iniciar una conversación con el responsable del reporte coincidente para comunicarse sobre la mascota. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |
| **24** | **Creación de reporte a partir del análisis (`HU-S3-06`)** | Cuando no se detectan coincidencias, permite crear un reporte de mascota encontrada reutilizando la foto analizada. | `[ ] Pasa`<br>`[ ] Falla`<br>`[ ] Bloq.` | |

---

## 4. Registro de Errores Encontrados (Para cargar en Trello)

Si alguna prueba da resultado **Falla**, completa esta ficha para que el equipo de desarrollo pueda corregirla:

### Fallo N° 1
* **Caso de prueba relacionado:** (N° del caso anterior) _______
* **¿Qué falla? (Descripción breve):** __________________________________________________
* **Pasos para reproducir el problema:**
  1. __________________________________________________
  2. __________________________________________________
  3. __________________________________________________
* **¿Qué debería haber pasado? (Resultado esperado):** __________________________________
* **¿Qué pasó en realidad? (Resultado obtenido):** ______________________________________
* **Nivel de gravedad:** `[ ] Bloqueante` `[ ] Alta` `[ ] Media` `[ ] Baja`
* **Captura de pantalla o evidencia:** *(Adjuntar imagen o video)*

---

### Fallo N° 2 *(si aplica)*
* **Caso de prueba relacionado:** (N° del caso anterior) _______
* **¿Qué falla? (Descripción breve):** __________________________________________________
* **Pasos para reproducir el problema:**
  1. __________________________________________________
  2. __________________________________________________
  3. __________________________________________________
* **¿Qué debería haber pasado? (Resultado esperado):** __________________________________
* **¿Qué pasó en realidad? (Resultado obtenido):** ______________________________________
* **Nivel de gravedad:** `[ ] Bloqueante` `[ ] Alta` `[ ] Media` `[ ] Baja`
* **Captura de pantalla o evidencia:** *(Adjuntar imagen o video)*

---

## 5. Conclusión y Feedback del Tester
* **Aspectos positivos destacados:** __________________________________________________
* **Sugerencias de mejora:** __________________________________________________________
