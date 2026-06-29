# Plan de Implementación: Alertas de Actualización e Integración de Android APK

Este plan describe los pasos técnicos para implementar un sistema de alertas en la aplicación (in-app updates) para la versión Android y enriquecer la opción de "Compartir App" para incluir tanto el enlace web como el enlace del instalador de Android (APK). Todo se desarrollará en una nueva rama llamada `feature/updates`.

## User Review Required

> [!IMPORTANT]
> Este cambio requiere:
> 1. Añadir el paquete `url_launcher: ^6.2.5` a `pubspec.yaml` para permitir abrir el enlace del APK en el navegador del dispositivo Android.
> 2. Agregar una regla de lectura pública en `firestore.rules` para la colección `/config/app` para poder consultar la versión actual sin restricciones.
> 3. Crear el documento `/config/app` en tu consola de Firebase Firestore.

## Proposed Changes

### 1. Control de Ramas (Git)
* **Nuevo Branch:** Crear y cambiar a la rama `feature/updates` desde la rama `main` limpia.

### 2. Dependencias y Reglas de Base de Datos
* **Dependencia:** Añadir `url_launcher: ^6.2.5` a `pubspec.yaml` y ejecutar `flutter pub get`.
* **Reglas de Firestore:** Modificar `firestore.rules` para permitir que cualquier usuario lea la configuración de actualización de la app.

```javascript
    // Regla para consulta de versión
    match /config/app {
      allow read: if true;
    }
```

### 3. Configuración de Versión Local
#### [NEW] [app_config.dart](file:///c:/Users/angel/josue_tareas/lib/config/app_config.dart)
* Definir la versión constante de la aplicación en el código:
  ```dart
  const String kAppVersion = "1.0.0";
  ```

### 4. Lógica de Verificación de Versión en el Provider
#### [MODIFY] [auth_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/auth_provider.dart)
* Agregar variables de estado en `AuthProvider`:
  * `bool tieneActualizacion = false;`
  * `String urlDescargaActualizacion = '';`
* Crear el método `verificarActualizaciones()` que consulte el documento `/config/app` en Firestore.
* Comparar la versión de Firestore (`version_android`) con `kAppVersion`. Si la versión de Firestore es mayor (por ejemplo, `1.0.1`), marcar `tieneActualizacion = true` y guardar `urlDescargaActualizacion`.
* Llamar a `verificarActualizaciones()` dentro del método `inicializar()`.

### 5. Interfaz de Usuario para la Alerta (SeleccionPerfilScreen)
#### [MODIFY] [seleccion_perfil_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/seleccion_perfil_screen.dart)
* Si `authProv.tieneActualizacion` es verdadero, mostrar una tarjeta informativa visual arriba del título "¿Quién eres?".
* Al presionar la tarjeta, usar `url_launcher` para abrir la URL de descarga directa de GitHub en el navegador del dispositivo.

### 6. Integración del Instalador en "Compartir App"
#### [MODIFY] [admin_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/admin_screen.dart)
* Modificar el método `_compartirEnlaceApp` para incluir en el mensaje de invitación tanto el enlace de la versión Web actual como el enlace genérico de descarga para Android que apunta a la última versión publicada en GitHub:
  ```dart
  const String linkWeb = "https://misionkids.a8abhinav02.workers.dev/";
  const String linkAndroid = "https://github.com/a8abhinav02-lgtm/MisionKids/releases/latest";
  
  final String mensaje = 
      "¡Únete a nuestra familia en Mission Kids! 👥\n\n"
      "🌐 Entra al aplicativo web aquí:\n"
      "$linkWeb\n\n"
      "🤖 O descarga la App de Android aquí:\n"
      "$linkAndroid";
  ```
  *(Nota: El enlace `/releases/latest` redirige automáticamente a la última versión APK subida, sin necesidad de actualizar este enlace manualmente en cada versión).*

---

## Estructura del Documento en Firestore
Para que funcione la verificación de actualización, deberás crear en tu consola de Firebase:
* **Colección:** `config`
* **ID del Documento:** `app`
* **Campos:**
  * `version_android`: `1.0.0` (Tipo String, la versión más reciente del APK en producción)
  * `url_android`: `https://github.com/a8abhinav02-lgtm/MisionKids/releases/latest` (Tipo String, enlace de descarga directa del APK)

---

## Verification Plan

### Automated Tests
* Ejecutar `flutter analyze` para verificar que la sintaxis de `url_launcher` compile limpiamente y no haya advertencias.

### Manual Verification
* Configurar temporalmente en tu base de datos Firestore `version_android` en `1.0.5`.
* Abrir la aplicación y verificar que se muestre el aviso de actualización.
* Presionar el aviso y validar que abra la página de descarga.
* En el Panel de Padres, presionar "Compartir App" y verificar que el texto copiado contenga ambos enlaces actualizados.
