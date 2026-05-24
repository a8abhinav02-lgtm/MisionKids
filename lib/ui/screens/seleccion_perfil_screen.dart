import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/auth_provider.dart';
import '../../providers/perfiles_provider.dart';
import '../themes/app_theme.dart';
import 'setup_familia_screen.dart';
import 'esperando_aprobacion_screen.dart';
import 'home_nino_screen.dart';
import 'admin_screen.dart';

class SeleccionPerfilScreen extends StatelessWidget {
  const SeleccionPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final perfilesProv = Provider.of<PerfilesProvider>(context);

    if (authProv.isLoading || perfilesProv.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProv.existeAdmin) {
      return const SetupFamiliaScreen();
    }

    if (!authProv.estaAprobado) {
      return const EsperandoAprobacionScreen();
    }

    final perfiles = perfilesProv.todosLosPerfiles;

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
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Animated Title
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Icon(Icons.rocket_launch, size: 48, color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "¿Quién eres?",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Elige tu perfil para continuar",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Versión: v1.5.0-Aprobaciones 🔒",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: [
                        // Perfiles de Hijos
                        ...perfiles.asMap().entries.map((entry) {
                          final i = entry.key;
                          final perfil = entry.value;
                          return FadeInUp(
                            delay: Duration(milliseconds: 200 + (i * 150)),
                            child: _BotonAvatar(
                              nombre: perfil.nombre,
                              iconData: AppTheme.getAvatarIcon(perfil.tematica),
                              color: AppTheme.colors[perfil.colorPrimario] ?? Colors.grey,
                              onTap: () {
                                perfilesProv.setPerfilActivo(perfil);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeNinoScreen()));
                              },
                            ),
                          );
                        }),

                        // Botón Padres
                        FadeInUp(
                          delay: Duration(milliseconds: 200 + (perfiles.length * 150)),
                          child: _BotonAvatar(
                            nombre: "Padres",
                            iconData: Icons.admin_panel_settings,
                            color: Colors.grey,
                            esPadre: true,
                            onTap: () => _mostrarLoginPadre(context, authProv),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarLoginPadre(BuildContext context, AuthProvider authProv) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            const Text("Zona de Padres"),
          ],
        ),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "PIN",
            prefixIcon: const Icon(Icons.password),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await authProv.cerrarSesion();
              if (ctx.mounted) Navigator.pop(ctx);
            }, 
            child: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (pinController.text == authProv.pinPadre) {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN Incorrecto ⛔"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Entrar"),
          ),
        ],
      ),
    );
  }
}

class _BotonAvatar extends StatefulWidget {
  final String nombre;
  final IconData iconData;
  final MaterialColor color;
  final VoidCallback onTap;
  final bool esPadre;

  const _BotonAvatar({
    required this.nombre,
    required this.iconData,
    required this.color,
    required this.onTap,
    this.esPadre = false,
  });

  @override
  State<_BotonAvatar> createState() => _BotonAvatarState();
}

class _BotonAvatarState extends State<_BotonAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.esPadre
                  ? LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade800])
                  : LinearGradient(colors: [widget.color.shade300, widget.color.shade700]),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(widget.iconData, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            widget.nombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (widget.esPadre) return child;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (ctx, ch) => Transform.scale(scale: _scaleAnim.value, child: ch),
      child: child,
    );
  }
}
