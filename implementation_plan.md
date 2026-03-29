# Refactorización a Soporte Multiusuario (Local)

El objetivo de esta fase es reestructurar la aplicación para hacerla sostenible (modularizando `main.dart`) y preparar la lógica para soportar **múltiples perfiles de niños**, permitiendo que cada uno tenga su propio saldo individual, historial de misiones y _tema personalizado_ guardado todo en local (Hive). Como acordamos, la integración con Firebase quedará aplazada hasta validar este modelo.

## User Review Required

> [!WARNING]
> El cambio al modelo multiusuario en local requerirá una **nueva definición de las cajas de Hive**. Para evitar conflictos de lectura, la mejor opción es comenzar con una base de datos limpia para los nuevos perfiles (borraremos la data de prueba actual `caja_tareas_v5` y `caja_config`). Necesito tu confirmación antes de proceder, para no borrar información de uso real si la hubiera.

> [!TIP]
> Respecto a la personalización de temas ("Niño o Niña"), usaremos paletas de colores y fuentes guardadas en la configuración de cada perfil, de modo que cada niño tenga su experiencia única (por ejemplo: colores azules/verdes, morados/naranjas, tema "espacial" o tema "aventura").

## Proposed Changes

La reestructuración abarca la mayoría de los archivos actuales. Separaremos Responsabilidades (Modelos, Proveedores de estado y UI).

---

### UI (Pantallas y Widgets)

#### [DELETE] [main.dart](file:///c:/Users/angel/josue_tareas/lib/main.dart) 
(Será reemplazado por un archivo `main.dart` muy pequeño únicamente para inicializar el estado global, Hive, y las rutas).

#### [NEW] [lib/ui/screens/seleccion_perfil_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/seleccion_perfil_screen.dart)
Pantalla inicial tipo "Netflix" para elegir quién va a usar la app: Muestra un avatar para Josué, otro para su herman@, y un candado para "Padres".

#### [NEW] [lib/ui/screens/home_nino_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/home_nino_screen.dart)
El dashboard del niño, que reacciona al `AppTheme` asociado a su perfil específico.

#### [NEW] [lib/ui/themes/app_theme.dart](file:///c:/Users/angel/josue_tareas/lib/ui/themes/app_theme.dart)
Contendrá la definición centralizada de los temas. Propongo de inicio esquemas seleccionables desde la zona de padres cuando se crea el perfil.

---

### Modelos de Datos (Hive)

#### [NEW] [lib/models/perfil_model.dart](file:///c:/Users/angel/josue_tareas/lib/models/perfil_model.dart)
Modelo exclusivo para manejar un perfil (`id`, `nombre`, `avatarIcono`, `saldoActual`, `metaActual`, `temaPreferido`).

#### [MODIFY] [lib/models/tarea_model.dart](file:///c:/Users/angel/josue_tareas/lib/tarea_model.dart)
Agregaremos un campo `perfilId` u organizaremos las tareas dentro del perfil, para que las de Josué no se mezclen con las de otro niño.

---

### Lógica (Proveedores)

#### [NEW] [lib/providers/perfiles_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/perfiles_provider.dart)
Gestionará el CRUD de perfiles y la persistencia del perfil "Abierto actualmente".

#### [MODIFY] [lib/providers/tarea_provider.dart](file:///c:/Users/angel/josue_tareas/lib/tarea_provider.dart)
Se extraerá de él toda la lógica financiera (`totalDinero`, `metaAhorro`) y se le pasará al `perfil_provider.dart`. El provider de tareas solo manejará Misiones, filtrándolas por `perfilId`.

## Open Questions

1. **Borrado de Datos:** ¿Confirmas que estás de acuerdo con que los datos locales de prueba (tareas de `"josue"`) se borren o ignoren para poder migrar limpio la estructura de base de datos a múltiples hijos?
2. **Temas / Avatares:** Al crear a un niño, ¿te gustaría que el padre seleccione simplemente entre opciones de colores (Azul, Rosa, Verde, etc.) o entre "Temáticas/Avatares" (Ej: Astronauta, Ninja, Princesa, Deportes)? ¿O simplemente Color de Fondo y Nombre?

## Verification Plan

### Manual Verification
1. La aplicación inicia en la pantalla "Seleccionar Perfil".
2. Sin perfiles, obligará a configurar al *Padre* (PIN de Seguridad).
3. Entrar a Zona Admin y cargar 2 perfiles de niños (con temas de color distintos).
4. Ver que en "Seleccionar Perfil" aparecen ambos.
5. Si entramos al Perfil 1, el fondo será de su color y tendrá sus propias tareas. Al ganar puntos, se incrementa el saldo del Perfil 1.
6. Si cambiamos al Perfil 2, este verá un saldo $0 inicial y un color de entorno completamente distinto.
