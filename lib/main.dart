import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'dominio/controlador.dart';
import 'firebase_options.dart';
import 'infra/almacen_prefs.dart';
import 'infra/api_http.dart';
import 'infra/canales_android.dart';
import 'infra/fondo.dart';
import 'infra/puerto_fcm.dart';
import 'presentacion/vms.dart';

/// 10.0.2.2 es la dirección de la computadora
/// vista desde el emulador Android.
///
/// El servidor Node.js está configurado
/// para utilizar el puerto 8081.
const String urlServidor = String.fromEnvironment(
  'SERVIDOR',
  defaultValue: 'http://10.0.2.2:8081',
);

Future<void> main() async {
  // Inicializar Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Registrar el manejador de segundo plano.
  // Debe registrarse antes de runApp().
  FirebaseMessaging.onBackgroundMessage(manejadorSegundoPlano);

  // Evitar que iOS muestre automáticamente
  // las notificaciones mientras la app está abierta.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );

  // Crear los canales de notificaciones de Android.
  await crearCanalesAndroid();

  // Conexión con el servidor Node.js.
  final api = ApiHttp(urlServidor);

  // Almacenamiento de sesiones.
  final almacen = AlmacenPrefs(await SharedPreferences.getInstance());

  // Controlador principal de la partida.
  final controlador = ControladorPartida(
    api: api,
    push: PuertoFcm(),
    almacen: almacen,
  );

  // Iniciar la aplicación.
  runApp(
    AppLoteria(vm: JuegoVm(controlador), crearCantor: () => CantorVm(api)),
  );
}
