import 'dart:async';

import 'package:flutter/widgets.dart';

import '../dominio/api_juego.dart';
import '../dominio/controlador.dart';
import '../dominio/partida.dart';
import '../dominio/puerto_push.dart';

class JuegoVm extends ChangeNotifier {
  JuegoVm(this.controlador) {
    _sub = controlador.cambios.listen((_) => notifyListeners());
  }

  final ControladorPartida controlador;
  late final StreamSubscription<void> _sub;

  Timer? _consulta;
  String? mensaje;
  bool ocupado = false;

  Partida? get partida => controlador.partida;
  bool get avisosActivos => controlador.avisosActivos;
  PermisoPush get permiso => controlador.permiso;

  /// Busca una partida guardada al iniciar la app.
  Future<void> iniciar() async {
    await controlador.leerPermiso();

    if (await controlador.restaurar()) {
      _vigilar();
    }

    notifyListeners();
  }

  /// Sin notificaciones, consulta al servidor
  /// cada 5 segundos mientras la app está abierta.
  void _vigilar() {
    _consulta?.cancel();

    if (controlador.avisosActivos) return;

    _consulta = Timer.periodic(
      const Duration(seconds: 5),
      (_) => controlador.sincronizar(),
    );
  }

  /// Permite unirse a una sala.
  Future<void> unirse({
    required String sala,
    required String nombre,
    required bool pedirAvisos,
  }) async {
    ocupado = true;
    mensaje = null;
    notifyListeners();

    try {
      if (pedirAvisos) {
        await controlador.pedirPermisoAvisos();
      }

      await controlador.unirse(sala: sala, nombre: nombre);

      _vigilar();
    } on ErrorApi catch (e) {
      mensaje = e.mensaje;
    } finally {
      ocupado = false;
      notifyListeners();
    }
  }

  /// Sincroniza cuando el usuario vuelve a la app.
  Future<void> alVolverALaApp() => controlador.sincronizar();

  /// Solicita validar un reclamo de Lotería.
  Future<void> cantarLoteria() async {
    try {
      final r = await controlador.reclamarLoteria();

      mensaje = r.gano
          ? '¡Ganaste! 🎉'
          : 'Todavía no tienes Lotería... ¡paciencia!';
    } on ErrorApi catch (e) {
      mensaje = e.mensaje;
    }

    notifyListeners();
  }

  /// Sale de la partida.
  Future<void> salir() async {
    _consulta?.cancel();
    await controlador.salir();
  }

  @override
  void dispose() {
    _consulta?.cancel();
    _sub.cancel();
    super.dispose();
  }
}

/// ViewModel del cantor.
class CantorVm extends ChangeNotifier {
  CantorVm(this.api);

  final ApiJuego api;

  SalaCreada? sala;
  final List<String> cantadas = [];
  String? mensaje;

  Timer? _auto;

  bool get automatico => _auto != null;

  /// Crea una nueva sala.
  Future<void> crear() async {
    try {
      sala = await api.crearSala();
      mensaje = null;
    } on ErrorApi catch (e) {
      mensaje = e.mensaje;
    }

    notifyListeners();
  }

  /// Canta la siguiente carta.
  Future<void> cantar() async {
    final s = sala;

    if (s == null) return;

    try {
      final c = await api.cantar(s.id, s.claveCantor);

      cantadas.insert(0, '${c.n}. ${c.nombre}');

      mensaje = null;
    } on ErrorApi catch (e) {
      mensaje = e.mensaje;

      if (e.codigo == 'SALA_TERMINADA' || e.codigo == 'SIN_CARTAS') {
        detenerAutomatico();
      }
    }

    notifyListeners();
  }

  /// Alterna el canto automático.
  void alternarAutomatico() {
    if (automatico) {
      detenerAutomatico();
    } else {
      _auto = Timer.periodic(const Duration(seconds: 6), (_) => cantar());
    }

    notifyListeners();
  }

  /// Detiene el canto automático.
  void detenerAutomatico() {
    _auto?.cancel();
    _auto = null;
  }

  @override
  void dispose() {
    detenerAutomatico();
    super.dispose();
  }
}
