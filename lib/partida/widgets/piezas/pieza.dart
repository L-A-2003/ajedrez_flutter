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

  const Pieza({
    super.key,
    required this.x,
    required this.y,
    required this.color,
    required this.icono,
  });

  List<(int, int)> obtenerPosiblesMovimientos();

  @protected
  List<(int, int)> obtenerPosiblesMovimientosVerticalesHorizontales() {
    return [];
  }

  @protected
  List<(int, int)> obtenerPosiblesMovimientosDiagonales() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    double medidaCasilla = MediaQuery.of(context).size.height / 8;

    return TapRegion(
      behavior: HitTestBehavior.translucent,
      onTapInside: (event) => BlocProvider.of<BlocPartida>(context).add(
        PartidaVerMovimientosPosibles(
          pieza: this,
          coordenadasPieza: (y, x),
          movimientosPosibles: obtenerPosiblesMovimientos(),
        ),
      ),
      child: SizedBox(
        height: medidaCasilla,
        width: medidaCasilla,
        child: Center(
          child: FaIcon(
            icono,
            color: color == Tipo.blancas ? Colors.deepPurple : Colors.black,
            size: 48,
          ),
        ),
      ),
    );
  }
}
