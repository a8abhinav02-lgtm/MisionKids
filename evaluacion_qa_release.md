# Reporte de Evaluación QA & Release Manager

## Veredicto: [Riesgo Crítico]

---

## Análisis de Impacto

**Qué funciona bien en la estructura actual:**
* **Estructura de Directorios:** El proyecto cuenta con una separación inicial aceptable separando las capas en `models/`, `providers/`, `services/`, y `ui/`. 
* **State Management:** El uso de `Provider` con `ChangeNotifierProxyProvider` en `main.dart` para inyectar dependencias (ej. `auth` a `perfiles` y `tareas`) es un enfoque estándar en Flutter que permite sincronizar el estado reactivo cuando cambian las credenciales de la familia.
* **Integración Base:** Se encuentran configurados e integrados múltiples servicios esenciales como Firebase (Auth, Firestore), almacenamiento local (Hive) y notificaciones locales.
* **Reglas de Seguridad:** Se ha realizado un esfuerzo por limitar el acceso a la lectura y modificación de los datos familiares utilizando funciones de autorización como `esPropietario()`.

---

## Defectos/Riesgos

**1. Seguridad Informática:**
* **Almacenamiento de PIN sin cifrar:** El PIN de control parental se guarda localmente usando `Hive` en texto plano y de la misma manera en Firestore (`auth_provider.dart`). Si el dispositivo o la base de datos se ven comprometidos, se exponen estas credenciales.
* **Enumeración y Abuso de Cuentas:** En el flujo de *Unirse a Familia* (`setup_familia_screen.dart`), si la autenticación falla por contraseña inválida, el sistema captura el error y automáticamente crea la cuenta, generando colisiones y comportamientos impredecibles.
* **Privilegios de Creación (Firestore):** Las reglas permiten crear documentos en `/familias/{familiaId}` con solo estar autenticado, lo cual abre la puerta a inyección masiva de datos basura en la colección raíz por parte de un actor malicioso.

**2. Arquitectura y Calidad del Código:**
* **Acoplamiento Fuerte:** La capa de presentación (`setup_familia_screen.dart`) contiene demasiada lógica de negocio (por ejemplo, validando los fallos exactos de FirebaseAuth y decidiendo flujos de registro o migración). 
* **Ausencia de Clean Architecture:** Faltan las capas formales de *Domain* (Casos de Uso) y repositorios *Repository/Data Sources*. `AuthProvider` maneja tanto las llamadas de red a Firestore, la autenticación y la escritura en Hive simultáneamente, violando el Principio de Responsabilidad Única (SRP).
* **Deuda Técnica en Paquetes:** `flutter analyze` expone 26 paquetes desactualizados en `pubspec.yaml` (ej. `firebase_auth`, `cloud_firestore`), lo que puede traducirse en vulnerabilidades conocidas en producción.

**3. Diseño UI/UX y Accesibilidad:**
* **Uso de APIs Deprecadas:** Uso masivo de `.withOpacity()` reportado por el linter estático (recomendación: `.withValues(alpha:)`).
* **Bloqueos de UI:** Alertas por `use_build_context_synchronously` indican que el `BuildContext` se usa tras un `await` en los callbacks de los botones sin validación segura inmediata (e.g. validando `mounted` apropiadamente antes del `ScaffoldMessenger`).

**4. Rendimiento y Optimización:**
* **Hive sobrecarga inicial:** Las inicializaciones síncronas/asíncronas al levantar la app pueden generar *frames drop* si la caja de autenticación se vuelve grande (o si se usan adaptadores pesados en el hilo principal).
* **Ausencia de índices definidos:** No es claro si hay índices optimizados de Firestore configurados para consultas masivas sobre las tareas de un niño o una familia, lo cual afectaría el rendimiento a escala.

**5. Preparación para Producción:**
* **Manejo de Errores Deficiente:** Los bloques `catch (e)` muestran un `e.toString()` crudo al usuario en *SnackBars* (ej. `[firebase_auth/invalid-email]...`). Esto no es aceptable para producción; se requieren mensajes traducidos y amigables.
* **Falta de Entornos (Environments/Flavors):** No hay separación entre Desarrollo y Producción. Hacer pruebas puede corromper o ensuciar la base de datos viva.
* **Ausencia de Monitoreo:** No hay integración con Firebase Crashlytics para capturar fallos de usuarios en producción o rastrear el impacto de excepciones silenciosas.

---

## Plan de Acción y Código

A continuación se plantean los pasos exactos y refactorizaciones para estabilizar el producto para su "Release".

### Acción 1: Seguridad en el Almacenamiento Local (Flutter Secure Storage)
*Razón:* No guardar PIN o credenciales en texto plano usando `Hive`.

**Código a refactorizar (Reemplazo parcial de `caja_auth_v2`):**
```dart
// 1. Agregar a pubspec.yaml: flutter_secure_storage: ^9.0.0
// 2. Crear un servicio dedicado:

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    // Aquí puedes realizar un Hash (SHA-256) antes de guardarlo o usar SecureStorage puro.
    await _storage.write(key: 'pin_padre', value: pin);
  }

  Future<String?> readPin() async {
    return await _storage.read(key: 'pin_padre');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### Acción 2: Separación de Lógica en "Unirse a Familia" 
*Razón:* Evitar el "silencio" y la mezcla de flujos SignIn/SignUp en la UI.

**Refactorización en `setup_familia_screen.dart` (Flujo "JoinStep"):**
```dart
// En lugar de hacer try/catch ciego, extrae la lógica al Provider (SRP).
try {
  await authProv.joinFamilyFlow(
    email: _emailCtrl.text.trim(), 
    password: _passCtrl.text, 
    codigo: codigo
  );
  if (!mounted) return;
  Navigator.pushReplacement(...);
} on FirebaseAuthException catch (e) {
  if (!mounted) return;
  final errorMessage = ErrorHandler.getMessage(e.code);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
}
```

### Acción 3: Manejador de Errores Global (Producción)
*Razón:* Mostrar errores amigables al usuario y preparar para Crashlytics.

**Crear `lib/services/error_handler.dart`:**
```dart
class ErrorHandler {
  static String getMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'El usuario no está registrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya tiene una cuenta activa.';
      case 'network-request-failed':
        return 'Comprueba tu conexión a internet e inténtalo de nuevo.';
      default:
        return 'Ocurrió un error inesperado. Inténtalo más tarde.';
    }
  }
}
```

### Acción 4: Solución de Advertencias del Compilador
*Razón:* Limpiar la deuda técnica.

1.  **Reemplazar Opacity:** Buscar en `lib/ui/screens` todo `withOpacity(0.5)` y cambiar a `withValues(alpha: 0.5)`.
2.  **Solucionar `use_build_context_synchronously`:** Asegurar siempre colocar `if (!mounted) return;` justo antes de usar `context` en cualquier bloque `async` de la UI.
3.  **Actualización de `pubspec.yaml`:**
    ```bash
    flutter pub upgrade --major-versions
    ```

### Acción 5: Restricción en Firestore Rules
*Razón:* Evitar inyección de datos basura.

```javascript
// En firestore.rules, dentro de familias/{familiaId}
allow create: if usuarioAutenticado() &&
              request.resource.data.keys().hasAll(['email_padre', 'fecha_creacion', 'padres']) &&
              request.resource.data.padres[0] == request.auth.uid;
```
