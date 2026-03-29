import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/perfiles_provider.dart';
import '../themes/app_theme.dart';
import 'seleccion_perfil_screen.dart';

class SetupFamiliaScreen extends StatefulWidget {
  const SetupFamiliaScreen({super.key});

  @override
  State<SetupFamiliaScreen> createState() => _SetupFamiliaScreenState();
}

class _SetupFamiliaScreenState extends State<SetupFamiliaScreen> {
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _nombreHijoCtrl = TextEditingController();

  String _colorSeleccionado = 'azul';
  String _avatarSeleccionado = 'astronauta';
  int _step = 0; // 0 = PIN, 1 = Perfil del hijo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo + Title
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Icon(Icons.family_restroom, size: 56, color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "¡Bienvenido!",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Configuremos la cuenta familiar",
                      style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
                    ),

                    const SizedBox(height: 30),

                    // Steps indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepDot(label: "PIN", isActive: _step == 0, isDone: _step > 0),
                        Container(width: 40, height: 2, color: _step > 0 ? Colors.amber : Colors.white24),
                        _StepDot(label: "Hijo", isActive: _step == 1, isDone: false),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: _step == 0 ? _buildPinStep() : _buildPerfilStep(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.lock, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            const Text("Crea tu PIN de Administrador", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Text("Solo los padres podrán acceder a la zona de control.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 20),
        TextField(controller: _pinCtrl, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(labelText: "PIN (4 dígitos)", prefixIcon: Icon(Icons.password))),
        const SizedBox(height: 12),
        TextField(controller: _confirmPinCtrl, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(labelText: "Confirmar PIN", prefixIcon: Icon(Icons.password))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () {
              if (_pinCtrl.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("El PIN debe tener al menos 4 dígitos")));
                return;
              }
              if (_pinCtrl.text != _confirmPinCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Los PINs no coinciden")));
                return;
              }
              setState(() => _step = 1);
            },
            child: const Text("SIGUIENTE →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildPerfilStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.child_care, color: Colors.amber),
            ),
            const SizedBox(width: 12),
            const Text("Perfil del Primer Hijo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 20),
        TextField(controller: _nombreHijoCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: "Nombre del Hijo/a", prefixIcon: Icon(Icons.person))),
        const SizedBox(height: 20),

        const Text("Avatar:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppTheme.avatares.keys.map((k) {
            final isSelected = _avatarSeleccionado == k;
            return GestureDetector(
              onTap: () => setState(() => _avatarSeleccionado = k),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo.withValues(alpha: 0.1) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.indigo : Colors.transparent, width: 2.5),
                    ),
                    child: Icon(AppTheme.avatares[k], size: 28, color: isSelected ? Colors.indigo : Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(AppTheme.avatarLabels[k] ?? k, style: TextStyle(fontSize: 10, color: isSelected ? Colors.indigo : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        const Text("Color preferido:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppTheme.colors.keys.map((c) {
            final isSelected = _colorSeleccionado == c;
            return GestureDetector(
              onTap: () => setState(() => _colorSeleccionado = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.colors[c],
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.black87 : Colors.transparent, width: 3),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.colors[c]!.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)] : [],
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 22) : null,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text("← ATRÁS"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  if (_nombreHijoCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escribe el nombre del niño")));
                    return;
                  }
                  final authProv = Provider.of<AuthProvider>(context, listen: false);
                  final perfilProv = Provider.of<PerfilesProvider>(context, listen: false);

                  await authProv.registrarAdmin(_pinCtrl.text);
                  await perfilProv.crearPerfil(nombre: _nombreHijoCtrl.text, tematica: _avatarSeleccionado, colorPrimario: _colorSeleccionado);

                  if (mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SeleccionPerfilScreen()));
                  }
                },
                child: const Text("COMENZAR 🚀", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepDot({required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.amber : (isActive ? Colors.amber.withValues(alpha: 0.3) : Colors.white12),
            border: Border.all(color: isActive || isDone ? Colors.amber : Colors.white24, width: 2),
          ),
          child: isDone ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: isActive || isDone ? Colors.amber : Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
