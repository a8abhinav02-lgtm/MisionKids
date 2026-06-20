import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../providers/auth_provider.dart';
import '../../providers/perfiles_provider.dart';
import '../../services/error_handler.dart';
import '../themes/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'seleccion_perfil_screen.dart';

class SetupFamiliaScreen extends StatefulWidget {
  const SetupFamiliaScreen({super.key});

  @override
  State<SetupFamiliaScreen> createState() => _SetupFamiliaScreenState();
}

class _SetupFamiliaScreenState extends State<SetupFamiliaScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _nombreHijoCtrl = TextEditingController();

  String _colorSeleccionado = 'azul';
  String _avatarSeleccionado = 'astronauta';
  int _step = -1; // -1 = Elección Inicial, 0 = Cuenta, 1 = PIN, 2 = Perfil del hijo, 3 = Código familiar (Join)
  bool _isCargando = false;
  bool _isLoginFlow = false;
  bool _isJoinFlow = false;
  final _codigoFamiliaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
                    Hero(
                      tag: 'logo_familia',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
                        ),
                        child: const Icon(Icons.family_restroom, size: 56, color: Colors.amber),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Mission Kids",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _step == -1 ? "¡Bienvenida Familia!" : (_isLoginFlow ? "Inicia sesión" : "Crea tu cuenta familiar"),
                      style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
                    ),

                    const SizedBox(height: 30),

                    if (_step == -1) 
                      _buildChoiceStep()
                    else ...[
                      // Steps indicator (Solo en registro)
                      if (!_isLoginFlow) 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StepDot(label: "Cuenta", isActive: _step == 0, isDone: _step > 0),
                            _connector(_step > 0),
                            _StepDot(label: "PIN", isActive: _step == 1, isDone: _step > 1),
                            _connector(_step > 1),
                            _StepDot(label: "Hijo", isActive: _step == 2, isDone: false),
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
                        child: _isLoginFlow 
                          ? _buildLoginStep() 
                          : (_step == 0 
                              ? _buildEmailStep() 
                              : (_step == 1 
                                  ? _buildPinStep() 
                                  : (_step == 2 
                                      ? _buildPerfilStep() 
                                      : _buildJoinStep()))),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _connector(bool active) => Container(width: 30, height: 2, color: active ? Colors.amber : Colors.white24);

  Widget _buildChoiceStep() {
    return Column(
      children: [
        _ChoiceCard(
          title: "¡Comenzar Nueva Familia!",
          subtitle: "Crea tu cuenta de administrador y los perfiles de tus hijos por primera vez.",
          icon: Icons.rocket_launch,
          color: Colors.amber,
          onTap: () => setState(() { _step = 0; _isLoginFlow = false; _isJoinFlow = false; }),
        ),
        const SizedBox(height: 20),
        _ChoiceCard(
          title: "Sincronizar mi Familia",
          subtitle: "Ya tienes una cuenta en otro dispositivo. Ingresa para descargar tus datos.",
          icon: Icons.cloud_download,
          color: Colors.blue,
          onTap: () => setState(() { _step = 0; _isLoginFlow = true; _isJoinFlow = false; }),
        ),
        const SizedBox(height: 20),
        _ChoiceCard(
          title: "Unirse a Familia Existente",
          subtitle: "Otro padre ya configuró la familia. Regístrate e ingresa su código.",
          icon: Icons.group_add,
          color: Colors.indigo,
          onTap: () => setState(() { _step = 0; _isLoginFlow = false; _isJoinFlow = true; }),
        ),
      ],
    );
  }

  Widget _buildLoginStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Inicia Sesión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Text("Tus datos se descargarán automáticamente.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 20),
        TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Correo Electrónico", prefixIcon: Icon(Icons.email))),
        const SizedBox(height: 12),
        TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.vpn_key))),
        const SizedBox(height: 24),
        if (_isCargando)
          const Center(child: CircularProgressIndicator())
        else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () async {
                if (!_emailCtrl.text.contains('@') || _passCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa tus credenciales")));
                  return;
                }
                setState(() => _isCargando = true);
                try {
                  final authProv = Provider.of<AuthProvider>(context, listen: false);
                  await authProv.loginPadre(_emailCtrl.text.trim(), _passCtrl.text);
                  if (!context.mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SeleccionPerfilScreen()));
                } on FirebaseAuthException catch (e) {
                  if (!context.mounted) return;
                  setState(() => _isCargando = false);
                  final errorMsg = ErrorHandler.getMessage(e.code);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
                } catch (e) {
                  if (!context.mounted) return;
                  setState(() => _isCargando = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al entrar: ${e.toString()}"), backgroundColor: Colors.red));
                }
              },
              child: const Text("SINCRONIZAR Y ENTRAR ☁️", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step = -1),
              child: const Text("← VOLVER ATRÁS", style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_circle, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            const Text("Paso 1: Tu Cuenta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Text("Los datos se guardarán en la nube de forma segura.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 20),
        TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Correo Electrónico", prefixIcon: Icon(Icons.email))),
        const SizedBox(height: 12),
        TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Crea una Contraseña", prefixIcon: Icon(Icons.vpn_key))),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = -1), child: const Text("ATRÁS"))),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  if (!_emailCtrl.text.contains('@') || _passCtrl.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email inválido o contraseña corta (min 6)")));
                    return;
                  }
                  if (_isJoinFlow) {
                    setState(() => _step = 3);
                  } else {
                    setState(() => _step = 1);
                  }
                },
                child: const Text("SIGUIENTE →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
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
            const Text("Paso 2: PIN de Acceso", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Text("Para proteger tu panel de control local.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 20),
        TextField(controller: _pinCtrl, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(labelText: "PIN (4 dígitos)", prefixIcon: Icon(Icons.password))),
        const SizedBox(height: 12),
        TextField(controller: _confirmPinCtrl, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(labelText: "Confirmar PIN", prefixIcon: Icon(Icons.password))),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text("ATRÁS"))),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  if (_pinCtrl.text.length < 4 || _pinCtrl.text != _confirmPinCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Revisa el PIN y su confirmación")));
                    return;
                  }
                  setState(() => _step = 2);
                },
                child: const Text("SIGUIENTE →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
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
            const Text("Paso 3: Primer Perfil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        if (_isCargando)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text("ATRÁS"))),
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
                    setState(() => _isCargando = true);
                    try {
                      final authProv = Provider.of<AuthProvider>(context, listen: false);
                      final perfilProv = Provider.of<PerfilesProvider>(context, listen: false);

                      await authProv.registrarAdmin(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text,
                        pin: _pinCtrl.text,
                      );
                      
                      await perfilProv.crearPerfil(
                        nombre: _nombreHijoCtrl.text, 
                        tematica: _avatarSeleccionado, 
                        colorPrimario: _colorSeleccionado
                      );

                      if (!context.mounted) return;
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SeleccionPerfilScreen()));
                    } on FirebaseAuthException catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isCargando = false);
                      final errorMsg = ErrorHandler.getMessage(e.code);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
                    } catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isCargando = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text("CREAR CUENTA 🚀", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildJoinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.group_add, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            const Text("Paso 2: Código Familiar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Text("Ingresa el código de familia compartido por el otro administrador.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 20),
        TextField(
          controller: _codigoFamiliaCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: "Código de Familia (ej: MK-123456)",
            prefixIcon: Icon(Icons.vpn_key_rounded),
          ),
        ),
        const SizedBox(height: 24),
        if (_isCargando)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text("ATRÁS"))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    final codigo = _codigoFamiliaCtrl.text.trim().toUpperCase();
                    if (codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa el código de familia")));
                      return;
                    }
                    setState(() => _isCargando = true);
                    try {
                      final authProv = Provider.of<AuthProvider>(context, listen: false);
                      await authProv.joinFamilyFlow(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text,
                        codigo: codigo,
                      );

                      if (!context.mounted) return;
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SeleccionPerfilScreen()));
                    } on FirebaseAuthException catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isCargando = false);
                      final errorMsg = ErrorHandler.getMessage(e.code);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
                    } catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isCargando = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error inesperado: ${e.toString()}"), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text("UNIRSE A FAMILIA 👥", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
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
