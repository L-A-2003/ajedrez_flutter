import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Rey extends Pieza {
  final bool movido;

  const Rey({super.key, this.movido = false, required super.color, required super.x, required super.y, super.icono = FontAwesomeIcons.chessKing});

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    final posibles = <(int, int)>[(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1), (x + 1, y + 1), (x + 1, y - 1), (x - 1, y + 1), (x - 1, y - 1)];

    return posibles.where((movimiento) {
      return movimiento.$1 >= 0 && movimiento.$1 < 8 && movimiento.$2 >= 0 && movimiento.$2 < 8;
    }).toList();
  }
}
