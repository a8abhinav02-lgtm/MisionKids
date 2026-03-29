import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/tarea_model.dart';
import 'models/perfil_model.dart';
import 'providers/auth_provider.dart';
import 'providers/perfiles_provider.dart';
import 'providers/tarea_provider.dart';
import 'ui/screens/seleccion_perfil_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(TareaAdapter());
  Hive.registerAdapter(PerfilAdapter());
  
  runApp(const MiAppTareas());
}

class MiAppTareas extends StatelessWidget {
  const MiAppTareas({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..inicializar()),
        ChangeNotifierProvider(create: (_) => PerfilesProvider()..inicializar()),
        ChangeNotifierProvider(create: (_) => TareaProvider()..inicializar()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Misión Switch 2 (Familia)',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF0F4F8),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const SeleccionPerfilScreen(),
      ),
    );
  }
}