import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Caballo extends Pieza {
  const Caballo({
    super.key,
    required super.x,
    required super.y,
    required super.color,
      super.icono = FontAwesomeIcons.chessKnight,
  });

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    return [];
  }
}
