# Yago - Sistema de Reporte y Búsqueda de Animales Perdidos

Aplicación móvil orientada a la comunidad para el reporte, localización y reencuentro de mascotas y animales perdidos.

---

## 1. Descripción General

> *[Completar: Breve resumen de la visión de la aplicación, el problema que busca resolver y el impacto esperado en la comunidad]*

---

## 2. Objetivo del Proyecto

* **Objetivo General:**
  * *[Completar: Propósito principal de la plataforma]*

* **Objetivos Específicos:**
  * *[Completar: Objetivos puntuales, ej. agilizar el reporte inmediato con foto y geolocalización, facilitar la búsqueda en mapa, etc.]*

---

## 3. Alcance del Sistema (Dentro de Alcance)

* [ ] **Gestión de Reportes de Animales:** Publicación de mascotas perdidas y encontradas (datos, fotos, rasgos distintivos, fecha/hora y ubicación).
* [ ] **Mapa Interactivo y Geolocalización:** Visualización de alertas de animales perdidos o vistos recientemente en zonas cercanas.
* [ ] **Búsqueda y Filtros:** Filtrado por especie, raza, tamaño, color, zona geográfica y estado (perdido / encontrado / en tránsito).
* [ ] **Notificaciones y Alertas Comunitarias:** Avisos a usuarios cercanos cuando se reporta un animal perdido en la zona.
* [ ] **Canal de Contacto / Mensajería:** Comunicación entre quien encontró la mascota y el dueño o rescatista.
* [ ] **Gestión de Usuarios y Perfiles:** Registro, historial de reportes publicados y datos de contacto seguros.

---

## 4. Fuera de Alcance

> *[Completar y ajustar según los límites definidos para esta etapa del proyecto]*

- [ ] Venta o comercialización de animales y accesorios.
- [ ] Servicios veterinarios de urgencia o historias clínicas digitales complejas.
- [ ] Pasarela de pagos o procesamiento de donaciones (inicialmente).
- [ ] Reconocimiento biométrico facial automatizado avanzado de animales (salvo que se incorpore IA en etapas posteriores).
- [ ] Cobertura logística de rescate o transporte de animales.

---

## 5. Épicas Principales

1. **Gestión de Usuarios y Autenticación:** Registro, acceso y administración del perfil del usuario.
2. **Reporte de Animales Perdidos y Encontrados:** Formularios ágiles para cargar datos clave, fotografías y punto en el mapa.
3. **Mapa y Exploración Geográfica:** Visualización en mapa con marcadores según estado y proximidad.
4. **Búsqueda, Filtros y Detalle:** Búsqueda rápida por características físicas y visualización de la ficha del animal.
5. **Comunicación y Reencuentro:** Mecanismos para contactar al reportante y marcar el caso como "Resuelto".
6. **Moderación y Administración:** Validación de publicaciones y control de reportes indebidos o duplicados.

---

## 6. Historias de Usuario

### Épica 1: Autenticación y Perfil

| ID | Historia de Usuario | Criterios de Aceptación / Notas | Prioridad |
| :--- | :--- | :--- | :--- |
| US-AUTH-01 | Como usuario, quiero registrarme e iniciar sesión para gestionar mis reportes y contactar a otros usuarios. | | Alta |
| US-AUTH-02 | Como usuario, quiero configurar mis datos de contacto para que puedan comunicarse conmigo si encuentran a mi mascota. | | Alta |

### Épica 2: Reporte de Animales

| ID | Historia de Usuario | Criterios de Aceptación / Notas | Prioridad |
| :--- | :--- | :--- | :--- |
| US-REP-01 | Como usuario, quiero publicar el reporte de mi mascota perdida con fotos, descripción y ubicación de extravío para alertar a la comunidad. | | Alta |
| US-REP-02 | Como usuario, quiero reportar un animal que encontré o vi en la calle para que su dueño pueda identificarlo. | | Alta |
| US-REP-03 | Como autor de un reporte, quiero actualizar el estado a "Reencontrado / Resuelto" cuando la mascota vuelva a casa. | | Media |

### Épica 3: Mapa y Localización

| ID | Historia de Usuario | Criterios de Aceptación / Notas | Prioridad |
| :--- | :--- | :--- | :--- |
| US-MAP-01 | Como usuario, quiero ver un mapa con marcadores de animales perdidos y encontrados en mi zona para estar atento a mi alrededor. | | Alta |
| US-MAP-02 | Como usuario, quiero seleccionar un marcador en el mapa para ver una vista previa rápida del reporte. | | Media |

### Épica 4: Búsqueda y Filtros

| ID | Historia de Usuario | Criterios de Aceptación / Notas | Prioridad |
| :--- | :--- | :--- | :--- |
| US-SRC-01 | Como usuario, quiero filtrar reportes por tipo de animal, tamaño, color y distancia para acotar la búsqueda de mi mascota. | | Alta |
| US-SRC-02 | Como usuario, quiero ver el detalle completo de un reporte para verificar características particulares y fotos adicionales. | | Alta |

---

## 7. Justificación de la Plataforma Móvil

La elección de una aplicación móvil resulta clave para la temática de animales perdidos por:
* **Inmediatez en la vía pública:** Permite tomar una foto con la cámara y subir el reporte al instante en el lugar exacto del hallazgo o extravío.
* **Geolocalización precisa por GPS:** Captura automática de coordenadas sin necesidad de ingresar direcciones manuales.
* **Notificaciones push instantáneas:** Alertas oportunas a vecinos o personas cercanas ante un reporte urgente en su área de influencia.