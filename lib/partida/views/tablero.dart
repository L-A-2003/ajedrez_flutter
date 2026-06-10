import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:ajedrez_flutter/partida/widgets/casillas/casilla_movible.dart';
import 'package:ajedrez_flutter/partida/widgets/casillas/casilla_vacia.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Tablero extends StatelessWidget {
  const Tablero({super.key});

  @override
  Widget build(BuildContext context) {
    double medidaTablero = MediaQuery.of(context).size.width;
    double medidaCasilla = medidaTablero / 8;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: [BoxShadow(spreadRadius: 4, blurRadius: 10)]),
          height: medidaTablero,
          width: medidaTablero,
          child: Column(
            children: List.generate(8, (indexFila) {
              return Row(
                children: List.generate(8, (indexCasilla) {
                  return Container(
                    height: medidaCasilla,
                    width: medidaCasilla,
                    color: (indexFila.isEven && indexCasilla.isEven) || (indexFila.isOdd && indexCasilla.isOdd) ? const Color(0xFFebecd0) : const Color(0xFF739552),
                  );
                }),
              );
            }),
          ),
        ),
        SizedBox(
          height: medidaTablero,
          width: medidaTablero,
          child: BlocSelector<BlocPartida, PartidaState, List<List<Pieza?>>>(
            selector: (state) => state is PartidaJugando ? state.tableroPiezas : [],
            builder: (context, state) {
              if (state.isNotEmpty) {
                return Column(
                  children: List.generate(8, (indexFila) {
                    return Row(
                      children: List.generate(8, (indexCasilla) {
                        return state[indexFila][indexCasilla] ?? CasillaVacia();
                      }),
                    );
                  }),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
        SizedBox(
          height: medidaTablero,
          width: medidaTablero,
          child: BlocSelector<BlocPartida, PartidaState, List<List<CasillaMovible?>>>(
            selector: (state) => state is PartidaJugando ? state.tableroCasillasMovibles : [],
            builder: (context, state) {
              if (state.isNotEmpty) {
                return Column(
                  children: List.generate(8, (indexFila) {
                    return Row(
                      children: List.generate(8, (indexCasilla) {
                        return state[indexFila][indexCasilla] ?? CasillaVacia();
                      }),
                    );
                  }),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}
