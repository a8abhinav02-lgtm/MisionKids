import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../providers/perfiles_provider.dart';
import '../themes/app_theme.dart';
import 'setup_familia_screen.dart';
import 'esperando_aprobacion_screen.dart';
import 'home_nino_screen.dart';
import 'admin_screen.dart';
import '../widgets/feedback_fab.dart';
import '../widgets/politica_privacidad_modal.dart';

class SeleccionPerfilScreen extends StatelessWidget {
  const SeleccionPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final perfilesProv = Provider.of<PerfilesProvider>(context);

    if (authProv.isLoading || perfilesProv.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final perfiles = perfilesProv.todosLosPerfiles;

    if (!authProv.existeAdmin || !authProv.estaAutenticado) {
      return const SetupFamiliaScreen();
    }

    if (!authProv.estaAprobado) {
      return const EsperandoAprobacionScreen();
    }

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
              if (authProv.tieneActualizacion)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: FadeInDown(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(authProv.urlDescargaActualizacion);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Color(0xFFF77F00)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.system_update_alt_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Actualización Disponible",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Presiona aquí para descargar la última versión de Android.",
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                          delay: Duration(milliseconds: 200 + perfiles.length * 150),
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
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => PoliticaPrivacidadModal.mostrar(context),
                icon: const Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                label: const Text(
                  "Política de Privacidad y Menores",
                  style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: const FeedbackFab(),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _mostrarDialogoRecuperarPin(context, authProv);
                },
                child: const Text(
                  "¿Olvidaste tu PIN? 🔑",
                  style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
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

  void _mostrarDialogoRecuperarPin(BuildContext context, AuthProvider authProv) {
    final passwordCtrl = TextEditingController();
    final nuevoPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    bool cargando = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          final email = authProv.emailPadre.isNotEmpty ? authProv.emailPadre : (authProv.usuario?.email ?? '');

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lock_reset, color: Colors.amber.shade800),
                ),
                const SizedBox(width: 12),
                const Text("Recuperar PIN"),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email.isNotEmpty
                        ? "Para verificar que eres el tutor legal de la cuenta ($email), ingresa tu contraseña:"
                        : "Define tu nuevo PIN de acceso de 4 dígitos:",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Contraseña de la cuenta",
                        prefixIcon: const Icon(Icons.key),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: nuevoPinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: "Nuevo PIN (4 dígitos)",
                      prefixIcon: const Icon(Icons.pin),
                      counterText: "",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: "Confirmar nuevo PIN",
                      prefixIcon: const Icon(Icons.check),
                      counterText: "",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final enviado = await authProv.enviarCorreoRestablecimientoPassword();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  enviado
                                      ? "Enlace enviado a $email. Revisa tu bandeja de entrada."
                                      : "No se pudo enviar el correo. Verifica tu conexión.",
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "¿Olvidaste también tu contraseña? Enviar correo",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.indigo),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: cargando
                    ? null
                    : () async {
                        final nuevoPin = nuevoPinCtrl.text.trim();
                        final confirmPin = confirmPinCtrl.text.trim();

                        if (nuevoPin.length != 4 || nuevoPin != confirmPin) {
                          setStateModal(() {
                            errorMsg = "El nuevo PIN debe ser de 4 dígitos y coincidir.";
                          });
                          return;
                        }

                        if (email.isNotEmpty && passwordCtrl.text.isEmpty) {
                          setStateModal(() {
                            errorMsg = "Ingresa tu contraseña actual para confirmar.";
                          });
                          return;
                        }

                        setStateModal(() {
                          cargando = true;
                          errorMsg = null;
                        });

                        final exito = await authProv.restablecerPinConContrasena(
                          password: passwordCtrl.text,
                          nuevoPin: nuevoPin,
                        );

                        if (exito) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("¡PIN actualizado con éxito! Ya puedes ingresar."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          setStateModal(() {
                            cargando = false;
                            errorMsg = "Contraseña incorrecta o error al sincronizar.";
                          });
                        }
                      },
                child: cargando
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Guardar PIN"),
              ),
            ],
          );
        },
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
