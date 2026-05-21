import 'package:ajedrez_flutter/enums.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/alfil.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/caballo.dart';
import 'package:ajedrez_flutter/partida/widgets/casillas/casilla_movible.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/peon.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/pieza.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/reina.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/rey.dart';
import 'package:ajedrez_flutter/partida/widgets/piezas/torre.dart';
import 'package:bloc/bloc.dart';

sealed class TableroEvent {}

final class IniciarTablero extends TableroEvent {}

final class VerMovimientosPosiblesTablero extends TableroEvent {
  final Pieza pieza;
  final (int, int) coordenadasPieza;
  final List<(int, int)> movimientosPosibles;

  VerMovimientosPosiblesTablero({
    required this.pieza,
    required this.coordenadasPieza,
    required this.movimientosPosibles,
  });
}

final class MoverPiezaTablero extends TableroEvent {
  final (int, int) coordenadas;

  MoverPiezaTablero({required this.coordenadas});
}

final class EstadoTablero {
  final List<List<Pieza?>> tableroPiezas;
  final List<List<CasillaMovible?>> tableroCasillasMovibles;
  final Tipo turno;

  EstadoTablero({
    required this.tableroPiezas,
    required this.tableroCasillasMovibles,
    required this.turno,
  });
}

class BlocTablero extends Bloc<TableroEvent, EstadoTablero> {
  BlocTablero()
    : super(
        EstadoTablero(
          tableroPiezas: [],
          tableroCasillasMovibles: [],
          turno: Tipo.blancas,
        ),
      ) {
    Pieza? piezaSeleccionada;
    (int, int) coordenadasPiezaSeleccionada = (-1, -1);

    on<IniciarTablero>((event, emit) {
      List<List<Pieza?>> tableroPiezas = List.generate(8, (indexColumna) {
        return List.generate(8, (indexFila) {
          switch ((indexColumna, indexFila)) {
            case (1, _):
            case (6, _):
              return Peon(
                color: indexColumna == 1 ? Tipo.negras : Tipo.blancas,
                x: indexFila,
                y: indexColumna,
                primerMovimiento: true,
              );
            case (0, 0):
            case (0, 7):
            case (7, 0):
            case (7, 7):
              return Torre(
                color: indexColumna == 0 ? Tipo.negras : Tipo.blancas,
                x: indexFila,
                y: indexColumna,
              );
            case (0, 1):
            case (0, 6):
            case (7, 1):
            case (7, 6):
              return Caballo(
                color: indexColumna == 0 ? Tipo.negras : Tipo.blancas,
                x: indexFila,
                y: indexColumna,
              );
            case (0, 2):
            case (0, 5):
            case (7, 2):
            case (7, 5):
              return Alfil(
                color: indexColumna == 0 ? Tipo.negras : Tipo.blancas,
                x: indexFila,
                y: indexColumna,
              );
            case (0, 3):
            case (7, 3):
              return Reina(
                color: indexColumna == 0 ? Tipo.negras : Tipo.blancas,
                x: indexFila,
                y: indexColumna,
              );
            case (0, 4):
            case (7, 4):
              return Rey(
                color: indexColumna == 0 ? Tipo.negras : Tipo.blancas,
                x: indexFila,
                y: indexColumna,
              );
          }

          return null;
        });
      });

      emit(
        EstadoTablero(
          tableroPiezas: tableroPiezas,
          tableroCasillasMovibles: [],
          turno: Tipo.blancas,
        ),
      );
    });

    on<VerMovimientosPosiblesTablero>((event, emit) {
      if (event.pieza.color == state.turno) {
        List<List<CasillaMovible?>> tableroCasillasMovibles = [];

        if (event.coordenadasPieza != coordenadasPiezaSeleccionada) {
          tableroCasillasMovibles = List.generate(8, (indexColumna) {
            return List.generate(8, (indexFila) {
              if (event.movimientosPosibles.contains((
                indexFila,
                indexColumna,
              ))) {
                return CasillaMovible(x: indexFila, y: indexColumna);
              } else {
                return null;
              }
            });
          });
          piezaSeleccionada = event.pieza;
          coordenadasPiezaSeleccionada = event.coordenadasPieza;
        } else {
          piezaSeleccionada = null;
          coordenadasPiezaSeleccionada = (-1, -1);
        }

        emit(
          EstadoTablero(
            tableroPiezas: state.tableroPiezas,
            tableroCasillasMovibles: tableroCasillasMovibles,
            turno: state.turno,
          ),
        );
      }
    });

    on<MoverPiezaTablero>((event, emit) {
      List<List<Pieza?>> tableroPiezas = List.from(state.tableroPiezas);
      tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] = generarPieza(
        piezaSeleccionada as Pieza,
        event.coordenadas.$1,
        event.coordenadas.$2,
      );

      tableroPiezas[coordenadasPiezaSeleccionada
              .$1][coordenadasPiezaSeleccionada.$2] =
          null;

      emit(
        EstadoTablero(
          tableroPiezas: tableroPiezas,
          tableroCasillasMovibles: [],
          turno: state.turno == Tipo.blancas ? Tipo.negras : Tipo.blancas,
        ),
      );
    });
  }

  Pieza? generarPieza(Pieza pieza, int y, int x) {
    switch (pieza.runtimeType) {
      case const (Peon):
        return Peon(color: pieza.color, x: x, y: y);
      case const (Torre):
        return Torre(color: pieza.color, x: x, y: y);
      case const (Caballo):
        return Caballo(color: pieza.color, x: x, y: y);
      case const (Alfil):
        return Alfil(color: pieza.color, x: x, y: y);
      case const (Reina):
        return Reina(color: pieza.color, x: x, y: y);
      case const (Rey):
        return Rey(color: pieza.color, x: x, y: y);
    }

    return null;
  }
}
