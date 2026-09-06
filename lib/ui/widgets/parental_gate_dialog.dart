import 'dart:math';
import 'package:flutter/material.dart';

class ParentalGateDialog extends StatefulWidget {
  final VoidCallback onExito;

  const ParentalGateDialog({super.key, required this.onExito});

  static Future<void> verificar(BuildContext context, {required VoidCallback onExito}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParentalGateDialog(onExito: onExito),
    );
  }

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int _num1;
  late int _num2;
  late int _resultadoEsperado;
  final _respuestaCtrl = TextEditingController();
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _generarReto();
  }

  void _generarReto() {
    final random = Random();
    _num1 = 3 + random.nextInt(7); // 3 a 9
    _num2 = 3 + random.nextInt(7); // 3 a 9
    _resultadoEsperado = _num1 * _num2;
    _respuestaCtrl.clear();
  }

  void _validarRespuesta() {
    final respuesta = int.tryParse(_respuestaCtrl.text.trim());
    if (respuesta == _resultadoEsperado) {
      Navigator.pop(context);
      widget.onExito();
    } else {
      setState(() {
        _mensajeError = "Incorrecto. Intenta con este nuevo cálculo:";
        _generarReto();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.verified_user_rounded, color: Colors.indigo.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Zona de Padres",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Por seguridad familiar y directrices de menores, resuelve la siguiente operación para verificar que eres un adulto:",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Text(
                "$_num1 × $_num2 = ?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _respuestaCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Tu resultado",
              errorText: _mensajeError,
              prefixIcon: const Icon(Icons.calculate_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _validarRespuesta(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _validarRespuesta,
          child: const Text("Verificar"),
        ),
      ],
    );
  }
}
