# Tecnologías del Proyecto

Este documento resume las tecnologías y herramientas que se utilizarán para el desarrollo de **StandMap**.

---

## 1. Aplicación Móvil

* **Flutter & Dart**
  * *Uso:* Creación de la aplicación móvil y desarrollo del plano interactivo donde se visualizan y mueven los stands.
* **Android Studio**
  * *Uso:* Entorno para programar, probar la aplicación en emuladores y compilarla en Android.

---

## 2. Backend y Base de Datos

* **Firebase**
  * *Uso:* Plataforma en la nube para gestionar el backend de forma directa, sin necesidad de crear ni mantener un servidor propio.
* **Cloud Firestore**
  * *Uso:* Base de datos para guardar los eventos, stands y expositores, actualizando la información al instante cuando se hace un cambio en el plano.
* **Firebase Authentication**
  * *Uso:* Registro e inicio de sesión para identificar a los usuarios y sus permisos (Organizador o Colaborador).

---

## 3. Inteligencia Artificial

* **Sin definir**
  * *Uso:* Se elegirá más adelante para implementar el asistente que responderá preguntas y dará sugerencias sobre la distribución de los stands.

---

## 4. Control de Versiones y Organización

* **Git + GitHub**
  * *Uso:* Llevar el historial de cambios del proyecto y tener una copia de respaldo segura en la nube.
* **Trello**
  * *Uso:* Tablero visual para organizar las tareas pendientes y hacer seguimiento de las entregas de la cátedra.

---

## Resumen

| Componente                  | Tecnología              | Para qué se usa                           |
| --------------------------- | ----------------------- | ----------------------------------------- |
| **App Móvil**               | Flutter & Dart          | Interfaz de la app y plano interactivo    |
| **Entorno Android**         | Android Studio          | Pruebas en emuladores y compilación       |
| **Backend**                 | Firebase                | Servicios en la nube sin servidor propio  |
| **Base de Datos**           | Cloud Firestore         | Guardar datos y actualizarlos al instante |
| **Autenticación**           | Firebase Authentication | Inicio de sesión y control de roles       |
| **Inteligencia Artificial** | *Sin definir*           | Asistente de consultas y sugerencias      |
| **Control de Versiones**    | Git + GitHub            | Historial de versiones y respaldo         |
| **Organización**            | Trello                  | Seguimiento de tareas y entregas          |
