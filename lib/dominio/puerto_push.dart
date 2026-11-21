import 'api_juego.dart';

enum PermisoPush { sinPreguntar, concedido, denegado }

/// Un mensaje recibido, sin depender del SDK de Firebase.
/// Los datos recibidos deben validarse antes de utilizarlos.
class MensajePush {
  const MensajePush({required this.datos, this.titulo, this.cuerpo});

  final Map<String, Object?> datos;
  final String? titulo;
  final String? cuerpo;
}

/// Interfaz para Firebase Cloud Messaging.
/// La implementación real estará en lib/infra/puerto_fcm.dart.
abstract class PuertoPush {
  /// Consulta el permiso actual sin mostrar ningún diálogo.
  Future<PermisoPush> estadoPermiso();

  /// Solicita al usuario permiso para recibir notificaciones.
  Future<PermisoPush> pedirPermiso();

  /// Obtiene el identificador del dispositivo.
  Future<DestinoPush?> obtenerDestino();

  /// Detecta cambios del token o identificador.
  Stream<DestinoPush> get destinoCambiado;

  /// Mensajes recibidos con la aplicación en primer plano.
  Stream<MensajePush> get enPrimerPlano;

  /// Mensajes abiertos desde una notificación.
  Stream<MensajePush> get alAbrirDesdeNotificacion;

  /// Notificación que abrió la aplicación desde cerrada.
  Future<MensajePush?> mensajeInicial();

  /// Suscribe el dispositivo a una sala.
  Future<void> suscribirTema(String tema);

  /// Cancela la suscripción a una sala.
  Future<void> desuscribirTema(String tema);
}
