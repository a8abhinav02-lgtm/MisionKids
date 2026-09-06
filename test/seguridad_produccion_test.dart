import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:josue_tareas/providers/auth_provider.dart';
import 'package:josue_tareas/ui/widgets/parental_gate_dialog.dart';
import 'package:josue_tareas/ui/widgets/politica_privacidad_modal.dart';

void main() {
  late Directory tempDir;
  late AuthProvider authProvider;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('hive_seguridad_test_');
    Hive.init(tempDir.path);
    authProvider = AuthProvider();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Línea 4: Seguridad y Recuperación de PIN de Padres', () {
    test('Restablecimiento de PIN en modo local actualiza el PIN en AuthProvider', () async {
      await authProvider.inicializar();

      final exito = await authProvider.restablecerPinConContrasena(
        password: '',
        nuevoPin: '4321',
      );

      expect(exito, isTrue);
      expect(authProvider.pinPadre, '4321');
    });

    test('enviarCorreoRestablecimientoPassword maneja caso sin email sin lanzar excepciones', () async {
      await authProvider.inicializar();
      final resultado = await authProvider.enviarCorreoRestablecimientoPassword();
      expect(resultado, isFalse);
    });
  });

  group('Línea 4: Puerta Parental y Cumplimiento COPPA', () {
    testWidgets('ParentalGateDialog se renderiza y valida respuesta matemática', (tester) async {
      bool exitoInvocado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ParentalGateDialog.verificar(
                  context,
                  onExito: () => exitoInvocado = true,
                ),
                child: const Text('Abrir Reto'),
              ),
            ),
          ),
        ),
      );

      // Abrir el diálogo
      await tester.tap(find.text('Abrir Reto'));
      await tester.pumpAndSettle();

      // Verificar que el diálogo está visible
      expect(find.text('Zona de Padres'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Extraer los números de la operación del texto
      final textoRetoFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data != null && widget.data!.contains('×') && widget.data!.contains('='),
      );
      expect(textoRetoFinder, findsOneWidget);

      // Probar primero respuesta incorrecta
      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('Verificar'));
      await tester.pumpAndSettle();

      expect(exitoInvocado, isFalse);
      expect(find.text('Incorrecto. Intenta con este nuevo cálculo:'), findsOneWidget);

      // Extraer el nuevo reto tras fallo
      final nuevoTextoReto = (tester.widget(textoRetoFinder) as Text).data!;
      final nuevasPartes = nuevoTextoReto.split('×');
      final nuevoNum1 = int.parse(nuevasPartes[0].trim());
      final nuevoNum2 = int.parse(nuevasPartes[1].split('=')[0].trim());
      final nuevoResultadoCorrecto = (nuevoNum1 * nuevoNum2).toString();

      // Ingresar la respuesta correcta
      await tester.enterText(find.byType(TextField), nuevoResultadoCorrecto);
      await tester.tap(find.text('Verificar'));
      await tester.pumpAndSettle();

      // Se debe haber cerrado el diálogo y ejecutado onExito
      expect(exitoInvocado, isTrue);
      expect(find.byType(ParentalGateDialog), findsNothing);
    });

    testWidgets('PoliticaPrivacidadModal se renderiza con todas las secciones requeridas', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 2000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PoliticaPrivacidadModal(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Política de Privacidad'), findsOneWidget);
      expect(find.textContaining('1. Protección de Menores (COPPA)'), findsOneWidget);
      expect(find.textContaining('2. Entorno Familiar Privado'), findsOneWidget);
      expect(find.textContaining('3. Cero Publicidad de Terceros'), findsOneWidget);
      expect(find.textContaining('4. Puertas Parentales (Parental Gate)'), findsOneWidget);
      expect(find.textContaining('5. Control y Eliminación de Datos'), findsOneWidget);
    });
  });
}
