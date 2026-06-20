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
// Eventos para iniciar la partida, ver movimientos posibles, mover pieza y tiempo agotado

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

// Estados de jugando, empate y ganador
final class PartidaJugando extends PartidaState {
  final Tipo turno;
  final bool reyEnJaque;
  final List<List<Pieza?>> tableroPiezas;
  final List<FaIconData> piezasNegrasComidas;
  final List<FaIconData> piezasBlancasComidas;
  final List<List<CasillaMovible?>> tableroCasillasMovibles;

  PartidaJugando({
    required this.turno,
    required this.reyEnJaque,
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
  BlocPartida() : super(PartidaJugando(turno: Tipo.blancas, reyEnJaque: false, tableroPiezas: [], piezasNegrasComidas: [], piezasBlancasComidas: [], tableroCasillasMovibles: [])) {
    Pieza? piezaSeleccionada;
    (int, int) coordenadasPiezaSeleccionada = (-1, -1);

    on<PartidaIniciar>((event, emit) {
      List<List<Pieza?>> tableroPiezas = // Crea el tablero tableroPirezas[0] devuelve la primera fila, tableroPiezas[0][0] devuelve la primera casilla de la primera fila
      List.generate(8, (indexColumna) {
        return List.generate // List.generate llama a una funcion de (cantidad valores, nombre, {funcion que se llama por cada valor})
        // En este caso se crean las indexColumna(Filas [Verticales]) y dentro de cada columna se crean las indexFila(Columnas [Horizontales])
        (8, (indexFila) {
          switch ((indexColumna, indexFila)) {
            // Luego en el switch se asigna la pieza correspondiente a cada casilla
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
      // Cambia el estado a PartidaJugando con el tablero inicializado
      emit(PartidaJugando(turno: Tipo.blancas, reyEnJaque: false, piezasNegrasComidas: [], piezasBlancasComidas: [], tableroCasillasMovibles: [], tableroPiezas: tableroPiezas));
    });

    on<PartidaVerMovimientosPosibles>((event, emit) {
      PartidaJugando estadoActual = state as PartidaJugando;

      if (event.pieza.color == estadoActual.turno) {
        // Solo se pueden ver los movimientos posibles de las piezas del turno actual
        List<List<CasillaMovible?>> tableroCasillasMovibles = [];

        // Solo actualiza si la pieza que se clickeo es diferente a la anterior
        if (event.coordenadasPieza != coordenadasPiezaSeleccionada) {
          List<(int, int)> movimientosPosiblesReales = generarMovimientosPosiblesReales(event.movimientosPosibles, estadoActual.tableroPiezas, event.pieza, true);

          tableroCasillasMovibles = List.generate(8, (indexColumna) {
            return List.generate(8, (indexFila) {
              if (movimientosPosiblesReales.contains((indexFila, indexColumna))) {
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
            reyEnJaque: estadoActual.reyEnJaque,
            tableroPiezas: estadoActual.tableroPiezas,
            tableroCasillasMovibles: tableroCasillasMovibles,
            piezasNegrasComidas: estadoActual.piezasNegrasComidas,
            piezasBlancasComidas: estadoActual.piezasBlancasComidas,
          ),
        );
      }
    });

    on<PartidaMoverPieza>((event, emit) {
      bool empate = false;
      bool piezaComida = false;
      PartidaJugando estadoActual = state as PartidaJugando;

      List<List<Pieza?>> tableroPiezas = List.from(estadoActual.tableroPiezas);
      List<FaIconData> piezasNegrasComidas = List.from(estadoActual.piezasNegrasComidas);
      List<FaIconData> piezasBlancasComidas = List.from(estadoActual.piezasBlancasComidas);

      if (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] is Pieza) {
        piezaComida = true;

        FaIconData iconoPiezaComida = (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] as Pieza).icono;

        if (estadoActual.turno == Tipo.blancas) {
          piezasNegrasComidas.add(iconoPiezaComida);
        } else {
          piezasBlancasComidas.add(iconoPiezaComida);
        }
      }

      tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] = generarPieza(piezaSeleccionada as Pieza, event.coordenadas.$1, event.coordenadas.$2);
      tableroPiezas[coordenadasPiezaSeleccionada.$1][coordenadasPiezaSeleccionada.$2] = null;

      if (piezaComida) {
        empate = tieneMaterialInsuficiente(Tipo.blancas) && tieneMaterialInsuficiente(Tipo.negras);
      }

      //TODO: Falta revisar si el rey esta ahogado, en ese caso tambien se empata

      if (empate) {
        emit(PartidaEmpate());
      } else {
        Tipo colorTurnoSiguiente = estadoActual.turno == Tipo.blancas ? Tipo.negras : Tipo.blancas;
        (int, int) coordenadasRey = obtenerCoordenadasRey(colorTurnoSiguiente, tableroPiezas);

        bool jaqueMate = false;
        bool jaque = reyEnJaque(coordenadasRey.$2, coordenadasRey.$1, colorTurnoSiguiente);

        if (jaque) {
          jaqueMate = reyEnJaqueMate(coordenadasRey.$2, coordenadasRey.$1, colorTurnoSiguiente, tableroPiezas);
        }

        if (jaqueMate) {
          emit(PartidaGanador(color: estadoActual.turno));
        } else {
          emit(
            PartidaJugando(
              reyEnJaque: jaque,
              turno: colorTurnoSiguiente,
              tableroCasillasMovibles: [],
              tableroPiezas: tableroPiezas,
              piezasBlancasComidas: piezasBlancasComidas,
              piezasNegrasComidas: piezasNegrasComidas,
            ),
          );
        }
      }
    });

    on<PartidaTiempoAgotado>((event, emit) {
      Tipo colorOponente = event.color == Tipo.blancas ? Tipo.negras : Tipo.blancas;

      if (tieneMaterialInsuficiente(colorOponente)) {
        emit(PartidaEmpate());
      } else {
        emit(PartidaGanador(color: colorOponente));
      }
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

  bool reyEnJaque(int y, int x, Tipo colorRey, {List<List<Pieza?>>? tableroPiezasAlternativo}) {
    int yAuxiliar = y;
    int xAuxiliar = x;
    List<List<Pieza?>> tableroPiezas = tableroPiezasAlternativo ?? (state as PartidaJugando).tableroPiezas;

    //---------------------------------------------------

    //Vertical hacia abajo
    if (y < 7) {
      yAuxiliar = y + 1;

      while (yAuxiliar <= 7) {
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

    //Vertical hacia arriba
    if (y > 0) {
      yAuxiliar = y - 1;

      while (yAuxiliar >= 0) {
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
      xAuxiliar = x + 1;

      while (xAuxiliar <= 7) {
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
      xAuxiliar = x - 1;

      while (xAuxiliar >= 0) {
        int resultado = buscarPieza(piezaAtacandoReyVerticalHorizontal, tableroPiezas, yAuxiliar, xAuxiliar, colorRey);

        if (resultado == 0) {
          break;
        } else if (resultado == 1) {
          return true;
        }

        xAuxiliar--;
      }

      xAuxiliar = x;
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

  List<(int, int)> generarMovimientosPosiblesReales(List<(int, int)> movimientosPosibles, List<List<Pieza?>> tableroPiezas, Pieza pieza, bool tenerEnCuentaJaque) {
    List<(int, int)> movimientosPosiblesReales = [];
    (int, int) coordenadasRey = obtenerCoordenadasRey(pieza.color, tableroPiezas);

    switch (pieza.runtimeType) {
      case const (Peon):
        if (pieza.x < 7) {
          if (casillaValida(tableroPiezas, movimientosPosibles.first.$2, pieza.x + 1, pieza.color) == 1) {
            movimientosPosiblesReales.add((pieza.x + 1, movimientosPosibles.first.$2));
          }
        }
        if (pieza.x > 0) {
          if (casillaValida(tableroPiezas, movimientosPosibles.first.$2, pieza.x - 1, pieza.color) == 1) {
            movimientosPosiblesReales.add((pieza.x - 1, movimientosPosibles.first.$2));
          }
        }

        while (movimientosPosibles.isNotEmpty) {
          (int, int) movimiento = movimientosPosibles.first;
          int valorCasilla = casillaValida(tableroPiezas, movimiento.$2, movimiento.$1, pieza.color);

          if (valorCasilla == 2) {
            movimientosPosiblesReales.add(movimiento);
            movimientosPosibles.removeAt(0);
          } else {
            movimientosPosibles.clear();
          }
        }
        break;
      case const (Caballo):
        for ((int, int) movimiento in movimientosPosibles) {
          if (casillaValida(tableroPiezas, movimiento.$2, movimiento.$1, pieza.color) != 0) {
            movimientosPosiblesReales.add(movimiento);
          }
        }
        break;
      default:
        movimientosPosiblesReales = generarMovimientosPosiblesRealesTorreAlfilReinaRey(movimientosPosibles, tableroPiezas, pieza);
        break;
    }

    if (tenerEnCuentaJaque) {
      List<(int, int)> movimientosPosiblesRealesSinJaque = [];

      for ((int, int) movimiento in movimientosPosiblesReales) {
        List<List<Pieza?>> tableroPiezasAlternativo = generarCopiaTablero(tableroPiezas);

        tableroPiezasAlternativo[pieza.y][pieza.x] = null;
        tableroPiezasAlternativo[movimiento.$2][movimiento.$1] = generarPieza(pieza, movimiento.$2, movimiento.$1);

        late int y;
        late int x;

        if (pieza.runtimeType == Rey) {
          y = movimiento.$2;
          x = movimiento.$1;
        } else {
          y = coordenadasRey.$2;
          x = coordenadasRey.$1;
        }

        if (!reyEnJaque(y, x, pieza.color, tableroPiezasAlternativo: tableroPiezasAlternativo)) {
          movimientosPosiblesRealesSinJaque.add(movimiento);
        }
      }

      return movimientosPosiblesRealesSinJaque;
    } else {
      return movimientosPosiblesReales;
    }
  }

  List<(int, int)> generarMovimientosPosiblesRealesTorreAlfilReinaRey(List<(int, int)> movimientosPosibles, List<List<Pieza?>> tableroPiezas, Pieza pieza) {
    List<(int, int)> movimientosPosiblesReales = [];

    List<(int, int)> movimientosPosiblesArriba = [];
    List<(int, int)> movimientosPosiblesAbajo = [];
    List<(int, int)> movimientosPosiblesIzquierda = [];
    List<(int, int)> movimientosPosiblesDerecha = [];

    List<(int, int)> movimientosPosiblesArribaIzquierda = [];
    List<(int, int)> movimientosPosiblesArribaDerecha = [];
    List<(int, int)> movimientosPosiblesAbajoIzquierda = [];
    List<(int, int)> movimientosPosiblesAbajoDerecha = [];

    switch (pieza.runtimeType) {
      case const (Torre):
        movimientosPosiblesArriba = movimientosPosibles.where((element) => element.$2 < pieza.y).toList();
        movimientosPosiblesAbajo = movimientosPosibles.where((element) => element.$2 > pieza.y).toList();
        movimientosPosiblesIzquierda = movimientosPosibles.where((element) => element.$1 < pieza.x).toList();
        movimientosPosiblesDerecha = movimientosPosibles.where((element) => element.$1 > pieza.x).toList();
        break;
      case const (Alfil):
        movimientosPosiblesArribaIzquierda = movimientosPosibles.where((element) => element.$2 < pieza.y && element.$1 < pieza.x).toList();
        movimientosPosiblesArribaDerecha = movimientosPosibles.where((element) => element.$2 < pieza.y && element.$1 > pieza.x).toList();
        movimientosPosiblesAbajoIzquierda = movimientosPosibles.where((element) => element.$2 > pieza.y && element.$1 < pieza.x).toList();
        movimientosPosiblesAbajoDerecha = movimientosPosibles.where((element) => element.$2 > pieza.y && element.$1 > pieza.x).toList();
        break;
      case const (Rey):
      case const (Reina):
        movimientosPosiblesArriba = movimientosPosibles.where((element) => element.$2 < pieza.y && element.$1 == pieza.x).toList();
        movimientosPosiblesAbajo = movimientosPosibles.where((element) => element.$2 > pieza.y && element.$1 == pieza.x).toList();
        movimientosPosiblesIzquierda = movimientosPosibles.where((element) => element.$1 < pieza.x && element.$2 == pieza.y).toList();
        movimientosPosiblesDerecha = movimientosPosibles.where((element) => element.$1 > pieza.x && element.$2 == pieza.y).toList();

        movimientosPosibles.removeWhere((element) => [...movimientosPosiblesArriba, ...movimientosPosiblesAbajo, ...movimientosPosiblesIzquierda, ...movimientosPosiblesDerecha].contains(element));

        movimientosPosiblesArribaIzquierda = movimientosPosibles.where((element) => element.$2 < pieza.y && element.$1 < pieza.x).toList();
        movimientosPosiblesArribaDerecha = movimientosPosibles.where((element) => element.$2 < pieza.y && element.$1 > pieza.x).toList();
        movimientosPosiblesAbajoIzquierda = movimientosPosibles.where((element) => element.$2 > pieza.y && element.$1 < pieza.x).toList();
        movimientosPosiblesAbajoDerecha = movimientosPosibles.where((element) => element.$2 > pieza.y && element.$1 > pieza.x).toList();
        break;
    }

    List<List<(int, int)>> movimientos = [
      movimientosPosiblesArriba,
      movimientosPosiblesAbajo,
      movimientosPosiblesIzquierda,
      movimientosPosiblesDerecha,
      movimientosPosiblesArribaIzquierda,
      movimientosPosiblesArribaDerecha,
      movimientosPosiblesAbajoIzquierda,
      movimientosPosiblesAbajoDerecha,
    ];

    while (movimientos.isNotEmpty) {
      List<(int, int)> movimientosDireccionales = movimientos.first;

      while (movimientosDireccionales.isNotEmpty) {
        (int, int) movimiento = movimientosDireccionales.first;
        int valorCasilla = casillaValida(tableroPiezas, movimiento.$2, movimiento.$1, pieza.color);

        if (valorCasilla != 0) {
          bool valido = true;

          if (pieza.runtimeType == Rey) {
            if (reyEnJaque(movimiento.$2, movimiento.$1, pieza.color)) {
              valido = false;
            }
          }

          if (valido) {
            movimientosPosiblesReales.add(movimiento);
          }
        }

        if (valorCasilla == 2) {
          movimientosDireccionales.removeAt(0);
        } else {
          movimientosDireccionales.clear();
        }
      }

      movimientos.removeAt(0);
    }

    return movimientosPosiblesReales;
  }

  int casillaValida(List<List<Pieza?>> tableroPiezas, int y, int x, Tipo colorPieza) {
    /*
      0 = Pieza aliada o rey enemigo
      1 = Pieza enemiga
      2 = No encontro pieza, sigue buscando
    */

    if (tableroPiezas[y][x] != null) {
      Pieza pieza = tableroPiezas[y][x]!;

      if (pieza.color != colorPieza) {
        if (pieza.runtimeType != Rey) {
          return 1;
        }
      }

      return 0;
    }

    return 2;
  }

  (int, int) obtenerCoordenadasRey(Tipo color, List<List<Pieza?>> tableroPiezas) {
    for (List<Pieza?> columna in tableroPiezas) {
      for (Pieza? pieza in columna) {
        if (pieza != null && pieza.runtimeType == Rey && pieza.color == color) {
          return (pieza.x, pieza.y);
        }
      }
    }

    return (-1, -1);
  }

  bool reyEnJaqueMate(int y, int x, Tipo color, List<List<Pieza?>> tableroPiezas) {
    List<Pieza> piezas = [];

    for (List<Pieza?> columna in tableroPiezas) {
      for (Pieza? pieza in columna) {
        if (pieza != null && pieza.runtimeType != Rey && pieza.color == color) {
          piezas.add(pieza);
        }
      }
    }

    for (Pieza pieza in piezas) {
      List<(int, int)> movimientosPosiblesReales = generarMovimientosPosiblesReales(pieza.obtenerPosiblesMovimientos(), tableroPiezas, pieza, false);

      for ((int, int) movimiento in movimientosPosiblesReales) {
        List<List<Pieza?>> tableroPiezasAlternativo = generarCopiaTablero(tableroPiezas);

        tableroPiezasAlternativo[pieza.y][pieza.x] = null;
        tableroPiezasAlternativo[movimiento.$2][movimiento.$1] = generarPieza(pieza, movimiento.$2, movimiento.$1);

        if (!reyEnJaque(y, x, color, tableroPiezasAlternativo: tableroPiezasAlternativo)) {
          return false;
        }
      }
    }

    return true;
  }

  List<List<Pieza?>> generarCopiaTablero(List<List<Pieza?>> tableroPiezas) {
    List<List<Pieza?>> copiaTablero = [];

    for (List<Pieza?> columna in tableroPiezas) {
      copiaTablero.add(List.from(columna));
    }

    return copiaTablero;
  }

  bool tieneMaterialInsuficiente(Tipo color) {
    List<Pieza> piezas = [];
    bool materialInsuficiente = true;

    for (List<Pieza?> columna in (state as PartidaJugando).tableroPiezas) {
      for (Pieza? pieza in columna) {
        if (pieza != null && pieza.color == color) {
          piezas.add(pieza);
        }
      }
    }

    if (piezas.length > 1) {
      bool tieneAlfil = false;
      bool tieneCaballo = false;

      for (Pieza pieza in piezas) {
        if ([Torre, Reina, Peon].contains(pieza.runtimeType)) {
          materialInsuficiente = false;
          break;
        } else {
          if (pieza.runtimeType == Alfil) {
            tieneAlfil = true;
          } else if (pieza.runtimeType == Caballo) {
            tieneCaballo = true;
          }

          if (tieneAlfil && tieneCaballo) {
            materialInsuficiente = false;
            break;
          }
        }
      }
    }

    return materialInsuficiente;
  }
}
