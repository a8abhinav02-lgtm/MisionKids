# Refactorización Multiusuario + UX Premium

## Resumen del Objetivo
Reestructurar la aplicación **Misión Switch 2** para soportar múltiples perfiles de niños con temas personalizados, modularizar el código monolítico, elevar la experiencia visual a nivel premium y asegurar el respaldo en la nube vía GitHub.

---

## Fase 1: Modularización y Modelo Multiusuario ✅ COMPLETADA
- [x] Modelo `Perfil` independiente (Hive `typeId: 1`).
- [x] Gestión de puntos y metas vinculada al perfil activo.
- [x] `TareaProvider` filtrado por `perfilId`.
- [x] Adaptadores Hive regenerados.

## Fase 2: Arquitectura de UI ✅ COMPLETADA
- [x] Separación de `main.dart` en múltiples pantallas y widgets.
- [x] Flujo de entrada: Onboarding PIN (Setup) -> Selección de Perfil -> Dashboard.
- [x] Panel de Administración con Tabs dinámicas por hijo.
- [x] Formulario de Tareas avanzado (plantillas, frecuencia, jornada).

## Fase 3: Rediseño Premium y Sincronización ✅ COMPLETADA 🚀
- [x] **Estética Premium**: Gradientes, animaciones de pulso (animate_do), sombras glow y modo oscuro integrado.
- [x] **Dashboard Niño**: Header dinámico, saludo contextual y tarjetas tapeables (UX mejorada).
- [x] **Panel Padres**: Botón "Agregar Hijo" prominente y pestañas con avatar del niño.
- [x] **Respaldo GitHub**: Conexión remota con repositorio privado (`a8abhinav02-lgtm/MisionKids`) usando PAT.
- [x] **Estructura Git**: Rama `feature/refactor-multiusuario` aislada para pruebas.

---

## Fase 4: Integración con Firebase 🔜 PENDIENTE
- [ ] Migración de almacenamiento local (Hive) a la nube (Firestore).
- [ ] Sincronización multi-dispositivo en tiempo real.
- [ ] Notificaciones push para aprobaciones y multas.

---

## Estructura de Ramas
- **`main`**: Estado estable anterior (Versión 3.1).
- **`feature/refactor-multiusuario`**: Desarrollo actual con todas las mejoras de UX y multiusuario.
