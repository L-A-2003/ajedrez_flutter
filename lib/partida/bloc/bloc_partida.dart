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

  PartidaVerMovimientosPosibles({required this.pieza, required this.coordenadasPieza, required this.movimientosPosibles});
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

  PartidaJugando({required this.turno, required this.tableroPiezas, required this.piezasNegrasComidas, required this.piezasBlancasComidas, required this.tableroCasillasMovibles});
}

final class PartidaEmpate extends PartidaState {}

final class PartidaGanador extends PartidaState {
  final Tipo color;

  PartidaGanador({required this.color});
}

class BlocPartida extends Bloc<PartidaEvent, PartidaState> {
  BlocPartida() : super(PartidaJugando(turno: Tipo.blancas, tableroPiezas: [], piezasNegrasComidas: [], piezasBlancasComidas: [], tableroCasillasMovibles: [])) {
    Pieza? piezaSeleccionada;
    (int, int) coordenadasPiezaSeleccionada = (-1, -1);

    on<PartidaIniciar>((event, emit) {
      List<List<Pieza?>> tableroPiezas = List.generate(8, (indexColumna) {
        return List.generate(8, (indexFila) {
          switch ((indexColumna, indexFila)) {
            case (1, _):
            case (6, _):
              return Peon(color: indexColumna == 1 ? Tipo.negras : Tipo.blancas, x: indexFila, y: indexColumna, primerMovimiento: true);
            case (0, 0):
            case (0, 7):
            case (7, 0):
            case (7, 7):
              return Torre(color: indexColumna == 0 ? Tipo.negras : Tipo.blancas, x: indexFila, y: indexColumna);
            case (0, 1):
            case (0, 6):
            case (7, 1):
            case (7, 6):
              return Caballo(color: indexColumna == 0 ? Tipo.negras : Tipo.blancas, x: indexFila, y: indexColumna);
            case (0, 2):
            case (0, 5):
            case (7, 2):
            case (7, 5):
              return Alfil(color: indexColumna == 0 ? Tipo.negras : Tipo.blancas, x: indexFila, y: indexColumna);
            case (0, 3):
            case (7, 3):
              return Reina(color: indexColumna == 0 ? Tipo.negras : Tipo.blancas, x: indexFila, y: indexColumna);
            case (0, 4):
            case (7, 4):
              return Rey(color: indexColumna == 0 ? Tipo.negras : Tipo.blancas, x: indexFila, y: indexColumna);
          }

          return null;
        });
      });

      emit(PartidaJugando(turno: Tipo.blancas, piezasNegrasComidas: [], piezasBlancasComidas: [], tableroCasillasMovibles: [], tableroPiezas: tableroPiezas));
    });

    on<PartidaVerMovimientosPosibles>((event, emit) {
      PartidaJugando estadoActual = state as PartidaJugando;

      if (event.pieza.color == estadoActual.turno) {
        List<List<CasillaMovible?>> tableroCasillasMovibles = [];

        if (event.coordenadasPieza != coordenadasPiezaSeleccionada) {
          tableroCasillasMovibles = List.generate(8, (indexColumna) {
            return List.generate(8, (indexFila) {
              if (event.movimientosPosibles.contains((indexFila, indexColumna))) {
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
      List<FaIconData> piezasNegrasComidas = List.from(estadoActual.piezasNegrasComidas);
      List<FaIconData> piezasBlancasComidas = List.from(estadoActual.piezasBlancasComidas);

      if (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] is Pieza) {
        FaIconData piezaComida = (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] as Pieza).icono;

        if (estadoActual.turno == Tipo.blancas) {
          piezasNegrasComidas.add(piezaComida);
        } else {
          piezasBlancasComidas.add(piezaComida);
        }
      }

      tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] = generarPieza(piezaSeleccionada as Pieza, event.coordenadas.$1, event.coordenadas.$2);

      tableroPiezas[coordenadasPiezaSeleccionada.$1][coordenadasPiezaSeleccionada.$2] = null;

      emit(
        PartidaJugando(
          tableroPiezas: tableroPiezas,
          tableroCasillasMovibles: [],
          piezasBlancasComidas: piezasBlancasComidas,
          piezasNegrasComidas: piezasNegrasComidas,
          turno: estadoActual.turno == Tipo.blancas ? Tipo.negras : Tipo.blancas,
        ),
      );
    });

    on<PartidaTiempoAgotado>((event, emit) {
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

  bool reyEnJaque(int y, int x, Tipo colorRey) {
    int yAuxiliar = y;
    int xAuxiliar = x;
    List<List<Pieza?>> tableroPiezas = (state as PartidaJugando).tableroPiezas;

    //---------------------------------------------------

    //Vertical hacia arriba
    if (y < 7) {
      while (yAuxiliar + 1 <= 7) {
        int resultado = buscarPieza(piezaAtacandoReyVerticalHorizontal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        yAuxiliar++;
      }

      yAuxiliar = y;
    }

    //Vertical hacia abajo
    if (y > 0) {
      while (yAuxiliar - 1 >= 0) {
        int resultado = buscarPieza(piezaAtacandoReyVerticalHorizontal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        yAuxiliar--;
      }

      yAuxiliar = y;
    }

    //Horizontal hacia la derecha
    if (x < 7) {
      while (xAuxiliar + 1 <= 7) {
        int resultado = buscarPieza(piezaAtacandoReyVerticalHorizontal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        xAuxiliar++;
      }

      xAuxiliar = x;
    }

    //Horizontal hacia la izquierda
    if (x > 0) {
      while (xAuxiliar - 1 >= 0) {
        int resultado = buscarPieza(piezaAtacandoReyVerticalHorizontal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        xAuxiliar--;
      }
    }

    //---------------------------------------------------

    //Diagonal hacia arriba a la derecha
    if (y < 7 && x < 7) {
      yAuxiliar = y + 1;
      xAuxiliar = x + 1;

      while (yAuxiliar <= 7 && xAuxiliar <= 7) {
        int resultado = buscarPieza(piezaAtacandoReyDiagonal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        yAuxiliar++;
        xAuxiliar++;
      }
    }

    //Diagonal hacia arriba a la izquierda
    if (y < 7 && x > 0) {
      yAuxiliar = y + 1;
      xAuxiliar = x - 1;

      while (yAuxiliar <= 7 && xAuxiliar >= 0) {
        int resultado = buscarPieza(piezaAtacandoReyDiagonal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        yAuxiliar++;
        xAuxiliar--;
      }
    }

    //Diagonal hacia abajo a la derecha
    if (y > 0 && x < 7) {
      yAuxiliar = y - 1;
      xAuxiliar = x + 1;

      while (yAuxiliar >= 0 && xAuxiliar <= 7) {
        int resultado = buscarPieza(piezaAtacandoReyDiagonal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        yAuxiliar--;
        xAuxiliar++;
      }
    }

    //Diagonal hacia abajo a la izquierda
    if (y > 0 && x > 0) {
      yAuxiliar = y - 1;
      xAuxiliar = x - 1;

      while (yAuxiliar >= 0 && xAuxiliar >= 0) {
        int resultado = buscarPieza(piezaAtacandoReyDiagonal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        yAuxiliar--;
        xAuxiliar--;
      }
    }

    //---------------------------------------------------

    //Peones
    if (colorRey == Tipo.blancas) {
      if (y < 7 && buscarPeon(y + 1, x, tableroPiezas, colorRey)) {
        return true;
      }
    } else {
      if (y > 0 && buscarPeon(y - 1, x, tableroPiezas, colorRey)) {
        return true;
      }
    }

    //---------------------------------------------------

    //Caballos
    if (y < 6 && buscarCaballoVertical(y + 2, x, tableroPiezas, colorRey)) {
      return true;
    }

    if (y > 1 && buscarCaballoVertical(y - 2, x, tableroPiezas, colorRey)) {
      return true;
    }

    if (x < 6 && buscarCaballoHorizontal(y, x + 2, tableroPiezas, colorRey)) {
      return true;
    }

    if (x > 1 && buscarCaballoHorizontal(y, x - 2, tableroPiezas, colorRey)) {
      return true;
    }

    //---------------------------------------------------

    //Rey
    if (y < 7 && buscarReyVertical(y + 1, x, tableroPiezas, colorRey)) {
      return true;
    }

    if (y > 0 && buscarReyVertical(y - 1, x, tableroPiezas, colorRey)) {
      return true;
    }

    if (x < 7 && buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x + 1, colorRey) == 1) {
      return true;
    }

    if (x > 0 && buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x - 1, colorRey) == 1) {
      return true;
    }

    return false;
  }

  int buscarPieza(bool Function(Pieza) funcionReyAtacado, List<List<Pieza?>> tableroPiezas, int y, int x, Tipo colorRey) {
    /*
      0 = No esta en jaque
      1 = Esta en jaque
      2 = No encontro pieza, sigue buscando
    */
    if (tableroPiezas[y][x] != null) {
      Pieza pieza = tableroPiezas[y][x]!;

      if (pieza.color != colorRey) {
        return funcionReyAtacado(pieza) ? 1 : 0;
      } else {
        return 0;
      }
    }

    return 2;
  }

  bool buscarPeon(int y, int x, List<List<Pieza?>> tableroPiezas, Tipo colorRey) {
    if (x > 0 && buscarPieza(piezaAtacandoReyEsPeon, tableroPiezas, y, x - 1, colorRey) == 1) {
      return true;
    }

    if (x < 7 && buscarPieza(piezaAtacandoReyEsPeon, tableroPiezas, y, x + 1, colorRey) == 1) {
      return true;
    }

    return false;
  }

  bool buscarCaballoVertical(int y, int x, List<List<Pieza?>> tableroPiezas, Tipo colorRey) {
    if (x > 0 && buscarPieza(piezaAtacandoReyEsCaballo, tableroPiezas, y, x - 1, colorRey) == 1) {
      return true;
    }

    if (x < 7 && buscarPieza(piezaAtacandoReyEsCaballo, tableroPiezas, y, x + 1, colorRey) == 1) {
      return true;
    }

    return false;
  }

  bool buscarCaballoHorizontal(int y, int x, List<List<Pieza?>> tableroPiezas, Tipo colorRey) {
    if (y > 0 && buscarPieza(piezaAtacandoReyEsCaballo, tableroPiezas, y - 1, x, colorRey) == 1) {
      return true;
    }

    if (y < 7 && buscarPieza(piezaAtacandoReyEsCaballo, tableroPiezas, y + 1, x, colorRey) == 1) {
      return true;
    }

    return false;
  }

  bool buscarReyVertical(int y, int x, List<List<Pieza?>> tableroPiezas, Tipo colorRey) {
    if (x > 0 && buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x - 1, colorRey) == 1) {
      return true;
    }

    if (buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x, colorRey) == 1) {
      return true;
    }

    if (x < 7 && buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x + 1, colorRey) == 1) {
      return true;
    }

    return false;
  }

  bool piezaAtacandoReyVerticalHorizontal(Pieza pieza) {
    switch (pieza.runtimeType) {
      case const (Torre):
      case const (Reina):
        return true;
      default:
        return false;
    }
  }

  bool piezaAtacandoReyDiagonal(Pieza pieza) {
    switch (pieza.runtimeType) {
      case const (Alfil):
      case const (Reina):
        return true;
      default:
        return false;
    }
  }

  bool piezaAtacandoReyEsPeon(Pieza pieza) {
    return pieza.runtimeType == Peon;
  }

  bool piezaAtacandoReyEsCaballo(Pieza pieza) {
    return pieza.runtimeType == Caballo;
  }

  bool piezaAtacandoReyEsRey(Pieza pieza) {
    return pieza.runtimeType == Caballo;
  }
}
