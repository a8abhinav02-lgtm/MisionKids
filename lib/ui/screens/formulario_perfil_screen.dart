import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/perfiles_provider.dart';
import '../themes/app_theme.dart';

class FormularioPerfilScreen extends StatefulWidget {
  const FormularioPerfilScreen({super.key});

  @override
  State<FormularioPerfilScreen> createState() => _FormularioPerfilScreenState();
}

class _FormularioPerfilScreenState extends State<FormularioPerfilScreen> {
  final _nombreHijoCtrl = TextEditingController();
  String _colorSeleccionado = 'azul';
  String _avatarSeleccionado = 'astronauta';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Nuevo Hijo")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Perfil del Nuevo Hijo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  controller: _nombreHijoCtrl, 
                  textCapitalization: TextCapitalization.words, 
                  decoration: const InputDecoration(labelText: "Nombre del Hijo/a")
                ),
                const SizedBox(height: 20),
                
                const Text("Selecciona su Avatar:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: AppTheme.avatares.keys.map((k) {
                    return ChoiceChip(
                      label: Icon(AppTheme.avatares[k], size: 24),
                      selected: _avatarSeleccionado == k,
                      onSelected: (val) => setState(() => _avatarSeleccionado = k),
                    );
                  }).toList()
                ),
                
                const SizedBox(height: 20),
                const Text("Selecciona su Color de Tema Preferido:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 15,
                  children: AppTheme.colors.keys.map((c) {
                    return GestureDetector(
                      onTap: () => setState(() => _colorSeleccionado = c),
                      child: Container(
                        width: 40, height: 40,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.colors[c],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _colorSeleccionado == c ? Colors.black : Colors.transparent,
                            width: 3
                          )
                        ),
                      ),
                    );
                  }).toList()
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, 
                    foregroundColor: Colors.white, 
                    minimumSize: const Size(double.infinity, 50)
                  ),
                  onPressed: () async {
                    if (_nombreHijoCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Revisa el nombre"))
                      );
                      return;
                    }
                    final perfilProv = Provider.of<PerfilesProvider>(context, listen: false);
                    
                    await perfilProv.crearPerfil(
                      nombre: _nombreHijoCtrl.text,
                      tematica: _avatarSeleccionado,
                      colorPrimario: _colorSeleccionado
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Hijo agregado correctamente."))
                      );
                    }
                  },
                  child: const Text("GUARDAR PERFIL"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
