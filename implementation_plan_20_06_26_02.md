# Implementación de Mejoras de Calidad y Seguridad (Fases 1 a 4)

Este plan describe los pasos técnicos para implementar secuencialmente las mejoras de seguridad y calidad reportadas en la auditoría, abarcando desde la fase 1 hasta la fase 4, omitiendo la fase 5 como fue solicitado. El objetivo es reforzar la arquitectura, la seguridad de datos locales y resolver advertencias del compilador sin afectar la funcionalidad existente ni corromper los datos en web o nativo.

## User Review Required

> [!IMPORTANT]
> Este plan involucra la creación de un nuevo branch (`fix/qa-improvements`) e instalar una nueva dependencia (`flutter_secure_storage`). Revisa los pasos y si estás de acuerdo, procede a aprobar el plan.

## Proposed Changes

### 1. Preparación del Entorno
* **Nuevo Branch:** Crear y cambiar a la rama `fix/qa-improvements`.
* **Dependencias:** Agregar `flutter_secure_storage: ^9.0.0` a `pubspec.yaml` e instalar dependencias usando `flutter pub get`. También se correrá `flutter pub upgrade --major-versions` para actualizar dependencias obsoletas según la auditoría (Fase 4).

### 2. Acción 1: Seguridad en Almacenamiento Local
Migrar el almacenamiento en texto plano del PIN a un almacenamiento seguro.

#### [NEW] [secure_storage_service.dart](file:///c:/Users/angel/josue_tareas/lib/services/secure_storage_service.dart)
* Crear servicio `SecureStorageService` que actúe como un *wrapper* alrededor de `FlutterSecureStorage` para manejar la persistencia encriptada del `pin_padre`. En web, esto usará localStorage de forma transparente (limitación inherente a web, pero estandarizada por el paquete).

#### [MODIFY] [auth_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/auth_provider.dart)
* Inyectar `SecureStorageService` dentro de `AuthProvider`.
* Cambiar las llamadas locales de `_cajaConfig!.put('pin_padre', ...)` para usar `SecureStorageService.savePin()`.
* Al leer el PIN local o validarlo, usar el método de lectura seguro en lugar del diccionario genérico de Hive.

### 3. Acción 3: Manejador de Errores Global
Centralizar la traducción de errores técnicos a mensajes amigables.

#### [NEW] [error_handler.dart](file:///c:/Users/angel/josue_tareas/lib/services/error_handler.dart)
* Crear la clase estática `ErrorHandler` con el método `getMessage(String errorCode)` que mapee códigos de error conocidos de `FirebaseAuthException` y devuelva cadenas de texto legibles para el usuario.

### 4. Acción 2: Separación de Lógica en "Unirse a Familia"
Refactorizar la lógica acoplada en la pantalla de registro para delegarla al Provider y manejar los errores correctamente usando el nuevo `ErrorHandler`.

#### [MODIFY] [setup_familia_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/setup_familia_screen.dart)
* En el paso de "Unirse a Familia" (`_buildJoinStep`), eliminar el anidamiento de validaciones y el `try/catch` directo de Firebase Auth.
* Delegar la ejecución de unión a un nuevo o modificado método del `AuthProvider`.
* Utilizar `ErrorHandler.getMessage(e.code)` al capturar errores (e.g. `FirebaseAuthException`) y mostrar el SnackBar.
* Verificar correctamente si el widget está montado (`if (!mounted) return;`) antes de interactuar con el contexto.

#### [MODIFY] [auth_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/auth_provider.dart)
* Agregar un método `unirseConEmailYCodigo` que maneje internamente la aserción de `signInWithEmailAndPassword` o la creación de cuenta, lanzando excepciones nativas hacia la UI si falla por razones no previstas (como contraseña errónea en una cuenta existente).

### 5. Acción 4: Solución de Advertencias del Compilador
Corrección de alertas estáticas y limpieza de código.

#### [MODIFY] [Archivos de UI en general](file:///c:/Users/angel/josue_tareas/lib/ui/screens/)
* Reemplazar cualquier instancia restante de `.withOpacity(x)` por `.withValues(alpha: x)` (si existen, realizaremos una verificación con `flutter analyze`).
* Añadir protecciones `if (!mounted) return;` después de cada `await` en los callbacks de botones en `setup_familia_screen.dart` y `admin_screen.dart`.

#### [MODIFY] [widget_test.dart](file:///c:/Users/angel/josue_tareas/test/widget_test.dart)
* Actualizar el nombre de clase `MyApp` a `MiAppTareas()` para que pase los tests base de Flutter.

---

## Verification Plan

### Automated Tests
* Ejecutar `flutter analyze` para verificar que ya no existan alertas por `use_build_context_synchronously`, `deprecated_member_use`, o errores en `widget_test.dart`.
* Ejecutar `flutter test` para validar que el archivo modificado compila sin problemas.

### Manual Verification
* Lanzar la app en Windows (`flutter run -d windows`) y/o Web (`flutter run -d chrome`).
* Validar que la sincronización con una cuenta existente funciona sin romperse.
* Iniciar el proceso de "Unirse a Familia", colocar una contraseña intencionalmente incorrecta para verificar que el nuevo `ErrorHandler` captura el evento y muestra el error de forma correcta sin crear una cuenta duplicada.
* Verificar que la variable persistida del PIN padre funciona correctamente tras reiniciar la aplicación, indicando que el Secure Storage es funcional.
