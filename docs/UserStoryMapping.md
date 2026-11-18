# User Story Mapping — Yago

**Proyecto:** Yago — Red comunitaria para la búsqueda y reencuentro de mascotas perdidas  
**Cátedra:** (2138) Laboratorio de Desarrollo de Software (2026)  
**Versión:** 2.0  
**Fecha:** Noviembre 2026  

---

## 1. Objetivos Principales (Backbone / Actividades de Alto Nivel)

El **Backbone** o columna vertebral del sistema representa las actividades esenciales que realizan tanto los **vecinos de la comunidad** como los **administradores**, ordenadas de forma cronológica según su interacción con Yago:

### Recorrido Principal del Usuario (Vecino de la comunidad):
1. **Descubrimiento y Participación Social:** Explorar el feed comunitario con historias de reencuentro, momentos y consejos, filtrar por categorías de interés e interactuar guardando contenido.
2. **Alertas y Búsqueda Geolocalizada:** Consultar alertas de mascotas perdidas y encontradas, filtrar por ciudad, ver la zona de avistamiento en un mapa contextual y publicar nuevos reportes con foto y ubicación.
3. **Reconocimiento Asistido con Inteligencia Artificial:** Tomar una fotografía de un animal en la vía pública para que el motor de IA extraiga sus rasgos físicos y busque automáticamente coincidencias con reportes activos.
4. **Comunicación y Coordinación Directa:** Iniciar un chat privado y confidencial 1 a 1 con el responsable de una publicación o reporte, coordinar pistas en tiempo real y recibir avisos en el celular.
5. **Cierre y Resolución del Caso:** Actualizar y dar por finalizado un reporte cuando la mascota ha sido recuperada, adoptada o el caso concluye formalmente.

### Recorrido Principal del Administrador (Moderación y Seguridad):
6. **Moderación y Convivencia Segura:** Supervisar la plataforma, recibir denuncias de la comunidad ante contenido fraudulento o indebido, aplicar bajas de publicaciones y suspender usuarios infractores.

---

## 2. User Story Map: Ejemplo con una Actividad

A continuación se ilustra la descomposición de la actividad **"Alertas y Búsqueda Geolocalizada"** en pasos de usuario secuenciales, diferenciando las tareas esenciales del MVP de las funcionalidades avanzadas:

### Actividad: Alertas y Búsqueda Geolocalizada
* **Paso 1: Consultar alertas comunitarias**
  * *Tareas MVP:*
    * `HU-S2-01:` Feed dedicado con tarjetas visuales priorizadas y badges de estado (`Perdida` / `Encontrada`).
    * `HU-S2-06:` Filtro de reportes por localidad o ciudad (estilo marketplace).
  * *Tareas Avanzado:*
    * Ordenamiento dinámico según cercanía geográfica y radios de alerta por barrio.
* **Paso 2: Visualizar la zona del reporte**
  * *Tareas MVP:*
    * `HU-S2-02:` Botón "Ver zona en mapa" que despliega un visor contextual con el radio aproximado del barrio (sin revelar domicilio exacto por seguridad).
  * *Tareas Avanzado:*
    * Rutas de avistamientos cronológicos y mapa interactivo de calor con avistamientos recientes.
* **Paso 3: Publicar una alerta de mascota**
  * *Tareas MVP:*
    * `HU-S2-03:` Formulario de publicación con foto, especie neutral (Regla 4), raza, colores y fecha.
    * `HU-S2-04:` Marcación de ubicación en mapa interactivo o detección automática de coordenadas por GPS.
  * *Tareas Avanzado:*
    * `HU-S3-06:` Generación asistida del reporte reutilizando la foto y atributos detectados previamente por la cámara IA.

---

## 3. Cómo Leer el Mapa

El User Story Map se organiza en dos dimensiones ortogonales:

* **Fila Superior (Actividades):** Representa el recorrido horizontal de alto nivel del usuario comunitario y del administrador a lo largo de todo el ciclo de vida del producto.
* **Nivel / Fila MVP (Minimum Viable Product):** Contiene las funcionalidades y tareas indispensables para lanzar la primera versión del sistema (cubiertas en los **Sprints 1 y 2**). Garantiza que la comunidad pueda registrarse, publicar alertas, ubicarlas en mapa y cerrar reportes resueltos.
* **Nivel / Fila Avanzado:** Funcionalidades complejas e incrementales desarrolladas en iteraciones posteriores (**Sprints 3, 4 y 5**), que incorporan el escáner neuronal con IA, la mensajería directa en tiempo real con notificaciones acumulativas y el módulo de moderación y seguridad.

---

## 4. Diagrama del User Story Mapping

```mermaid
flowchart TD
    %% Fila Superior: Actividades del Recorrido (Backbone)
    subgraph Actividades["ACTIVIDADES DE ALTO NIVEL (RECORRIDO PRINCIPAL)"]
        direction LR
        Act1["1. Descubrimiento Social"]
        Act2["2. Alertas y Mapas"]
        Act3["3. Reconocimiento IA"]
        Act4["4. Chat y Contacto"]
        Act5["5. Cierre y Reencuentro"]
        Act6["6. Moderación y Seguridad"]
        Act1 --> Act2 --> Act3 --> Act4 --> Act5 --> Act6
    end

    %% Fila Intermedia: Tareas MVP (Sprints 1 y 2)
    subgraph MVP["LÍNEA MVP (LO ESENCIAL PARA LANZAR LA PRIMERA VERSIÓN)"]
        direction LR
        MVP1["• Feed social comunitario (HU-S1-01)<br/>• Crear publicación con foto (HU-S1-02)<br/>• Reaccionar Me gusta (HU-S1-03)<br/>• Filtro por categorías (HU-S1-04)<br/>• Ficha detalle de mascota (HU-S1-05)<br/>• Guardar favoritos (HU-S1-06)"]
        MVP2["• Feed de reportes visuales (HU-S2-01)<br/>• Ver zona aproximada en mapa (HU-S2-02)<br/>• Publicar reporte perdida/encontrada (HU-S2-03)<br/>• Selector de ubicación GPS (HU-S2-04)<br/>• Filtro por ciudad (HU-S2-06)"]
        MVP3["• Entrada manual tradicional<br/>(Diferido para Release 2)"]
        MVP4["• Contacto telefónico opcional directo<br/>(Diferido para chat integrado)"]
        MVP5["• Marcar reporte como caso resuelto (HU-S2-05)<br/>• Badge de mascota reunida"]
        MVP6["• Términos y normas de convivencia<br/>(Moderación básica inicial)"]
    end

    %% Fila Inferior: Tareas Avanzado (Sprints 3, 4 y 5)
    subgraph Avanzado["LÍNEA AVANZADO (DESARROLLO EN ITERACIONES POSTERIORES)"]
        direction LR
        ADV1["• Algoritmo de contenidos sugeridos<br/>• Fotos ampliadas con aspect-ratio natural"]
        ADV2["• Radios dinámicos de avistamiento<br/>• Mapas de calor de zonas críticas"]
        ADV3["• Acceso a escáner IA (HU-S3-01)<br/>• Extracción de rasgos físicos (HU-S3-02)<br/>• Búsqueda automática de matches (HU-S3-03)<br/>• Visualización de similitud % (HU-S3-04)<br/>• Reporte asistido sin matches (HU-S3-06)"]
        ADV4["• Bandeja cronológica de chats (HU-S4-01)<br/>• Chat privado 1 a 1 unificado (HU-S4-02)<br/>• Mensajería en tiempo real con fotos (HU-S4-03)<br/>• Cabecera y chips multitema (HU-S4-04)<br/>• Notificaciones nativas acumulativas (HU-S4-05)<br/>• Notificaciones push remotas (HU-S4-06)"]
        ADV5["• Generación de historias de reencuentro en feed<br/>• Métricas de tiempo de búsqueda"]
        ADV6["• Denunciar publicaciones y chat (HU-S5-01)<br/>• Bloqueo automático de usuarios reportados<br/>• Bandeja de denuncias para admin (HU-S5-02)<br/>• Baja de contenido fraudulento (HU-S5-03)<br/>• Advertencia y suspensión de cuentas (HU-S5-04)"]
    end

    %% Conexiones entre Actividades, MVP y Avanzado
    Act1 --> MVP1 --> ADV1
    Act2 --> MVP2 --> ADV2
    Act3 --> MVP3 --> ADV3
    Act4 --> MVP4 --> ADV4
    Act5 --> MVP5 --> ADV5
    Act6 --> MVP6 --> ADV6
```
