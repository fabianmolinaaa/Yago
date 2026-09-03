# Roles del Sistema - Yago

Este documento describe los roles de usuario contemplados en la plataforma **Yago** y los permisos asociados a cada uno para la gestión de animales perdidos y encontrados.

---

## 1. Usuario General / Dueño de Mascota

Representa a cualquier ciudadano que utiliza la aplicación para reportar la pérdida de su mascota o dar aviso de un animal que encontró en la calle.

### Permisos y Funcionalidades:
- [ ] Registrarse e iniciar sesión en la aplicación.
- [ ] Gestionar su perfil y datos de contacto de preferencia.
- [ ] Publicar reportes de mascotas perdidas (con fotos, ubicación GPS y señas particulares).
- [ ] Publicar reportes de animales encontrados o avistados en la vía pública.
- [ ] Editar o dar de baja sus propios reportes.
- [ ] Marcar un caso como "Resuelto / Reencontrado".
- [ ] Explorar el mapa y listado de animales reportados con filtros de búsqueda.
- [ ] Contactar al publicador de un reporte a través de los canales habilitados.
- [ ] Reportar publicaciones sospechosas, inapropiadas o duplicadas.

---

## 2. Rescatista / Voluntario / Refugio

Usuario comprometido o integrante de asociaciones protectoras, refugios o veterinarias aliadas que colaboran activamente en el seguimiento y tránsito de animales perdidos.

### Permisos y Funcionalidades (Sugeridas):
- [ ] Todas las funciones del Usuario General.
- [ ] Acceso a insignia o estado de perfil verificado (si aplica).
- [ ] Actualizar el estado de seguimiento o tránsito temporal de un animal reportado.
- [ ] Recibir alertas focalizadas de animales en situación de riesgo en su radio de acción.
- [ ] *[Completar: permisos específicos para refugios/rescatistas]*

---

## 3. Administrador / Moderador

Encargado de la supervisión general, integridad de la información y buen uso de la plataforma comunitaria.

### Permisos y Funcionalidades:
- [ ] Acceso a panel de administración o moderación.
- [ ] Gestionar reportes denunciados por la comunidad (contenido spam, fotos inapropiadas, etc.).
- [ ] Editar, ocultar o eliminar cualquier reporte que incumpla las normas de convivencia.
- [ ] Suspender o bloquear temporal/definitivamente usuarios que hagan mal uso de la plataforma.
- [ ] Visualizar estadísticas generales de la aplicación (reportes activos, casos resueltos, zonas con mayor actividad).
- [ ] *[Completar: permisos adicionales de configuración del sistema]*

---

## Matriz Resumen de Permisos

| Acción | Usuario General | Rescatista / Refugio | Administrador |
| :--- | :---: | :---: | :---: |
| Crear reporte de animal | Sí | Sí | Sí |
| Editar/Eliminar reportes propios | Sí | Sí | Sí |
| Contactar a otros usuarios | Sí | Sí | Sí |
| Marcar caso como resuelto | Propios | Propios / Vinculados | Cualquier reporte |
| Moderar / Eliminar reportes ajenos | No | No | Sí |
| Suspender cuentas de usuario | No | No | Sí |
