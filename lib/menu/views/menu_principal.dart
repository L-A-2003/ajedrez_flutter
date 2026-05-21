import 'dart:math';
import 'package:ajedrez_flutter/menu/bloc/bloc_aplicacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderFieldState> inputKey =
        GlobalKey<FormBuilderFieldState>();

    double medidaCasilla = MediaQuery.of(context).size.height / 8;

    double cantidadCasillasLargo =
        MediaQuery.of(context).size.width / medidaCasilla;

    int cantidadCasillasLargoEntero = cantidadCasillasLargo.floor();

    double largoCasillaLateral =
        medidaCasilla *
        ((cantidadCasillasLargo - cantidadCasillasLargoEntero) / 2);

    Map<(int, int), Widget> piezasAleatorias = generarPiezasAleatorias(
      cantidadCasillasLargoEntero,
      medidaCasilla,
    );

    return Stack(
      children: [
        Column(
          children: List.generate(8, (indexFila) {
            return Row(
              children: List.generate(cantidadCasillasLargoEntero + 2, (
                indexCasilla,
              ) {
                return Container(
                  height: medidaCasilla,
                  width:
                      (indexCasilla == 0 ||
                          indexCasilla == cantidadCasillasLargoEntero + 1)
                      ? largoCasillaLateral
                      : medidaCasilla,
                  color:
                      (indexFila.isEven && indexCasilla.isEven) ||
                          (indexFila.isOdd && indexCasilla.isOdd)
                      ? const Color(0xFFebecd0)
                      : const Color(0xFF739552),
                  child: piezasAleatorias.containsKey((indexFila, indexCasilla))
                      ? piezasAleatorias[(indexFila, indexCasilla)]
                      : SizedBox.shrink(),
                );
              }),
            );
          }),
        ),
        Center(
          child: Container(
            height: medidaCasilla * 4,
            width: medidaCasilla * 5,
            decoration: BoxDecoration(
              color: const Color(0xFFebecd0),
              border: Border.all(width: 5, color: const Color(0xFF739552)),
              boxShadow: [BoxShadow(spreadRadius: 4, blurRadius: 10)],
            ),
            child: Column(
              spacing: 10,
              children: [
                Text(
                  "Ajedrez",
                  style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
                ),

                FormBuilderTextField(key: inputKey, name: "duracion"),
                IconButton(
                  onPressed: () => BlocProvider.of<AplicacionBloc>(
                    context,
                  ).add(AplicacionIniciarPartida()),
                  icon: Icon(Icons.play_arrow),
                  iconSize: 100,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<(int, int), Widget> generarPiezasAleatorias(
    int maximoX,
    double medidaCasilla,
  ) {
    Map<(int, int), Widget> piezas = {};

    while (piezas.length < (maximoX * 8) / 3) {
      (int, int) coordenadaAleatoria = (
        Random().nextInt(9),
        Random().nextInt(maximoX - 1) + 1,
      );

      if (!piezas.containsKey(coordenadaAleatoria)) {
        late FaIconData icono;

        switch (Random().nextInt(6)) {
          case 0:
            icono = FontAwesomeIcons.chessPawn;
            break;
          case 1:
            icono = FontAwesomeIcons.chessKnight;
            break;
          case 2:
            icono = FontAwesomeIcons.chessBishop;
            break;
          case 3:
            icono = FontAwesomeIcons.chessQueen;
            break;
          case 4:
            icono = FontAwesomeIcons.chessKing;
            break;
          case 5:
            icono = FontAwesomeIcons.chessRook;
            break;
        }

        piezas[coordenadaAleatoria] = SizedBox(
          height: medidaCasilla,
          width: medidaCasilla,
          child: Center(
            child: FaIcon(
              icono,
              color: Random().nextBool() ? Colors.deepPurple : Colors.black,
              size: 48,
            ),
          ),
        );
      }
    }

    return piezas;
  }

  void validarDuracion() {}
}
