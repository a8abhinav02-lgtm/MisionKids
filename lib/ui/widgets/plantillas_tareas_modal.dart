import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarea_model.dart';
import '../../providers/tarea_provider.dart';
import 'formulario_tarea.dart';

class PlantillaTareaItem {
  final String nombre;
  final int puntos;
  final bool esObligatoria;
  final IconData icono;
  final String bloque; // 'manana', 'tarde', 'noche'
  final String categoria; // 'higiene', 'orden', 'estudio', 'salud'
  final String descripcion;

  const PlantillaTareaItem({
    required this.nombre,
    required this.puntos,
    required this.esObligatoria,
    required this.icono,
    required this.bloque,
    required this.categoria,
    required this.descripcion,
  });
}

class PlantillasTareasModal extends StatefulWidget {
  final String perfilId;
  final String nombreHijo;

  const PlantillasTareasModal({
    super.key,
    required this.perfilId,
    required this.nombreHijo,
  });

  static const List<PlantillaTareaItem> plantillasDisponibles = [
    PlantillaTareaItem(
      nombre: "Tender la Cama",
      puntos: 5,
      esObligatoria: true,
      icono: Icons.bed,
      bloque: "manana",
      categoria: "orden",
      descripcion: "Dejar la cama ordenada al levantarse.",
    ),
    PlantillaTareaItem(
      nombre: "Lavarse los Dientes (2 min)",
      puntos: 5,
      esObligatoria: true,
      icono: Icons.cleaning_services,
      bloque: "manana",
      categoria: "higiene",
      descripcion: "Cepillarse después del desayuno o antes de dormir.",
    ),
    PlantillaTareaItem(
      nombre: "Bañarse y Vestirse",
      puntos: 10,
      esObligatoria: true,
      icono: Icons.bathtub,
      bloque: "manana",
      categoria: "higiene",
      descripcion: "Ducha limpia y ropa limpia lista para el día.",
    ),
    PlantillaTareaItem(
      nombre: "Tomar Desayuno Nutritivo",
      puntos: 5,
      esObligatoria: false,
      icono: Icons.local_dining,
      bloque: "manana",
      categoria: "salud",
      descripcion: "Comer todo el desayuno sin distracciones.",
    ),
    PlantillaTareaItem(
      nombre: "Hacer Deberes Escolares",
      puntos: 15,
      esObligatoria: true,
      icono: Icons.school,
      bloque: "tarde",
      categoria: "estudio",
      descripcion: "Completar tareas y estudiar las materias del cole.",
    ),
    PlantillaTareaItem(
      nombre: "Lectura de 15 Minutos",
      puntos: 10,
      esObligatoria: false,
      icono: Icons.menu_book,
      bloque: "tarde",
      categoria: "estudio",
      descripcion: "Leer un libro o cuento favorito.",
    ),
    PlantillaTareaItem(
      nombre: "Comer Frutas y Verduras",
      puntos: 5,
      esObligatoria: false,
      icono: Icons.apple,
      bloque: "tarde",
      categoria: "salud",
      descripcion: "Incluir porción de fruta o verdura en las comidas.",
    ),
    PlantillaTareaItem(
      nombre: "Practicar Deporte / Ejercicio",
      puntos: 10,
      esObligatoria: false,
      icono: Icons.sports_soccer,
      bloque: "tarde",
      categoria: "salud",
      descripcion: "Moverse, jugar al aire libre o hacer actividad física.",
    ),
    PlantillaTareaItem(
      nombre: "Recoger Juguetes y Cuarto",
      puntos: 10,
      esObligatoria: true,
      icono: Icons.toys,
      bloque: "noche",
      categoria: "orden",
      descripcion: "Guardar juguetes en su lugar antes de cenar.",
    ),
    PlantillaTareaItem(
      nombre: "Alistar Mochila Escolar",
      puntos: 5,
      esObligatoria: true,
      icono: Icons.backpack,
      bloque: "noche",
      categoria: "estudio",
      descripcion: "Cuadernos y estuche guardados para el día siguiente.",
    ),
    PlantillaTareaItem(
      nombre: "Ponerse Pijama y Dormir a Tiempo",
      puntos: 5,
      esObligatoria: true,
      icono: Icons.bedtime,
      bloque: "noche",
      categoria: "higiene",
      descripcion: "Acostarse a la hora acordada sin pantallas.",
    ),
    PlantillaTareaItem(
      nombre: "Alimentar Mascota / Regar Planta",
      puntos: 5,
      esObligatoria: false,
      icono: Icons.pets,
      bloque: "tarde",
      categoria: "orden",
      descripcion: "Cuidar a un ser vivo de la casa con amor.",
    ),
  ];

  @override
  State<PlantillasTareasModal> createState() => _PlantillasTareasModalState();
}

class _PlantillasTareasModalState extends State<PlantillasTareasModal> {
  String _categoriaSeleccionada = 'todas';

  Color _colorBloque(String bloque) {
    switch (bloque) {
      case 'manana':
        return Colors.amber.shade700;
      case 'tarde':
        return Colors.orange.shade700;
      case 'noche':
        return Colors.indigo.shade600;
      default:
        return Colors.blue;
    }
  }

  String _labelBloque(String bloque) {
    switch (bloque) {
      case 'manana':
        return '☀️ Mañana';
      case 'tarde':
        return '🌤️ Tarde';
      case 'noche':
        return '🌙 Noche';
      default:
        return bloque;
    }
  }

  Future<void> _asignarConUnToque(BuildContext context, PlantillaTareaItem plantilla) async {
    final tareaProv = Provider.of<TareaProvider>(context, listen: false);
    
    await tareaProv.agregarTarea(
      nombre: plantilla.nombre,
      puntos: plantilla.puntos,
      obligatoria: plantilla.esObligatoria,
      icon: plantilla.icono,
      bloque: plantilla.bloque,
      tipoRecurrencia: 'diaria',
      diasSemana: const [1, 2, 3, 4, 5, 6, 7],
      perfilId: widget.perfilId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "¡Misión '${plantilla.nombre}' asignada a ${widget.nombreHijo}!",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _personalizarPlantilla(BuildContext context, PlantillaTareaItem plantilla) {
    Navigator.pop(context);
    final tareaBorrador = Tarea(
      nombre: plantilla.nombre,
      puntos: plantilla.puntos,
      esObligatoria: plantilla.esObligatoria,
      iconoCodePoint: plantilla.icono.codePoint,
      bloque: plantilla.bloque,
      perfilId: widget.perfilId,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => FormularioTarea(
        tarea: tareaBorrador,
        perfilId: widget.perfilId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _categoriaSeleccionada == 'todas'
        ? PlantillasTareasModal.plantillasDisponibles
        : PlantillasTareasModal.plantillasDisponibles.where((p) => p.categoria == _categoriaSeleccionada).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Tirador superior
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Cabecera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Plantillas Rápidas (1 Toque)",
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Asigna hábitos clave a ${widget.nombreHijo} al instante",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Chips de categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _chipCategoria('todas', '🌟 Todas (${PlantillasTareasModal.plantillasDisponibles.length})'),
                const SizedBox(width: 8),
                _chipCategoria('higiene', '🧼 Higiene & Salud'),
                const SizedBox(width: 8),
                _chipCategoria('orden', '🛏️ Orden & Rutina'),
                const SizedBox(width: 8),
                _chipCategoria('estudio', '📚 Estudio & Mente'),
                const SizedBox(width: 8),
                _chipCategoria('salud', '🍎 Alimentación & Deporte'),
              ],
            ),
          ),

          // Lista de plantillas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plantilla = filtradas[index];
                final colorB = _colorBloque(plantilla.bloque);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono con fondo colorido
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorB.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(plantilla.icono, color: colorB, size: 26),
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plantilla.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plantilla.descripcion,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                // Badge bloque
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colorB.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _labelBloque(plantilla.bloque),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorB),
                                  ),
                                ),
                                // Badge puntos
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "💰 +${plantilla.puntos} pts",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                  ),
                                ),
                                if (plantilla.esObligatoria)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Obligatoria",
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Botones Asignar / Personalizar
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _asignarConUnToque(context, plantilla),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 4),
                                Text("Asignar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _personalizarPlantilla(context, plantilla),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                "Editar ✏️",
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipCategoria(String key, String label) {
    final seleccionada = _categoriaSeleccionada == key;
    return ChoiceChip(
      label: Text(label),
      selected: seleccionada,
      onSelected: (val) {
        if (val) setState(() => _categoriaSeleccionada = key);
      },
      selectedColor: Colors.amber.shade100,
      labelStyle: TextStyle(
        color: seleccionada ? Colors.amber.shade900 : Colors.grey.shade700,
        fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: seleccionada ? Colors.amber.shade400 : Colors.grey.shade300,
      ),
      showCheckmark: false,
    );
  }
}
