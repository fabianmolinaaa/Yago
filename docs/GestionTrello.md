# Guía de Gestión y Uso de Trello — Yago

Este documento define la estructura, reglas operativas y criterios de uso del tablero de **Trello** para el seguimiento y desarrollo del proyecto **Yago**, en estricto cumplimiento con las especificaciones de la cátedra **(2138) Laboratorio de Desarrollo de Software (2026)**.

---

## 1. Configuración General del Tablero

* **Cantidad de tableros:** Un único tablero para todo el proyecto durante el cuatrimestre.
* **Nombre sugerido:** `[Apellido y nombre del estudiante] — Laboratorio Desarrollo de Software 2026`
* **Acceso docente obligatorio:**
  * `ggaetan@uaco.unpa.edu.ar`
  * `nseron@uaco.unpa.edu.ar`
* **Descripción del tablero ("Acerca de este tablero"):**
  * Nombre del proyecto: **Yago**
  * Nombre y apellido del estudiante
  * Materia: **(2138) Laboratorio de Desarrollo de Software**

---

## 2. Estructura de Listas del Tablero

El tablero cuenta con una combinación de **4 listas fijas** y **4 listas dinámicas** que representan el sprint en curso.

```
+------------------+   +-----------------------+   +-------------------------+   +----------------------+   +-----------------------+   +-----------------+   +------------+   +-----------------+
| PRODUCT BACKLOG  |   | SPRINT N · POR HACER  |   | SPRINT N · EN DESARROLLO|   | SPRINT N · EN PRUEBAS|   | SPRINT N · TERMINADO  |   | BUGS / MEJORAS  |   |  ENTREGAS  |   |  DOCUMENTACIÓN  |
+------------------+   +-----------------------+   +-------------------------+   +----------------------+   +-----------------------+   +-----------------+   +------------+   +-----------------+
   (Lista Fija)             (Dinámica Sprint)           (Dinámica Sprint)            (Dinámica Sprint)          (Dinámica Sprint)          (Lista Fija)        (Lista Fija)       (Lista Fija)
```

### Listas Fijas:
1. **PRODUCT BACKLOG:** Contiene todas las historias de usuario que aún no se han planificado para el sprint en curso.
2. **BUGS / MEJORAS:** Registro de problemas técnicos, fallas detectadas o mejoras colaterales identificadas durante el desarrollo o pruebas.
3. **ENTREGAS:** Historial y tarjetas oficiales de entrega de cada sprint con sus evidencias congeladas.
4. **DOCUMENTACIÓN:** Repositorio central de enlaces a los artefactos clave del proyecto.

### Las 4 Listas Dinámicas del Sprint en Curso:
* `SPRINT 1 · POR HACER`
* `SPRINT 1 · EN DESARROLLO`
* `SPRINT 1 · EN PRUEBAS`
* `SPRINT 1 · TERMINADO`

> ⚠️ **Regla de oro al cambiar de sprint:** 
> **NO crear 4 listas nuevas**. Al cerrar el Sprint 1 y comenzar el Sprint 2, se **renombran las mismas 4 listas** cambiando el número (ej.: `SPRINT 1` pasa a `SPRINT 2`). De este modo, el tablero siempre mantiene el mismo número constante de listas y no se acumulan columnas viejas.

---

## 3. Cierre y Transición entre Sprints

Antes de renombrar las 4 listas para dar paso al nuevo sprint:

| Situación de la tarjeta | Acción a realizar | Justificación |
| :--- | :--- | :--- |
| **Terminada** (en `TERMINADO`) | **Archivarla** (no borrarla). | El registro histórico formal queda respaldado en la tarjeta de la lista **ENTREGAS**. |
| **No terminada** (sigue en alcance) | **No moverla**. | Al renombrar las 4 listas del sprint, la tarjeta queda automáticamente incorporada al nuevo sprint. |
| **No terminada** (se descarta del alcance) | Agregar un **comentario explicativo** del motivo y luego **archivarla**. | No debe dejarse arrastrar indefinidamente sin resolver ni perder el registro histórico de por qué se descartó. |

---

## 4. Anatomía de una Tarjeta de Historia de Usuario

Cada tarjeta en el backlog o en el sprint representa una **Historia de Usuario funcional**, nunca una tarea técnica individual.

### Formato de campos:
* **Título:** `[Código] – [Nombre breve]`  
  *Ejemplo:* `HU-S1-01 – Iniciar sesión con email` o `HU-07 – Solicitar turno`.
* **Descripción:** 
  ```text
  Como [tipo de usuario], quiero [acción], para [beneficio].
  ```
* **Etiquetas nativas:**
  * Sprint: `Sprint 1`, `Sprint 2`, etc.
  * Prioridad: `Alta`, `Media`, `Baja`.
* **Fecha de vencimiento (campo nativo):** Fecha planificada de finalización del sprint o historia.
* **Checklist 1 — "Criterios de aceptación":** 
  * Un ítem individual por cada criterio. 
  * Para que la historia se considere completa, el 100% de las casillas deben estar tildadas.
* **Checklist 2 — "Evidencias":**
  * Enlace al commit puntual en GitHub (`https://github.com/fabianmolinaaa/Yago/commit/[hash]`).
  * Enlace a capturas, video demostrativo o prototipo según corresponda.
* **Checklist opcional — "Tareas":**
  * Tareas técnicas necesarias (ej.: *Diseñar pantalla*, *Crear modelo*, *Integrar Firebase*, *Realizar pruebas*).

### Reglas de movimiento de tarjetas:
$$\text{POR HACER} \longrightarrow \text{EN DESARROLLO} \longrightarrow \text{EN PRUEBAS} \longrightarrow \text{TERMINADO}$$

> 🛑 **Restricción estricta de paso a "TERMINADO":**
> * Una tarjeta **no pasa a TERMINADO** solo porque se finalizó la programación.
> * Debe tener el checklist de **Criterios de aceptación al 100%** y haber sido probada.
> * **Verificación de regresión:** Antes de darla por terminada, correr un chequeo rápido de los criterios de las historias ya terminadas que interactúan con ese código para verificar que no se haya roto nada.

---

## 5. Gestión de Imprevistos y Bloqueos

Si ocurre un bloqueo o cambio de planificación en una historia, **no se borra la tarjeta**. Se registra un **comentario** con el siguiente formato:

```text
Planificación anterior: Sprint 1, fecha estimada 25/09
Nueva planificación: Sprint 2, fecha estimada 05/10
Motivo: Bloqueo — falta definir el formato de datos del servicio externo
Impacto esperado: se retrasa una semana, no afecta otras historias
```

---

## 6. Lista BUGS / MEJORAS

Para fallos descubiertos durante el desarrollo o pruebas. Las tarjetas deben detallar:
* **Descripción:** Qué falla.
* **Cómo reproducirlo:** Pasos paso a paso.
* **Resultado esperado:** Lo que debería suceder.
* **Resultado obtenido:** Lo que realmente sucede.
* **Prioridad / Severidad:** Bloqueante, Alta, Media, Baja.
* **Estado:** Pendiente, En corrección, Resuelto.

*(Nota: No todo bug entra automáticamente al sprint actual; se prioriza según severidad).*

---

## 7. Lista ENTREGAS

Una tarjeta por cada hito (`Sprint 1`, `Sprint 2`, `Sprint 3`, `Entrega final`).

### Descripción de la tarjeta de entrega:
* **Fecha:** Día de entrega.
* **Objetivo del sprint:** Meta alcanzada.
* **Historias comprometidas:** Lista de códigos de historias.
* **Historias terminadas:** Lista de códigos cumplidos.
* **Historias no terminadas:** Con su respectiva justificación.
* **Observaciones:** Notas relevantes del ciclo.

### Adjuntos obligatorios (ícono de clip, no texto en descripción):
1. **Tag de Git congelado:** Enlace al tag o release (ej. `https://github.com/fabianmolinaaa/Yago/releases/tag/sprint-1-entrega`).
2. **Video o capturas funcionales (OBLIGATORIO SIEMPRE):** Demostración visual de la app funcionando sin necesidad de instalar o compilar.
3. **Build o ejecutable (opcional / complementario):** APK de Android o enlace de despliegue si aplica.

---

## 8. Lista DOCUMENTACIÓN (Enlaces, no archivos)

En la columna **DOCUMENTACIÓN** se colocan enlaces directos para que Trello funcione como índice general del proyecto:

| Tarjeta de Recurso | Enlace a adjuntar |
| :--- | :--- |
| **Repositorio GitHub** | `https://github.com/fabianmolinaaa/Yago` |
| **User Story Map** | Enlace a tablero / documento de historias |
| **Prototipo UI/UX** | Enlace a Figma / capturas |
| **Diseño de Base de Datos** | Enlace a [docs/BaseDeDatos.md](docs/BaseDeDatos.md) en GitHub |
| **Documento del Proyecto** | Enlace a [README.md](../README.md) y [docs/Alcance.md](docs/Alcance.md) en GitHub |
| **Plan de Pruebas** | Enlace a la sección de pruebas / testing plan |

---

## 9. Antipatrones y Qué NO Hacer

* ❌ **Crear una lista por cada artefacto o documento.**
* ❌ **Crear una tarjeta por cada documento.**
* ❌ **Copiar todo el informe del proyecto dentro de Trello.**
* ❌ **Usar Trello solo para tildar "hecho" al final del sprint.**
* ❌ **Crear historias de usuario para tareas técnicas sueltas** (ej: *"Crear botón"* o *"Configurar base de datos"*).
* ❌ **Dejar el tablero sin actualizar durante semanas.**
* ❌ **Mover una tarjeta directamente de "Por hacer" a "Terminado" sin pasar por desarrollo y pruebas.**
* ❌ **Borrar tarjetas porque el trabajo cambió** (siempre se comenta y se archiva).
* ❌ **Modificar la planificación sin dejar constancia del cambio.**
