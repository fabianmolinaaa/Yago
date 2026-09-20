# Directivas y Reglas para Asistentes de IA (AGENTS.md) — Yago

Este archivo establece las reglas operativas, convenciones de código y directivas de gestión que **cualquier Asistente de IA (Antigravity, Gemini Code Assist, etc.) DEBE cumplir obligatoriamente** al operar dentro de este repositorio.

---

## 📌 Contexto del Proyecto
* **Proyecto:** Yago — Aplicación móvil comunitaria para búsqueda y reencuentro de mascotas perdidas.
* **Stack:** Flutter & Dart, Firebase (Auth, Firestore, Cloud Storage), Google Gemini AI.
* **Marco Académico:** Cátedra (2138) Laboratorio de Desarrollo de Software (2026).

---

## 🚨 Regla 1: Convenciones Estrictas de Git y GitHub
1. **Identificador de Historia Obligatorio en Commits:**
   * Todo commit asociado a una Historia de Usuario **DEBE comenzar siempre** con el código de la historia:
     ```text
     [Código HU]: [tipo]([ámbito]): [descripción]
     # O bien:
     [Código HU]: [descripción concisa]
     ```
   * *Ejemplos:* 
     * `HU-S1-01: feat(feed): implementa visualización del feed comunitario`
     * `HU-S1-02: crea pantalla de creación de publicaciones comunitarias`
2. **Entrega de Commits para Trello:**
   * Al finalizar la implementación de una historia o tarea, el agente **debe proporcionar explícitamente el hash y el enlace directo al commit** (`https://github.com/fabianmolinaaa/Yago/commit/[hash]`) para que el usuario pueda pegarlo en el checklist *"Evidencias"* de la tarjeta en Trello.
3. **Cierre de Sprint y Tags:**
   * Al cerrar un sprint, el comando de congelamiento es estrictamente:
     ```bash
     git tag sprint-N-entrega
     git push origin sprint-N-entrega
     ```
4. **Referencia completa:** Consulta siempre [docs/PoliticasGitHub.md](docs/PoliticasGitHub.md).

---

## 📋 Regla 2: Alineación con Trello y Gestión Ágil
1. **Trazabilidad con Historias de Usuario:**
   * Toda funcionalidad desarrollada debe contrastarse contra [docs/HistoriasDeUsuario.md](docs/HistoriasDeUsuario.md).
2. **Definición de Terminado (DoD):**
   * Una funcionalidad **NO está terminada** solo por programar el código. Debe cumplir con el 100% de los criterios de aceptación y pasar pruebas de no regresión sobre historias previas.
3. **Descomposición:**
   * Nunca tratar tareas técnicas sueltas (ej.: *"crear botón"*, *"crear índice en Firestore"*) como historias independientes; son tareas dentro de una Historia de Usuario (`HU-XX`).
4. **Referencia completa:** Consulta siempre [docs/GestionTrello.md](docs/GestionTrello.md).

---

## 🎨 Regla 3: Estilo de Código y UI
1. Seguir estrictamente el sistema de diseño definido en [docs/DesignSystem.md](docs/DesignSystem.md) (paleta cromática, tipografías, componentes oficiales `PetCard`, `YagoBottomNavBar`, etc.).
2. Mantener la arquitectura modular definida en [docs/Estructura.md](docs/Estructura.md).
3. No generar comentarios públicos en las publicaciones ni mapas globales libres de acuerdo con las decisiones de seguridad de [docs/Alcance.md](docs/Alcance.md).
