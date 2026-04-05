# Visita Guiada Final: Misión Switch 2 (Reglas y Bloqueos de Comportamiento) 🏁

Hemos finalizado la estructura de comportamiento de la aplicación. Tu proyecto ahora piensa como un "padre digital condicional", aplicando restricciones diseñadas para educar al niño.

---

## 🛠️ Reglas Aplicadas (Probadas y Activas)

### 1. Cuadro Horario ("Solo en el Presedente")
- El niño **ahora está restringido** al bloque horario del momento. 
- *Ejemplo:* Si son las 2:00 PM, el bloque activo es `"tarde"`. Las misiones de la mañana se ven grises y apagadas, y las de la noche aún no se encienden. Un niño no puede marcar como "hecha" su obligación de bañarse de la mañana a las 3:00 PM.
- El **Padre** no experimenta este bloqueo. El panel de administrador puede dar checks, revisar y sancionar a cualquier hora.

### 2. Bloqueador "Primero lo Obligatorio"
- Tu solicitud: *¿Si no hace las llaves, no puede ganar los puntos?* Sí.
- **Funcionamiento exacto:** El sistema vigila el estado de las tareas de la `mañana` y de la `tarde` actuales. Si el niño no ha presionado y enviado a revisión su tarea *Obligatoria*, ningún botón que otorgue puntos (🤑) funcionará en su panel.
- Una alarma roja saltará pidiéndole que atienda su responsabilidad.

---

## 🎨 Resumen del Flujo UX Actual

1. **Niño**:
    * Intenta pulsar misión de puntos **sin** haber completado obligatoria -> ⚠️ *Alerta roja, denegado.*
    * Pulsa misión obligatoria (Llave 🔑) de su bloque actual -> 🎉 *Confeti, SnackBar verde de envío, Reloj Fijo.*
    * Pulsa misión de puntos -> 🎉 *Confeti, enviado con éxito.*
2. **Padre**: 
    * Abre el panel Admin -> Ignora restricciones de tiempo -> Revisa las acciones del niño en "Aprobaciones" -> Pulsa Check para validar.

---

## ☁️ Repositorio y Entorno

Todo el código fuente cuenta con respaldo y sincronización:
- **Git** rama: `feature/refactor-multiusuario`.

**Con todo esto documentado, la fase oficial de BETA y TESTEO en casa está declarada como abierta.**
