import 'package:ajedrez_flutter/partida/bloc/bloc_tablero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CasillaMovible extends StatelessWidget {
  final int x;
  final int y;
  const CasillaMovible({super.key, required this.x, required this.y});

  @override
  Widget build(BuildContext context) {
    double medidaCasilla = MediaQuery.of(context).size.height / 8;

    return TapRegion(
      behavior: HitTestBehavior.translucent,
      onTapInside: (event) => BlocProvider.of<BlocTablero>(
        context,
      ).add(MoverPiezaTablero(coordenadas: (y, x))),
      child: SizedBox(
        height: medidaCasilla,
        width: medidaCasilla,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(45),
            child: Opacity(
              opacity: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
