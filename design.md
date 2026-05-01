# Manual de Lineamientos de Diseño: Mission Kids 🚀

Este documento define la identidad visual y los estándares de UX/UI para asegurar la consistencia en el desarrollo futuro de **Mission Kids**.

---

## 🎨 1. Sistema de Color

### Colores de Marca (Multi-temática)
La aplicación utiliza un sistema dinámico basado en la temática del niño. Los colores principales se definen en `AppTheme.colors`:
- **Base Principal**: Índigo (`Colors.indigo`) para interfaces administrativas.
- **Paleta de Aventura**: Azul, Rojo, Verde, Morado, Naranja, Rosa, Amarillo.

### Colores Funcionales
- **Fondo General**: `#F0F4F8` (Azul grisáceo muy claro) para dar descanso visual.
- **Superficies (Cards)**: Blanco puro `#FFFFFF`.
- **Obligatoriedad (Llaves)**: Rojo brillante para alertas y estados de "Llave 🔑".
- **Recompensas (Puntos)**: Ámbar/Dorado para monedas y logros 💰.
- **Atenuación (Completados)**: En lugar de usar opacidad que rompe el contraste WCAG, usar grises de alto contraste (ej: `AppTheme.accessibleGrey` para fondos y `AppTheme.highContrastGrey` para textos e iconos).

---

## 📐 2. Geometría y Espaciado

### Bordes Redondeados (Border Radius)
Buscamos una interfaz "suave" y amigable para niños:
- **Pantallas y Contenedores Grandes**: `20px` a `28px`.
- **Botones y Tarjetas de Tareas**: `16px`.
- **Campos de Texto (Inputs)**: `14px`.
- **Iconos de Avatar**: Siempre circulares o dentro de contenedores de `12px` de radio.

### Elevación y Sombras
- **Sombras Suaves**: `BoxShadow` con color `black.withValues(alpha: 0.04)` y blur de `8px`.
- **Botones**: Elevación `4` con sombra del mismo color del botón (glow).

---

## 🔠 3. Tipografía

- **Fuente Principal**: `Roboto` (Sans Serif).
- **Jerarquía**:
  - **Títulos de Pantalla**: `34px`, Weight `800`.
  - **Subtítulos/Nombres**: `22px`, Weight `Bold`.
  - **Cuerpo de Texto**: `15px` - `16px`, Weight `W600`.
  - **Etiquetas de Agrupación**: `13px`, Uppercase, Letter Spacing `1.2`.
- **Escalabilidad**: Evitar el uso de alturas fijas (fixed `height`) en contenedores con texto para permitir que la fuente crezca según las preferencias de accesibilidad del dispositivo.

---

## ♿ 4. Accesibilidad (Estándar WCAG AA)

Para asegurar que Mission Kids sea inclusiva para todas las familias, los siguientes lineamientos son de uso obligatorio:

1. **Objetivos de Toque**: Todo elemento interactivo (`ElevatedButton`, `InkWell`, `ActionChip`, etc.) debe tener un tamaño mínimo de **48dp** (ancho y alto) para facilitar la motricidad fina.
2. **Etiquetado Semántico (Natural)**:
   - Todo widget interactivo debe estar envuelto en un widget `Semantics`.
   - Evitar lenguajes técnicos. Usar narrativas amigables, por ejemplo:
     - ❌ `label: "Botón editar"`
     - ✅ `label: "Misión: Cepillarse los dientes. Toca para ver opciones de edición."`
3. **Contraste de Color**: Mantener siempre un ratio de contraste de al menos 4.5:1. Usar `AppTheme.highContrastGrey` para elementos desactivados o completados en lugar de opacidades (`Opacity(0.4)`), ya que las opacidades dificultan la lectura.

---

## 🎢 5. Componentes y Estados

### Tareas (Misiones)
1. **Agrupamiento**: Las tareas deben agruparse por similitud de nombre.
2. **Orden Cronológico**: Siempre mostrar el orden `Mañana -> Tarde -> Noche`.
3. **Estado "Aprobada"**:
   - Cambiar el fondo de la tarjeta a `AppTheme.accessibleGrey`.
   - Cambiar el color del texto e icono a `AppTheme.highContrastGrey`.
   - Reemplazar botones de acción por un icono de `Icons.check_circle` en verde.

### Feedback Visual y Sonoro
- **Animaciones**: Usar `animate_do` para entradas (FadeInDown/FadeInUp).
- **Celebración**: Disparar `ConfettiWidget` al completar misiones clave.
- **Alertas**: Sonidos de 10-15 segundos para recordatorios de tareas pendientes.

---

## 📱 6. UX para Niños vs Padres

- **Perfil Niño**: Iconografía grande, colores vibrantes y mensajes motivacionales. Menos texto, más iconos.
- **Perfil Padre**: Listas organizadas, control total (Admin), estados claros de aprobación y gestión de saldos.

---

## 🛠️ 7. Uso de Gradiantes
Para encabezados y tarjetas de perfil, usar siempre `AppTheme.getGradient(colorKey)`:
- **Inicio**: `shade700`.
- **Fin**: `shade400`.
- **Dirección**: `Alignment.topLeft` a `Alignment.bottomRight`.
