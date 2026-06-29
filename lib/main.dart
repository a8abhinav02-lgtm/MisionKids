import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'models/tarea_model.dart';
import 'models/perfil_model.dart';
import 'providers/auth_provider.dart';
import 'providers/perfiles_provider.dart';
import 'providers/tarea_provider.dart';
import 'services/reminder_service.dart';
import 'services/notification_service.dart';
import 'ui/screens/seleccion_perfil_screen.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  
  Hive.registerAdapter(TareaAdapter());
  Hive.registerAdapter(PerfilAdapter());
  
  // Inicializar servicio de notificaciones locales
  if (!kIsWeb) {
    await NotificationService.inicializar();
  }
  
  runApp(const MiAppTareas());
}

class MiAppTareas extends StatelessWidget {
  const MiAppTareas({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..inicializar()),
        ChangeNotifierProxyProvider<AuthProvider, PerfilesProvider>(
          create: (_) => PerfilesProvider(),
          update: (_, auth, perfiles) => perfiles!..updateFamiliaId(auth.familiaId)..inicializar(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TareaProvider>(
          create: (_) => TareaProvider(),
          update: (_, auth, tareas) => tareas!..updateFamiliaId(auth.familiaId)..inicializar(),
        ),
      ],
      child: ReminderService(
        child: MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'Mission Kids (Familia)',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFFF0F4F8),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final restrictedTextScaler = mediaQueryData.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.25,
            );
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaler: restrictedTextScaler),
              child: child!,
            );
          },
          home: const SeleccionPerfilScreen(),
        ),
      ),
    );
  }
}