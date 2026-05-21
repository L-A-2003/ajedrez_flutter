import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Torre extends Pieza {
  const Torre({
    super.key,
    required super.x,
    required super.y,
    required super.color,
    super.icono = FontAwesomeIcons.chessRook,
  });

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    return obtenerPosiblesMovimientosVerticalesHorizontales();
  }
}
