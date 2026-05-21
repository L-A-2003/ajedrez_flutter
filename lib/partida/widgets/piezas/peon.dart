import 'package:ajedrez_flutter/enums.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Peon extends Pieza {
  final bool primerMovimiento;

  const Peon({
    super.key,
    required super.color,
    required super.x,
    required super.y,
    this.primerMovimiento = false,
    super.icono = FontAwesomeIcons.chessPawn,
  });

  @override
  List<(int, int)> obtenerPosiblesMovimientos() {
    List<(int, int)> posiblesMovimientos = [
      color == Tipo.blancas ? (x, y - 1) : (x, y + 1),
    ];

    if (primerMovimiento) {
      posiblesMovimientos.add(color == Tipo.blancas ? (x, y - 2) : (x, y + 2));
    }

    return posiblesMovimientos;
  }
}
