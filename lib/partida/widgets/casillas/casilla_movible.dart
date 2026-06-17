import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CasillaMovible extends StatelessWidget {
  final int x;
  final int y;
  const CasillaMovible({super.key, required this.x, required this.y});

  @override
  Widget build(BuildContext context) {
    double medidaCasilla = MediaQuery.of(context).size.height / 8;

    return TapRegion( // Tap region para detectar toques dentro del area
      behavior: HitTestBehavior.opaque,  // Toda la casilla no solo el widget hijo, el "circulo", es clickeable
      onTapInside: (event) => BlocProvider.of<BlocPartida>(
        context,
      ).add(PartidaMoverPieza(coordenadas: (y, x))), // Al hacer click en la casilla movible, llama a moverpieza con las 
      // cordenadas del punto
      child: SizedBox( // El widget hijo, lo clickable mide toda una casilla y es un circulo con opacidad
        height: medidaCasilla,
        width: medidaCasilla,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(medidaCasilla * 0.35),
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
