import 'evento.dart';
import 'lineas.dart';

enum ResultadoAplicar { aplicado, duplicado, hueco, informativo }

/// El estado de la partida visto por UN jugador.
/// El push NO garantiza orden, entrega ni ausencia de duplicados.
class Partida {
  Partida({required this.sala, required this.nombre, required this.tabla});

  final String sala;
  final String nombre;
  final List<int> tabla;

  final List<CartaCantada> _cantadas = [];

  String? ganador;
  String? patronGanador;
  bool casi = false;
  int? cartaQueFalta;

  List<CartaCantada> get cantadas => List.unmodifiable(_cantadas);

  int get ultima => _cantadas.length;

  Set<int> get idsCantados => {for (final c in _cantadas) c.cartaId};

  CartaCantada? get ultimaCarta => _cantadas.isEmpty ? null : _cantadas.last;

  bool estaMarcada(int cartaId) => idsCantados.contains(cartaId);

  List<String> get patrones => patronesCompletos(tabla, idsCantados);

  bool get puedeCantarLoteria => ganador == null && patrones.isNotEmpty;

  /// Aplica un evento recibido por notificación o por el servidor.
  ResultadoAplicar aplicar(EventoJuego e) {
    switch (e) {
      case CartaCantada c:
        // La carta ya se había recibido.
        if (c.n <= ultima) {
          return ResultadoAplicar.duplicado;
        }

        // Faltan cartas anteriores.
        if (c.n > ultima + 1) {
          return ResultadoAplicar.hueco;
        }

        // Es la siguiente carta esperada.
        _cantadas.add(c);
        return ResultadoAplicar.aplicado;

      case LoteriaCantada l:
        final yaEstaba = ganador == l.ganador;

        ganador = l.ganador;
        patronGanador = l.patron;

        return yaEstaba
            ? ResultadoAplicar.duplicado
            : ResultadoAplicar.aplicado;

      case CasiGanas k:
        casi = true;
        cartaQueFalta = k.cartaId;

        return ResultadoAplicar.informativo;
    }
  }

  /// Aplica cartas recibidas del servidor.
  /// Admite cartas desordenadas y repetidas.
  void aplicarLote(List<CartaCantada> cartas) {
    final ordenadas = [...cartas]..sort((a, b) => a.n.compareTo(b.n));

    for (final c in ordenadas) {
      aplicar(c);
    }
  }
}
