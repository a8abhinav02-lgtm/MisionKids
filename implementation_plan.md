# Proyecto: Misión Switch 2 (Consolidación de Fase de Testeo) 🚀

Este proyecto ha logrado transformar una aplicación local en una plataforma en la nube sincronizada en tiempo real, implementando rigurosas reglas de negocio para el flujo de tareas.

## Hitos Logrados (Fase 4 & Flujo Operativo) ✅

### 1. Sistema de Autorización y Nube (Firebase) ✅
- **Auth**: Registro e Inicio de Sesión de padres mediante PIN.
- **Firestore**: Sincronización bidireccional instantánea.
- **Unificación de Identidad**: Vinculación eficiente de perfiles por nombre entre dispositivos.

### 2. Normativas de Interacción y Flujo de Tareas ✅
- **Activación por Franja Horaria**: El niño solo puede interactuar con las misiones que pertenecen al bloque horario actual (Mañana, Tarde, Noche).
- **Inactivación de Misiones Pasadas**: Las tareas de bloques pasados o futuros se muestran pero están congeladas para el perfil de hijo.
- **Aprobación Extendida (Padre)**: El padre mantiene privilegios de admin, pudiendo aprobar tareas de cualquier franja y fecha desde su panel.

### 3. Condiciones de Gamificación (Puntos vs Obligaciones) ✅
- **Bloqueo Inteligente**: Se impide que el niño envíe a revisión misiones de puntos opcionales si mantiene deudas de misiones obligatorias (Llaves 🔑) en el bloque actual o en los pasados del día.
- Se implementó un aviso `SnackBar` rojo para educar e incentivar el cumplimiento de los deberes.

---

## Próximos pasos sugeridos post-testeo
- Testeo de latencia de red bajo conexiones inestables.
- Implementación de notificaciones push Cloud Messaging (FCM).
- Tienda de recompensas secundarias.

**Estado del repositorio:** 100% Sincronizado en `feature/refactor-multiusuario`.
