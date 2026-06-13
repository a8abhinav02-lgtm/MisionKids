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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  
  Hive.registerAdapter(TareaAdapter());
  Hive.registerAdapter(PerfilAdapter());
  
  // Inicializar servicio de notificaciones locales
  await NotificationService.inicializar();
  
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
          update: (_, auth, perfiles) => perfiles!..updateUid(auth.uid)..inicializar(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TareaProvider>(
          create: (_) => TareaProvider(),
          update: (_, auth, tareas) => tareas!..updateUid(auth.uid)..inicializar(),
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
          home: const SeleccionPerfilScreen(),
        ),
      ),
    );
  }
}