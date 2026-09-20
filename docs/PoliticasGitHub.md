# Políticas de Uso de GitHub — Yago

Este documento establece las directivas y buenas prácticas de control de versiones y uso de GitHub para el proyecto académico **Yago**, en cumplimiento con los estándares requeridos por la cátedra de **Laboratorio de Desarrollo de Software (2026)**.

---

## 1. Visibilidad del Repositorio

* **Visibilidad:** El repositorio es público.
* **Enlace oficial:** [https://github.com/fabianmolinaaa/Yago](https://github.com/fabianmolinaaa/Yago)
* **Integración con Trello:** El enlace general al repositorio debe estar incorporado como recurso obligatorio en la tarjeta *"Repositorio GitHub"* dentro de la lista fija **DOCUMENTACIÓN** del tablero de Trello.

---

## 2. Convención de Mensajes de Commit

Para garantizar la **trazabilidad bidireccional** entre la planificación en Trello y el código fuente en GitHub:

1. **Obligatoriedad del Identificador:** Todo commit asociado al desarrollo de una Historia de Usuario debe comenzar con el código de la historia correspondiente.
2. **Formato estándar:**
   ```text
   [Código HU]: [tipo]([ámbito opcional]): [descripción en imperativo/presente]
   ```
   *O formato simplificado:*
   ```text
   [Código HU]: [descripción concisa de lo implementado]
   ```
### Ejemplos válidos:
* `HU-S1-01: feat(feed): implementa visualización del feed comunitario con Firestore`
* `HU-S1-01: fix(feed): corrige ordenamiento cronológico de publicaciones`
* `HU-S1-02: crea pantalla de creación de publicaciones comunitarias`
* `HU-S2-03: agrega formulario de reporte de mascota perdida`

> **Nota sobre commits técnicos o de soporte:** 
> Commits de infraestructura, refactor general o documentación no vinculados a una historia específica pueden utilizar el formato convencional (`docs: ...`, `chore: ...`, `setup: ...`), aunque se recomienda asociar el trabajo a las tarjetas correspondientes siempre que sea posible.

---

## 3. Vinculación de Evidencias en Trello (Commits Puntuales)

* En el checklist **"Evidencias"** de cada tarjeta de Historia de Usuario en Trello, **NUNCA** se debe colocar el enlace general al repositorio.
* Debe adjuntarse el **enlace específico al commit o Pull Request** que implementó dicha historia o criterio.
* **Formato del enlace de evidencia:**
  ```text
  https://github.com/fabianmolinaaa/Yago/commit/[HASH_DEL_COMMIT]
  ```
  *(Ejemplo: `https://github.com/fabianmolinaaa/Yago/commit/846b1da`)*

---

## 4. Congelamiento de Código por Sprint (Tags de Entrega)

Antes de dar por cerrado un Sprint y renombrar las listas en Trello, es **obligatorio** crear una etiqueta fija (`tag`) en Git que congele el estado del código en ese punto exacto, independientemente de si existe o no una versión desplegada.

### Procedimiento:
1. Asegurarse de que todos los cambios validados y probados estén integrados y commiteados en la rama principal (`main`):
   ```bash
   git checkout main
   git pull origin main
   ```
2. Generar el tag con la nomenclatura requerida:
   ```bash
   git tag sprint-N-entrega
   ```
   *(Donde `N` es el número del sprint cerrado. Ej: `sprint-1-entrega`, `sprint-2-entrega`, etc.)*
3. Subir el tag al repositorio remoto:
   ```bash
   git push origin sprint-N-entrega
   # O alternativamente:
   git push --tags
   ```
4. **Adjuntar en Trello:** Copiar el enlace al tag generado en GitHub y adjuntarlo (ícono de clip) en la tarjeta correspondiente de la lista **ENTREGAS**:
   ```text
   https://github.com/fabianmolinaaa/Yago/releases/tag/sprint-N-entrega
   # O bien:
   https://github.com/fabianmolinaaa/Yago/tree/sprint-N-entrega
   ```

---

## 5. Resumen de Buenas Prácticas y Antipatrones

| Qué SÍ hacer ✅ | Qué NO hacer ❌ |
| :--- | :--- |
| Mantener el repositorio público y actualizado. | Dejar el repositorio desactualizado durante semanas. |
| Vincular el hash exacto del commit en el checklist de Trello. | Pegar el link general del repo en el checklist de evidencias de una HU. |
| Prefijar commits con el código de la Historia (`HU-S1-01: ...`). | Hacer commits genéricos como *"arreglos"*, *"cambios"* o *"update"*. |
| Crear y pushear el tag `sprint-N-entrega` al cerrar cada sprint. | Cerrar el sprint en Trello sin haber etiquetado el código en GitHub. |
| Preservar el historial de commits y ramas ordenado. | Reescribir historial destructivamente (`force push`) en ramas públicas. |
