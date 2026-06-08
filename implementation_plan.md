# Plan de Implementación: Cuentas Compartidas (Co-parenting) 👥

Este plan detalla el rediseño del backend de base de datos (Firestore) y la lógica de autenticación en la app para permitir que múltiples cuentas de padres (correos independientes) gestionen la misma cuenta familiar en tiempo real.

## Recomendación de Rama (Git)

> [!IMPORTANT]
> **Es sumamente necesario crear una nueva rama de Git** (ej. `feature/cuentas-compartidas`) partiendo del estado actual. 
> Dado que realizaremos una reestructuración de la base de datos (esquema) y alteraremos el flujo de sincronización de datos de primer plano, separar este trabajo en una rama limpia facilitará el testeo, aislará riesgos y permitirá hacer rollback en caso de cualquier inconveniente sin afectar el código estable de la rama `feature/desbloqueo-registro`.

## User Review Required

> [!WARNING]
> **Migración del Esquema y Reglas de Firebase:**
> 1. **Migración Silenciosa:** Para no perder los datos de familias existentes, el código del `AuthProvider` implementará un disparador de compatibilidad: si detecta el esquema antiguo en Firestore (`/familias/{uid}`), migrará automáticamente los datos al nuevo formato de forma transparente para el usuario.
> 2. **Cambio de Reglas en Firebase Console:** Este cambio requiere que actualices las reglas de seguridad en la consola web de Firestore para permitir que múltiples UIDs accedan a la misma colección familiar.

---

## Proposed Changes

### 1. Esquema de Datos y Seguridad

#### [MODIFY] Reglas de Seguridad de Firestore (En la consola web de Firebase)
*   Reemplazar las reglas actuales por unas basadas en pertenencia al arreglo de `padres` en el documento familiar:
    ```javascript
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /usuarios/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        match /familias/{familiaId}/{document=**} {
          allow read, write: if request.auth != null && 
            request.auth.uid in get(/databases/$(database)/documents/familias/{familiaId}).data.padres;
        }
      }
    }
    ```

---

### 2. Autenticación y Sincronización

#### [MODIFY] [auth_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/auth_provider.dart)
*   **Campos Nuevos:**
    *   `String _familiaId = '';`
    *   `String get familiaId => _familiaId;`
*   **Lógica de Login (`loginPadre`):**
    *   Iniciar sesión con Firebase Auth.
    *   Consultar la colección `/usuarios/{uid}` para extraer su `familiaId`.
    *   Si el usuario no tiene documento en `/usuarios/{uid}` pero sí existe la familia clásica `/familias/{uid}`, ejecutar la **migración silenciosa**:
        1. Copiar los datos de `/familias/{uid}` a `/familias/FAM_{uid}` (nuevo ID).
        2. Mapear en `/usuarios/{uid}` el campo `familiaId: 'FAM_{uid}'`.
        3. Migrar las subcolecciones `/perfiles` y `/tareas` al nuevo ID.
    *   Asignar `_familiaId` localmente y guardarlo en Hive para persistencia offline.
*   **Lógica de Registro (`registrarAdmin`):**
    *   Crear el usuario en Firebase Auth.
    *   Generar un ID de familia único legible (ej. `MK-` + 6 dígitos aleatorios).
    *   Crear documento `/usuarios/{uid}` con `{ 'email': email, 'familiaId': familiaId }`.
    *   Crear el documento familiar `/familias/{familiaId}` con `{ 'pin_padre': pin, 'email_padre': email, 'padres': [uid] }`.
*   **Lógica para Unirse (`unirseAFamilia`):**
    *   `Future<void> unirseAFamilia(String codigoFamilia)`:
        1. Verificar que el `codigoFamilia` exista en `/familias/`.
        2. Actualizar `/usuarios/{uid}` con `familiaId: codigoFamilia`.
        3. Añadir el `uid` del usuario al arreglo de `padres` en `/familias/{codigoFamilia}` mediante `FieldValue.arrayUnion([uid])`.

#### [MODIFY] [perfiles_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/perfiles_provider.dart) y [tarea_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/tarea_provider.dart)
*   Reemplazar las llamadas que usaban `_uid` para escuchar en Firestore por `_familiaId` expuesto por `AuthProvider`:
    ```dart
    // Ejemplo en _escucharTareas():
    _db.collection('familias').doc(_familiaId).collection('tareas').snapshots();
    ```

---

### 3. Modificaciones en la Interfaz (UI)

#### [MODIFY] [setup_familia_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/setup_familia_screen.dart)
*   Añadir una tercera opción en la bienvenida: **"Unirme a Familia Compartida 👥"**.
*   Si se selecciona:
    *   Pedir login de correo y contraseña (o registro rápido).
    *   Solicitar que ingrese el código de familia (ej. `MK-102938`).
    *   Ejecutar `unirseAFamilia(codigo)` y redireccionar a la selección de perfiles.

#### [MODIFY] [admin_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/admin_screen.dart)
*   En la Zona de Padres, en la tarjeta de resumen o una sección dedicada a la configuración, mostrar de forma prominente:
    *   **Código de Familia Compartido:** `MK-XXXXXX` (con botón de "Copiar al portapapeles").
    *   **Miembros Autorizados:** Listar los correos electrónicos de los padres que tienen acceso a la familia.

---

## Plan de Verificación

### Pruebas de Flujo Completo
1.  **Registro y Generación:** Crear una cuenta nueva y verificar que se genera un código de familia aleatorio y el usuario se asocia correctamente en Firestore `/usuarios` y `/familias`.
2.  **Invitación y Sincronización:**
    *   En el Dispositivo A (Papá), ver el código de familia.
    *   En el Dispositivo B (Mamá), registrarse y elegir "Unirse a Familia", ingresando el código.
    *   Comprobar que en el Dispositivo B se cargan instantáneamente los perfiles e hijos creados en el Dispositivo A.
3.  **Acción Cruzada:** Crear una misión en el Dispositivo A y verificar que aparezca en el Dispositivo B en tiempo real.
4.  **Migración Retrocompatible:** Iniciar sesión con un usuario preexistente (que solo tenía datos en `/familias/{uid}`) y comprobar que entra sin perder perfiles, saldo ni historial, y que sus colecciones han sido movidas exitosamente en segundo plano.
