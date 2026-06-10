import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CasillaMovible extends StatelessWidget {
  final int x;
  final int y;
  const CasillaMovible({super.key, required this.x, required this.y});

  @override
  Widget build(BuildContext context) {
    double medidaCasilla = MediaQuery.of(context).size.width / 8;

    return TapRegion(
      behavior: HitTestBehavior.opaque,
      onTapInside: (event) => BlocProvider.of<BlocPartida>(
        context,
      ).add(PartidaMoverPieza(coordenadas: (y, x))),
      child: SizedBox(
        height: medidaCasilla,
        width: medidaCasilla,
        child: Center(
          child: Opacity(
            opacity: 0.3,
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
