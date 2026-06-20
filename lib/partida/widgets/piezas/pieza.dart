import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:ajedrez_flutter/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

abstract class Pieza extends StatelessWidget {
  final int x;
  final int y;
  final Tipo color;
  final FaIconData icono;

  const Pieza({super.key, required this.x, required this.y, required this.color, required this.icono});

  List<(int, int)> obtenerPosiblesMovimientos();

  @protected
  List<(int, int)> obtenerPosiblesMovimientosVerticalesHorizontales() {
    List<(int, int)> movimientos = [];

    for (int i = y - 1; i >= 0; i--) {
      movimientos.add((x, i));
    }

    for (int i = y + 1; i < 8; i++) {
      movimientos.add((x, i));
    }

    for (int i = x - 1; i >= 0; i--) {
      movimientos.add((i, y));
    }

    for (int i = x + 1; i < 8; i++) {
      movimientos.add((i, y));
    }

    return movimientos;
  }

  @protected
  List<(int, int)> obtenerPosiblesMovimientosDiagonales() {
    List<(int, int)> movimientos = [];

    for (int i = 1; x - i >= 0 && y - i >= 0; i++) {
      movimientos.add((x - i, y - i));
    }

    for (int i = 1; x + i < 8 && y - i >= 0; i++) {
      movimientos.add((x + i, y - i));
    }

    for (int i = 1; x - i >= 0 && y + i < 8; i++) {
      movimientos.add((x - i, y + i));
    }

    for (int i = 1; x + i < 8 && y + i < 8; i++) {
      movimientos.add((x + i, y + i));
    }

    return movimientos;
  }

  @override
  Widget build(BuildContext context) {
    double medidaCasilla = MediaQuery.of(context).size.width / 8;

    return TapRegion(
      behavior: HitTestBehavior.translucent,
      onTapInside: (event) => BlocProvider.of<BlocPartida>(context).add(PartidaVerMovimientosPosibles(pieza: this, coordenadasPieza: (y, x), movimientosPosibles: obtenerPosiblesMovimientos())),
      child: SizedBox(
        height: medidaCasilla,
        width: medidaCasilla,
        child: Center(child: FaIcon(icono, color: color == Tipo.blancas ? Colors.deepPurple : Colors.black, size: 36)),
      ),
    );
  }
}
