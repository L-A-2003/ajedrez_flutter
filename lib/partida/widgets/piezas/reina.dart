import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Reina extends Pieza {
  const Reina({
    super.key,
    required super.color,
    required super.x,
    required super.y,
    super.icono = FontAwesomeIcons.chessQueen,
  });

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    return [
      ...obtenerPosiblesMovimientosDiagonales(),
      ...obtenerPosiblesMovimientosVerticalesHorizontales(),
    ];
  }
}
