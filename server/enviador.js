
'use strict';

// "Enviador" = lo único que habla con Firebase.
// Se inyecta en el servidor para poder probar sin Firebase.

/**
 * Imprime los mensajes en consola en lugar de enviarlos.
 * Modo clase sin Firebase.
 */
function crearEnviadorConsola(log = console.log) {
  return {
    async enviar(mensaje) {
      log('[push simulado]', JSON.stringify(mensaje));
      return 'simulado';
    },
  };
}

/**
 * Enviador real con Firebase Admin SDK.
 *
 * Las credenciales se configuran mediante
 * GOOGLE_APPLICATION_CREDENTIALS.
 *
 * Con dryRun=true Firebase valida el mensaje,
 * pero no lo entrega.
 */
function crearEnviadorFcm({ dryRun = false } = {}) {
  const admin = require('firebase-admin');

  admin.initializeApp();

  const messaging = admin.messaging();

  return {
    enviar: (mensaje) => messaging.send(mensaje, dryRun),
  };
}

/**
 * Comprueba si un token dejó de ser válido.
 */
function esDestinoMuerto(err) {
  const codigo = err && err.code;

  // invalid-argument NO se incluye porque también
  // puede indicar un mensaje mal construido.
  return (
    codigo === 'messaging/registration-token-not-registered' ||
    codigo === 'messaging/invalid-registration-token'
  );
}

module.exports = {
  crearEnviadorConsola,
  crearEnviadorFcm,
  esDestinoMuerto
};
