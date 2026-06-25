import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Torre extends Pieza {
  final bool movido;

  const Torre({super.key, this.movido = false, required super.color, required super.x, required super.y, super.icono = FontAwesomeIcons.chessRook});

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    return obtenerPosiblesMovimientosVerticalesHorizontales();
  }
}
