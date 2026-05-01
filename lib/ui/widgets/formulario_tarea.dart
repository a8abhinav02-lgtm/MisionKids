import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/tarea_model.dart';
import '../../providers/tarea_provider.dart';

class FormularioTarea extends StatefulWidget {
  final Tarea? tarea;
  final String perfilId;

  const FormularioTarea({super.key, this.tarea, required this.perfilId});

  @override
  State<FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<FormularioTarea> {
  final _nombreCtrl = TextEditingController();
  final _puntosCtrl = TextEditingController();
  String _bloque = 'manana';
  bool _esObligatoria = false;
  IconData _icono = Icons.star;
  String _tipoRecurrencia = 'diaria';
  List<int> _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];
  DateTime? _fechaFija;

  final List<Map<String, dynamic>> _plantillas = [
    {"nombre": "Cepillarse Dientes", "puntos": "0", "obligatoria": true, "icono": Icons.cleaning_services, "bloque": "manana", "recurrencia": "diaria"},
    {"nombre": "Bañarse", "puntos": "50", "obligatoria": true, "icono": Icons.bathtub, "bloque": "manana", "recurrencia": "diaria"},
    {"nombre": "Hacer la Cama", "puntos": "100", "obligatoria": true, "icono": Icons.bed, "bloque": "manana", "recurrencia": "diaria"},
    {"nombre": "Hacer Tareas Escuela", "puntos": "500", "obligatoria": true, "icono": Icons.school, "bloque": "tarde", "recurrencia": "semanal"},
    {"nombre": "Recoger Juguetes", "puntos": "200", "obligatoria": false, "icono": Icons.toys, "bloque": "noche", "recurrencia": "diaria"},
    {"nombre": "Alistar Maleta", "puntos": "100", "obligatoria": true, "icono": Icons.backpack, "bloque": "noche", "recurrencia": "semanal"},
    {"nombre": "Practicar Deporte", "puntos": "300", "obligatoria": false, "icono": Icons.directions_run, "bloque": "tarde", "recurrencia": "semanal"},
  ];

  final List<IconData> _iconosDisponibles = [Icons.cleaning_services, Icons.checkroom, Icons.local_dining, Icons.piano, Icons.menu_book, Icons.backpack, Icons.bed, Icons.school, Icons.pets, Icons.sports_soccer, Icons.computer, Icons.star, Icons.directions_bike, Icons.pool, Icons.bathtub, Icons.toys, Icons.roller_skating, Icons.directions_run];

  String _diaLetra(int dia) {
    return ['L','M','X','J','V','S','D'][dia - 1];
  }

  @override
  void initState() {
    super.initState();
    if (widget.tarea != null) {
      _nombreCtrl.text = widget.tarea!.nombre;
      _puntosCtrl.text = widget.tarea!.puntos.toString();
      _bloque = widget.tarea!.bloque;
      _esObligatoria = widget.tarea!.esObligatoria;
      _icono = widget.tarea!.icono;
      _tipoRecurrencia = widget.tarea!.tipoRecurrencia;
      _diasSeleccionados = List.from(widget.tarea!.diasSemana);
      _fechaFija = widget.tarea!.fechaEspecifica;
    }
  }

  void _cargarPlantilla(Map<String, dynamic> plantilla) {
    setState(() {
      _nombreCtrl.text = plantilla["nombre"];
      _puntosCtrl.text = plantilla["puntos"];
      _esObligatoria = plantilla["obligatoria"];
      _icono = plantilla["icono"];
      _bloque = plantilla["bloque"];
      _tipoRecurrencia = plantilla["recurrencia"];
      if (plantilla["nombre"].toString().contains("Escuela") || plantilla["nombre"].toString().contains("Maleta")) {
        _diasSeleccionados = [1, 2, 3, 4, 5];
        _tipoRecurrencia = 'semanal';
      } else {
        _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];
        _tipoRecurrencia = 'diaria';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plantilla cargada."), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context, listen: false);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Text(widget.tarea == null ? "Nueva Misión" : "Editar Misión", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)), 
                Semantics(
                  label: "Cerrar formulario",
                  button: true,
                  child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                )
              ]
            ),
            if (widget.tarea == null) ...[
              const SizedBox(height: 10), const Text("🚀 Rutinas Rápidas:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, 
                child: Row(
                  children: _plantillas.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8.0), 
                    child: Semantics(
                      label: "Usar plantilla rápida: ${p['nombre']}",
                      button: true,
                      child: ActionChip(
                        avatar: Icon(p['icono'], size: 18, color: Colors.white), 
                        label: Text(p['nombre']), 
                        backgroundColor: Colors.indigo.shade300, 
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 13), 
                        onPressed: () => _cargarPlantilla(p)
                      ),
                    )
                  )).toList()
                )
              ),
              const Divider(height: 25),
            ],
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Nombre Tarea", prefixIcon: Icon(Icons.task_alt))),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: TextField(controller: _puntosCtrl, decoration: const InputDecoration(labelText: "Puntos", prefixIcon: Icon(Icons.monetization_on)), keyboardType: TextInputType.number)), const SizedBox(width: 10), Expanded(child: Container(decoration: BoxDecoration(color: _esObligatoria ? Colors.red[50] : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: _esObligatoria ? Border.all(color: Colors.red.shade300) : null), child: SwitchListTile(title: const Text("Llave 🔑", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: const Text("Obligatoria", style: TextStyle(fontSize: 10)), value: _esObligatoria, activeThumbColor: Colors.red, dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10), onChanged: (val) => setState(() => _esObligatoria = val))))]),
            const SizedBox(height: 15),
            const Text("Frecuencia:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0, 
              runSpacing: 8.0,
              children: [
                Semantics(
                  label: "Frecuencia Diaria",
                  selected: _tipoRecurrencia == 'diaria',
                  child: ChoiceChip(label: const Text("Diaria"), selected: _tipoRecurrencia == 'diaria', onSelected: (val) => setState(() => _tipoRecurrencia = 'diaria'))
                ),
                Semantics(
                  label: "Frecuencia: Días Específicos",
                  selected: _tipoRecurrencia == 'semanal',
                  child: ChoiceChip(label: const Text("Días Específicos"), selected: _tipoRecurrencia == 'semanal', onSelected: (val) => setState(() => _tipoRecurrencia = 'semanal'))
                ),
                Semantics(
                  label: "Reto Único en fecha fija",
                  selected: _tipoRecurrencia == 'fecha_fija',
                  child: ChoiceChip(label: const Text("Reto Único (Fecha)"), selected: _tipoRecurrencia == 'fecha_fija', onSelected: (val) => setState(() => _tipoRecurrencia = 'fecha_fija'))
                ),
              ]
            ),
            if (_tipoRecurrencia == 'semanal') 
              Wrap(
                spacing: 8, 
                children: [
                  for (var i = 1; i <= 7; i++) 
                    Semantics(
                      label: "Día: ${_diaLetra(i)}",
                      selected: _diasSeleccionados.contains(i),
                      child: FilterChip(
                        label: Text(_diaLetra(i)), 
                        selected: _diasSeleccionados.contains(i), 
                        onSelected: (selected) { setState(() { if (selected) { _diasSeleccionados.add(i); } else { _diasSeleccionados.remove(i); } }); }
                      ),
                    )
                ]
              ),
            if (_tipoRecurrencia == 'fecha_fija') 
              Semantics(
                label: "Seleccionar fecha del calendario",
                child: ListTile(
                  title: Text(_fechaFija == null ? "Seleccionar Fecha" : DateFormat('dd/MM/yyyy').format(_fechaFija!)), 
                  leading: const Icon(Icons.calendar_today, color: Colors.indigo), 
                  tileColor: Colors.grey[200], 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                  onTap: () async { final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030)); if (picked != null) setState(() => _fechaFija = picked); }
                ),
              ),
            const SizedBox(height: 10),
            DropdownButton<String>(value: _bloque, items: const [DropdownMenuItem(value: 'manana', child: Text("🌞 Mañana")), DropdownMenuItem(value: 'tarde', child: Text("⛅ Tarde")), DropdownMenuItem(value: 'noche', child: Text("🌙 Noche"))], onChanged: (val) => setState(() => _bloque = val!)),
            const SizedBox(height: 10),
            SizedBox(
              height: 60, 
              child: ListView(
                scrollDirection: Axis.horizontal, 
                children: _iconosDisponibles.map((icon) => Semantics(
                  label: "Elegir icono para la misión",
                  button: true,
                  child: GestureDetector(
                    onTap: () => setState(() => _icono = icon), 
                    child: Container(
                      margin: const EdgeInsets.only(right: 12), 
                      padding: const EdgeInsets.all(14), 
                      decoration: BoxDecoration(color: _icono == icon ? Colors.indigo : Colors.grey[200], shape: BoxShape.circle), 
                      child: Icon(icon, color: _icono == icon ? Colors.white : Colors.black54, size: 28),
                    )
                  ),
                )).toList()
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () {
              if (_nombreCtrl.text.isEmpty) return;
              if (_tipoRecurrencia == 'fecha_fija' && _fechaFija == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona una fecha para el reto"))); return; }
              
              if (widget.tarea == null) {
                proveedor.agregarTarea(nombre: _nombreCtrl.text, puntos: int.tryParse(_puntosCtrl.text) ?? 0, obligatoria: _esObligatoria, icon: _icono, bloque: _bloque, tipoRecurrencia: _tipoRecurrencia, diasSemana: _diasSeleccionados, fechaEspecifica: _fechaFija, perfilId: widget.perfilId);
              } else {
                proveedor.editarTarea(widget.tarea!, nombre: _nombreCtrl.text, puntos: int.tryParse(_puntosCtrl.text) ?? 0, obligatoria: _esObligatoria, icon: _icono, bloque: _bloque, tipoRecurrencia: _tipoRecurrencia, diasSemana: _diasSeleccionados, fechaEspecifica: _fechaFija);
              }
              Navigator.pop(context);
            }, child: Text(widget.tarea == null ? "CREAR MISIÓN" : "GUARDAR CAMBIOS")),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
