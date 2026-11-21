import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

/// Manejador de notificaciones en segundo plano.
/// No modifica la interfaz ni el controlador.
@pragma('vm:entry-point')
Future<void> manejadorSegundoPlano(RemoteMessage mensaje) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Al abrir la app, el controlador
  // consultará al servidor para recuperar las cartas.
}
