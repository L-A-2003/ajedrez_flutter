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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

sealed class PartidaEvent {}

final class PartidaIniciar extends PartidaEvent {}

final class PartidaVerMovimientosPosibles extends PartidaEvent {
  final Pieza pieza;
  final (int, int) coordenadasPieza;
  final List<(int, int)> movimientosPosibles;

  PartidaVerMovimientosPosibles({
    required this.pieza,
    required this.coordenadasPieza,
    required this.movimientosPosibles,
  });
}

final class PartidaMoverPieza extends PartidaEvent {
  final (int, int) coordenadas;

  PartidaMoverPieza({required this.coordenadas});
}

final class PartidaTiempoAgotado extends PartidaEvent {
  final Tipo color;

  PartidaTiempoAgotado({required this.color});
}

sealed class PartidaState {}

final class PartidaJugando extends PartidaState {
  final Tipo turno;
  final List<List<Pieza?>> tableroPiezas;
  final List<FaIconData> piezasNegrasComidas;
  final List<FaIconData> piezasBlancasComidas;
  final List<List<CasillaMovible?>> tableroCasillasMovibles;

  PartidaJugando({
    required this.turno,
    required this.tableroPiezas,
    required this.piezasNegrasComidas,
    required this.piezasBlancasComidas,
    required this.tableroCasillasMovibles,
  });
}

final class PartidaEmpate extends PartidaState {}

final class PartidaGanador extends PartidaState {
  final Tipo color;

  PartidaGanador({required this.color});
}

class BlocPartida extends Bloc<PartidaEvent, PartidaState> {
  BlocPartida()
    : super(
        PartidaJugando(
          turno: Tipo.blancas,
          tableroPiezas: [],
          piezasNegrasComidas: [],
          piezasBlancasComidas: [],
          tableroCasillasMovibles: [],
        ),
      ) {
    Pieza? piezaSeleccionada;
    (int, int) coordenadasPiezaSeleccionada = (-1, -1);

    on<PartidaIniciar>((event, emit) {
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
        PartidaJugando(
          turno: Tipo.blancas,
          piezasNegrasComidas: [],
          piezasBlancasComidas: [],
          tableroCasillasMovibles: [],
          tableroPiezas: tableroPiezas,
        ),
      );
    });

    on<PartidaVerMovimientosPosibles>((event, emit) {
      PartidaJugando estadoActual = state as PartidaJugando;

      if (event.pieza.color == estadoActual.turno) {
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
          PartidaJugando(
            turno: estadoActual.turno,
            tableroPiezas: estadoActual.tableroPiezas,
            tableroCasillasMovibles: tableroCasillasMovibles,
            piezasNegrasComidas: estadoActual.piezasNegrasComidas,
            piezasBlancasComidas: estadoActual.piezasBlancasComidas,
          ),
        );
      }
    });

    on<PartidaMoverPieza>((event, emit) {
      PartidaJugando estadoActual = state as PartidaJugando;

      List<List<Pieza?>> tableroPiezas = List.from(estadoActual.tableroPiezas);
      List<FaIconData> piezasNegrasComidas = List.from(
        estadoActual.piezasNegrasComidas,
      );
      List<FaIconData> piezasBlancasComidas = List.from(
        estadoActual.piezasBlancasComidas,
      );

      if (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] is Pieza) {
        FaIconData piezaComida =
            (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] as Pieza)
                .icono;

        if (estadoActual.turno == Tipo.blancas) {
          piezasNegrasComidas.add(piezaComida);
        } else {
          piezasBlancasComidas.add(piezaComida);
        }
      }

      tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] = generarPieza(
        piezaSeleccionada as Pieza,
        event.coordenadas.$1,
        event.coordenadas.$2,
      );

      tableroPiezas[coordenadasPiezaSeleccionada
              .$1][coordenadasPiezaSeleccionada.$2] =
          null;

      emit(
        PartidaJugando(
          tableroPiezas: tableroPiezas,
          tableroCasillasMovibles: [],
          piezasBlancasComidas: piezasBlancasComidas,
          piezasNegrasComidas: piezasNegrasComidas,
          turno: estadoActual.turno == Tipo.blancas
              ? Tipo.negras
              : Tipo.blancas,
        ),
      );
    });
  
    on<PartidaTiempoAgotado>((event, emit){
      //Ver si es empate por material insuficiente o gana el contrario
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
