import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/perfil_model.dart';

class PerfilesProvider extends ChangeNotifier {
  Box<Perfil>? _cajaPerfiles;
  bool isLoading = true;

  Perfil? _perfilActivo;
  
  Perfil? get perfilActivo => _perfilActivo;

  List<Perfil> get todosLosPerfiles {
    if (_cajaPerfiles == null || !_cajaPerfiles!.isOpen) return [];
    return _cajaPerfiles!.values.toList();
  }

  Future<void> inicializar() async {
    _cajaPerfiles = await Hive.openBox<Perfil>('caja_perfiles_v2');
    isLoading = false;
    notifyListeners();
  }

  void setPerfilActivo(Perfil perfil) {
    _perfilActivo = perfil;
    notifyListeners();
  }

  void limpiarPerfilActivo() {
    _perfilActivo = null;
    notifyListeners();
  }
  
  Perfil? buscarPerfil(String id) {
     return _cajaPerfiles?.get(id);
  }

  Future<void> crearPerfil({
    required String nombre, 
    required String tematica, 
    required String colorPrimario
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final nuevo = Perfil(
      id: newId,
      nombre: nombre,
      tematica: tematica,
      colorPrimario: colorPrimario,
    );
    await _cajaPerfiles!.put(newId, nuevo);
    notifyListeners();
  }

  Future<void> editarPerfil(Perfil perfil, String nombre, String tematica, String colorPrimario) async {
    perfil.nombre = nombre;
    perfil.tematica = tematica;
    perfil.colorPrimario = colorPrimario;
    await perfil.save();
    notifyListeners();
  }

  Future<void> eliminarPerfil(Perfil perfil) async {
    await perfil.delete();
    if (_perfilActivo?.id == perfil.id) {
       _perfilActivo = null;
    }
    notifyListeners();
  }

  // --- Finanzas del Perfil Activo ---
  Future<void> agregarDinero(String perfilId, int cantidad) async {
    final perfil = _cajaPerfiles?.get(perfilId);
    if (perfil != null) {
      perfil.saldo += cantidad;
      await perfil.save();
      notifyListeners();
    }
  }

  Future<void> definirNuevaMeta(String perfilId, String nombre, double monto) async {
    final perfil = _cajaPerfiles?.get(perfilId);
    if (perfil != null) {
      perfil.nombreMeta = nombre;
      perfil.metaAhorro = monto;
      await perfil.save();
      notifyListeners();
    }
  }

  Future<void> reclamarPremio(String perfilId) async {
    final perfil = _cajaPerfiles?.get(perfilId);
    if (perfil == null) return;
    
    final costoMeta = perfil.metaAhorro.toInt();
    final nombrePremio = perfil.nombreMeta;

    if (perfil.saldo >= costoMeta && costoMeta > 0) {
      perfil.saldo -= costoMeta;

      final nuevaVictoria = {
        'nombre': nombrePremio,
        'fecha': DateTime.now().toIso8601String(),
        'costo': costoMeta,
      };

      final List<Map<dynamic, dynamic>> historial = List.from(perfil.historialVictorias);
      historial.add(nuevaVictoria);
      
      perfil.historialVictorias = historial;
      perfil.metaAhorro = 0.0;
      perfil.nombreMeta = '';

      await perfil.save();
      notifyListeners();
    }
  }
}
