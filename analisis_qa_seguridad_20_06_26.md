# Reporte de Análisis de Calidad y Seguridad (QA & Security)

**Proyecto:** Mission Kids (josue_tareas)
**Rol:** Ingeniero Analista de Calidad y Seguridad de Software

A continuación, presento un análisis riguroso del estado actual del proyecto, enfocado en identificar vulnerabilidades de seguridad, deuda técnica, bugs potenciales y oportunidades de mejora en la calidad del código.

---

## 1. Hallazgos de Seguridad (Security)

### 1.1 Almacenamiento de PIN en texto plano
**Severidad:** Alta
* **Descripción:** El PIN de acceso parental (`pin_padre`) se almacena en texto plano en la colección `familias` en Firestore y localmente en Hive (`auth_provider.dart`).
* **Riesgo:** Si un atacante compromete la base de datos de Firebase o accede a los archivos locales del dispositivo (dispositivos rooteados), el PIN quedará expuesto inmediatamente.
* **Sugerencia:** Implementar hashing para el PIN antes de enviarlo a Firestore (ej. usando SHA-256 o bcrypt con salt). Localmente, utilizar Flutter Secure Storage en lugar de Hive para datos sensibles como pines o tokens, o encriptar la caja de Hive usando `Hive.generateSecureKey()`.

### 1.2 Lógica de Autenticación Permisiva (Flujo de "Unirse a Familia")
**Severidad:** Media
* **Descripción:** En `setup_familia_screen.dart` (aprox. línea 492), el flujo de "Unirse a Familia" intenta hacer login y, si falla con `user-not-found` o `invalid-credential`, automáticamente intenta crear el usuario (`createUserWithEmailAndPassword`).
* **Riesgo:** Si un usuario existente ingresa mal su contraseña (`invalid-credential`), la app intentará registrar la cuenta nuevamente y fallará porque el correo ya existe, causando confusión. Además, permite enumeración de correos.
* **Sugerencia:** Separar claramente los flujos de "Iniciar Sesión" y "Registro". Mostrar mensajes de error precisos ("Contraseña incorrecta", "Usuario no encontrado") en lugar de bifurcar la lógica de creación.

### 1.3 Reglas de Firestore (Firestore Rules)
**Severidad:** Baja/Media
* **Descripción:** La regla `allow create: if usuarioAutenticado();` en la colección `familias` permite que cualquier usuario autenticado cree un documento en esa colección.
* **Riesgo:** Un usuario malintencionado podría crear documentos basura en la colección `familias`, incrementando los costos de Firebase.
* **Sugerencia:** Restringir los campos que se pueden enviar al crear una familia usando `request.resource.data.keys().hasOnly([...])` y validar que el UID del creador se encuentre dentro del array `padres`.

---

## 2. Calidad de Código y Deuda Técnica (Code Quality)

### 2.1 Uso de BuildContext en operaciones asíncronas
* **Descripción:** El linter reporta: `Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check` en varios puntos de la UI.
* **Sugerencia:** Asegurarse de que las validaciones `if (!mounted) return;` se ejecuten inmediatamente después de los `await` y antes de usar cualquier función que dependa de `context` (como `ScaffoldMessenger.of(context)` o `Navigator.push`). 

### 2.2 APIs Deprecadas de Flutter
* **Descripción:** El reporte de análisis estático (`flutter_analyze_utf8.txt`) muestra múltiples advertencias por el uso de `.withOpacity()` (deprecado).
* **Sugerencia:** Reemplazar `.withOpacity(x)` por `.withValues(alpha: x)` en archivos como `admin_screen.dart`, `home_nino_screen.dart` y `seleccion_perfil_screen.dart` para evitar pérdida de precisión de color y mantener compatibilidad con futuras versiones de Flutter.

### 2.3 Dependencias Desactualizadas
* **Descripción:** El comando `flutter analyze` indica que 26 paquetes tienen versiones más recientes disponibles.
* **Sugerencia:** Ejecutar `flutter pub outdated` y `flutter pub upgrade --major-versions` periódicamente. Mantener dependencias como `firebase_auth`, `cloud_firestore` y `provider` actualizadas previene bugs de seguridad conocidos.

### 2.4 Manejo Global de Errores
* **Descripción:** Los bloques `catch (e)` (por ejemplo, en `setup_familia_screen.dart`) capturan `Exception` de forma genérica y muestran el error crudo (`e.toString()`) en un SnackBar.
* **Sugerencia:** Implementar un gestor de errores (Error Handler) que traduzca las excepciones de Firebase (ej. `auth/network-request-failed`) a mensajes amigables para el usuario. Nunca mostrar excepciones crudas o trazas de pila (stacktraces) en el entorno de producción.

---

## 3. Pruebas y Mantenimiento (Testing)

### 3.1 Pruebas Unitarias y de Widgets Rotas
* **Descripción:** El archivo `test\widget_test.dart` falla con el error `The name 'MyApp' isn't a class`. Esto ocurre porque la clase raíz fue renombrada a `MiAppTareas` pero el test por defecto de Flutter no fue actualizado.
* **Sugerencia:** 
  1. Corregir el test básico actualizando `MyApp` a `MiAppTareas()`.
  2. Implementar pruebas unitarias (Unit Tests) para la lógica de `AuthProvider` y `TareaProvider`.
  3. Implementar pruebas de integración para el flujo crítico de "Registro de familia y unión por código".

### 3.2 Ausencia de Entornos (Environments)
* **Descripción:** Actualmente la aplicación apunta directamente a un solo proyecto de Firebase de producción.
* **Sugerencia:** Configurar Firebase Flavors (Desarrollo, Staging, Producción) para asegurar que las pruebas de nuevos features no corrompan los datos de usuarios reales.

---

## 📝 Plan de Acción Recomendado

1. **Corto Plazo (Hotfixes):**
   - Corregir los avisos del linter (`withOpacity` -> `withValues`).
   - Corregir el test básico roto (`widget_test.dart`).
   - Mejorar los chequeos `if (mounted)` en la UI.
2. **Mediano Plazo (Seguridad):**
   - Migrar el almacenamiento local del PIN a **Flutter Secure Storage**.
   - Refactorizar el flujo de autenticación "Login vs Join" para no crear cuentas al fallar contraseñas.
3. **Largo Plazo (Arquitectura):**
   - Configurar Flavors en Flutter (Dev/Prod).
   - Aumentar la cobertura de pruebas unitarias.
