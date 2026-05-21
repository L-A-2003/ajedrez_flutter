import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Rey extends Pieza {
  const Rey({
    super.key,
    required super.color,
    required super.x,
    required super.y,
    super.icono = FontAwesomeIcons.chessKing,
  });

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    return [];
  }
}
