import 'package:ajedrez_flutter/enums.dart';
import 'package:ajedrez_flutter/menu/bloc/bloc_aplicacion.dart';
import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:ajedrez_flutter/partida/views/lateral.dart';
import 'package:ajedrez_flutter/partida/views/tablero.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/alfil.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/caballo.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/reina.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/torre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Partida extends StatelessWidget {
  final int duracion;

  const Partida({super.key, required this.duracion}); // Se crea el constructor que recibe la duracion de la partida

  @override
  Widget build(BuildContext context) {
    final BlocPartida blocPartida = BlocPartida();
    bool reyEnJaque = false;

    return BlocProvider(
      create: (context) => blocPartida..add(PartidaIniciar()),
      child: BlocListener<BlocPartida, PartidaState>(
        listener: (context, state) {
          switch (state) {
            case PartidaJugando():
              if (state.reyEnJaque != reyEnJaque) {
                reyEnJaque = state.reyEnJaque;

                if (reyEnJaque) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Rey en jaque!"), duration: Duration(seconds: 1)));
                }
              }
              break;
            case PartidaEmpate():
              break;
            case PartidaGanador():
              cartelGanador(context, BlocProvider.of<BlocAplicacion>(context), state.color);
              break;
            case PartidaPeonLlegoFinal():
              cartelPeonLlegoFinal(context, blocPartida, state.coordenadas);
              break;
          }
        },
        child: Column(
          children: [
            Lateral(duracion: duracion, color: Tipo.negras),
            Tablero(),
            Lateral(duracion: duracion, color: Tipo.blancas),
          ],
        ),
      ),
    );
  }

  Future<void> cartelGanador(BuildContext context, BlocAplicacion blocAplicacion, Tipo color) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Victoria!"),
        content: Text(color == Tipo.blancas ? "Blancas ganan" : "Negras ganan", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () {
              blocAplicacion.add(AplicacionFinalizoPartida());
              Navigator.of(context).pop();
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  Future<void> cartelPeonLlegoFinal(BuildContext context, BlocPartida blocPartida, (int, int) coordenadas) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: FaIcon(FontAwesomeIcons.chessPawn)),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                blocPartida.add(PartidaTransformarPeon(pieza: Alfil, coordenadas: coordenadas));
              },
              icon: FaIcon(FontAwesomeIcons.chessBishop),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                blocPartida.add(PartidaTransformarPeon(pieza: Caballo, coordenadas: coordenadas));
              },
              icon: FaIcon(FontAwesomeIcons.chessKnight),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                blocPartida.add(PartidaTransformarPeon(pieza: Torre, coordenadas: coordenadas));
              },
              icon: FaIcon(FontAwesomeIcons.chessRook),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                blocPartida.add(PartidaTransformarPeon(pieza: Reina, coordenadas: coordenadas));
              },
              icon: FaIcon(FontAwesomeIcons.chessQueen),
            ),
          ],
        ),
      ),
    );
  }
}
