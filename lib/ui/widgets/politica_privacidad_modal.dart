import 'package:flutter/material.dart';

class PoliticaPrivacidadModal extends StatelessWidget {
  const PoliticaPrivacidadModal({super.key});

  static Future<void> mostrar(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PoliticaPrivacidadModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Política de Privacidad",
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Compromiso de protección a menores (COPPA)",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

          // Contenido de la política
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _seccion(
                  icono: Icons.child_care_rounded,
                  color: Colors.green,
                  titulo: "1. Protección de Menores (COPPA)",
                  contenido:
                      "Misión Kids está diseñada para familias. No recopilamos información personal sensible de menores de 13 años. Los nombres o apodos utilizados en los perfiles existen exclusivamente para identificar las tareas y recompensas dentro de tu hogar.",
                ),
                const SizedBox(height: 16),
                _seccion(
                  icono: Icons.lock_outline_rounded,
                  color: Colors.indigo,
                  titulo: "2. Entorno Familiar Privado",
                  contenido:
                      "Todos los hábitos, registros de rachas, estrellas y misiones quedan cifrados y almacenados de forma segura mediante Hive local y Firebase Firestore bajo reglas estrictas que impiden el acceso a cualquier usuario externo a tu familia.",
                ),
                const SizedBox(height: 16),
                _seccion(
                  icono: Icons.no_adult_content_rounded,
                  color: Colors.orange,
                  titulo: "3. Cero Publicidad de Terceros",
                  contenido:
                      "Nuestra aplicación no contiene anuncios publicitarios de terceros ni rastreadores conductuales comerciales. Tu información familiar jamás se vende ni se comparte para fines de mercadotecnia.",
                ),
                const SizedBox(height: 16),
                _seccion(
                  icono: Icons.security_rounded,
                  color: Colors.purple,
                  titulo: "4. Puertas Parentales (Parental Gate)",
                  contenido:
                      "Cualquier acción hacia el exterior (como envío de sugerencias, soporte o enlaces) está protegida mediante retos matemáticos o PIN de acceso para garantizar que únicamente los adultos tomen decisiones operativas.",
                ),
                const SizedBox(height: 16),
                _seccion(
                  icono: Icons.delete_forever_rounded,
                  color: Colors.red,
                  titulo: "5. Control y Eliminación de Datos",
                  contenido:
                      "Los tutores legales tienen control total para editar, reiniciar o eliminar permanentemente cualquier perfil infantil o registro de misiones en cualquier momento desde la Zona de Padres.",
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "Misión Kids • Septiembre 2026\nVersión familiar certificada para Google Play & Web",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion({
    required IconData icono,
    required Color color,
    required String titulo,
    required String contenido,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contenido,
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
