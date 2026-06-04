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
  final posibles = <(int, int)>[
    (x + 1, y + 2),
    (x + 1, y - 2),
    (x - 1, y + 2),
    (x - 1, y - 2),
    (x + 2, y + 1),
    (x + 2, y - 1),
    (x - 2, y + 1),
    (x - 2, y - 1),
  ];

  return posibles.where((movimiento) {
    return movimiento.$1 >= 0 &&
           movimiento.$1 < 8 &&
           movimiento.$2 >= 0 &&
           movimiento.$2 < 8;
  }).toList();

}
}