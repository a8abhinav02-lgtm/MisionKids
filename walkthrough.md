# Visita Guiada Final: Mission Kids 🏁

Esta aplicación ha sido diseñada para fomentar la autonomía y responsabilidad de los niños mediante un sistema de gamificación en la nube.

---

## 🛠️ Cómo funciona ahora (Version Web/Cloud)

### 1. Acceso Universal
- La aplicación está desplegada en **Cloudflare Pages**. Puedes acceder desde cualquier navegador en computadora, tablet o móvil.
- **PWA**: Si entras desde un móvil, puedes darle a "Compartir" -> "Agregar a inicio" para que se instale como una App nativa con el icono de Mission Kids.

### 2. Sincronización Real
- Todo lo que un niño hace en su perfil se ve reflejado **instantáneamente** en el panel del administrador (padre).
- Si el padre aprueba una tarea, el saldo del niño se actualiza de inmediato aunque estén en dispositivos distintos.

### 3. Reglas de Misiones
- **Bloqueo de Franja**: Los niños solo pueden marcar tareas en su horario actual (Mañana/Tarde/Noche).
- **El Deber es Primero**: Las misiones de puntos están bloqueadas si hay misiones obligatorias (iconos de llave 🔑) pendientes en el bloque actual o anteriores.

---

## 👨‍👩‍👧‍👦 Flujo Recomendado para Padres

1.  **Configurar Familias**: Al iniciar, el administrador crea la cuenta con un PIN.
2.  **Crear Misiones**: Desde el panel de Admin, crea tareas diarias o semanales. Marca las responsabilidades críticas como "Obligatorias".
3.  **Seguir el Progreso**: Revisa la sección de "Aprobaciones" para ver las misiones enviadas por los niños.
4.  **Consolidar Puntos**: Una vez aprobadas, los puntos se suman al saldo del niño para ser canjeados por metas reales (ej: Nintendo Switch).

---

## 🚀 Despliegue Técnico
- **Repo**: Sincronizado en `main`.
- **Hosting**: Cloudflare Pages vinculado a GitHub.
- **Back-end**: Firebase (Auth + Firestore).

**¡La aplicación está lista para que Mission Kids comience su gran aventura!**
