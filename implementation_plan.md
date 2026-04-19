# Proyecto: Mission Kids 🚀 (Anteriormente Misión Switch 2)

Este proyecto ha logrado transformar una aplicación local en una plataforma en la nube sincronizada en tiempo real, con una arquitectura lista para la web y reglas de negocio sólidas.

## Hitos Logrados ✅

### 1. Sistema de Autorización y Nube (Firebase) ✅
- **Auth**: Registro e Inicio de Sesión de padres mediante PIN.
- **Firestore**: Sincronización bidireccional instantánea.
- **Unificación de Identidad**: Vinculación eficiente de perfiles por nombre entre dispositivos.

### 2. Normativas de Interacción y Flujo de Tareas ✅
- **Activación por Franja Horaria**: Restricción según el bloque horario actual (Mañana, Tarde, Noche).
- **Bloqueo "Deber antes que Puntos"**: Se impide enviar misiones de puntos si hay "Llaves 🔑" obligatorias pendientes.
- **Aprobación Admin**: Libertad total para el administrador desde cualquier lugar.

### 3. Despliegue Web y Branding ✅
- **Rebrand**: Cambio exitoso de nombre a "Mission Kids".
- **Cloudflare Pages**: Despliegue automatizado vía GitHub con script de construcción custom (`build_web.sh`).
- **PWA**: Configurado para funcionar como una aplicación instalable en móviles desde el navegador.

---

## 🧪 Fase Actual: Testeo y Verificación
- Verificación de sincronización en vivo entre versión Web y Android.
- Validación de flujos de aprobación en tiempo real.
- Pruebas de experiencia de usuario (UX) para niños.

**Rama de producción:** `main` (Sincronizada con Cloudflare).
