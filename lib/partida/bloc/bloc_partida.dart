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

// Estados de jugando, empate y ganador
// Solo se puede tener un estado a la vez, PartidaJugando es el que se actualiza constantemente.
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
    (int, int)?
    enPassantObjetivo; // la casilla a la que se va a mover el peon luego de en passant
    (int, int)? enPassantPeon; // El peon que se va a comer
    bool reyBlancoMovido = false;
    bool reyNegroMovido = false;
    bool torreBlancaIzqMovida = false;
    bool torreBlancaDerMovida = false;
    bool torreNegraIzqMovida = false;
    bool torreNegraDerMovida = false;

    on<PartidaIniciar>((event, emit) {
      // Crea el tablero inicial
      List<List<Pieza?>>
      tableroPiezas = // Crea el tablero tableroPirezas[0] devuelve la primera fila, tableroPiezas[0][0] devuelve la primera casilla de la primera fila
      List.generate(8, (indexColumna) {
        return List.generate // List.generate llama a una funcion de (cantidad valores, nombre, {funcion que se llama por cada valor})
        // En este caso se crean las indexColumna(Filas [Verticales]) y dentro de cada columna se crean las indexFila(Columnas [Horizontales])
        (8, (indexFila) {
          switch ((indexColumna, indexFila)) {
            // Luego en el switch se asigna la pieza correspondiente a cada casilla
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
      // Cambia el estado a PartidaJugando con el tablero inicializado
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
      // Actualiza el estado con las casillas movibles de la pieza seleccionada.
      // Para llamar a esta funcion ya se le pasa la pieza, sus coordenadas y sus movimientos posibles,
      // entonces solo se actualiza el estado.
      PartidaJugando estadoActual = state as PartidaJugando;

      if (event.pieza.color == estadoActual.turno) {
        List<(int, int)> movimientos = List.from(event.movimientosPosibles);
        // Si es un peon con un objetivo de en passant cercano, se agrega esa casilla.
        if (event.pieza is Peon && enPassantObjetivo != null) {
          int peonY = event.coordenadasPieza.$1;
          int peonX = event.coordenadasPieza.$2;
          int objetivoY = enPassantObjetivo!.$1;
          int objetivoX = enPassantObjetivo!.$2;

          int direccion = event.pieza.color == Tipo.blancas ? -1 : 1;
          bool columnaAdyacente =
              objetivoX == peonX - 1 || objetivoX == peonX + 1;
          bool filaCorrecta = objetivoY == peonY + direccion;

          if (columnaAdyacente && filaCorrecta) {
            movimientos.add((objetivoX, objetivoY));
          }
        }

        // Enroque
        if (event.pieza is Rey) {
          int reyY = event.coordenadasPieza.$1;
          int reyX = event.coordenadasPieza.$2;
          Tipo color = event.pieza.color;

          bool reyMovido = color == Tipo.blancas
              ? reyBlancoMovido
              : reyNegroMovido;

          if (!reyMovido && !reyEnJaque(reyY, reyX, color)) {
            bool torreDerMovida = color == Tipo.blancas
                ? torreBlancaDerMovida
                : torreNegraDerMovida;
            bool torreDerExiste = estadoActual.tableroPiezas[reyY][7] is Torre;

            if (!torreDerMovida &&
                torreDerExiste &&
                casillaLibreYSegura(
                  reyY,
                  5,
                  color,
                  estadoActual.tableroPiezas,
                ) &&
                casillaLibreYSegura(
                  reyY,
                  6,
                  color,
                  estadoActual.tableroPiezas,
                )) {
              movimientos.add((6, reyY));
            }
            bool torreIzqMovida = color == Tipo.blancas
                ? torreBlancaIzqMovida
                : torreNegraIzqMovida;
            bool torreIzqExiste = estadoActual.tableroPiezas[reyY][0] is Torre;
            if (!torreIzqMovida &&
                torreIzqExiste &&
                estadoActual.tableroPiezas[reyY][1] == null &&
                casillaLibreYSegura(
                  reyY,
                  2,
                  color,
                  estadoActual.tableroPiezas,
                ) &&
                casillaLibreYSegura(
                  reyY,
                  3,
                  color,
                  estadoActual.tableroPiezas,
                )) {
              movimientos.add((2, reyY));
            }
          }
        }

        // Solo se pueden ver los movimientos posibles de las piezas del turno actual
        List<List<CasillaMovible?>> tableroCasillasMovibles = [];

        // Solo actualiza si la pieza que se clickeo es diferente a la anterior
        if (event.coordenadasPieza != coordenadasPiezaSeleccionada) {
          tableroCasillasMovibles = List.generate(8, (indexColumna) {
            return List.generate(8, (indexFila) {
              if (movimientos.contains((
                // Compara cada elemento con movimientos posibles y si es
                // devuelve una casilla movible, sino devuelve null
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
      // Crea una copia del estado actual del juego.
      PartidaJugando estadoActual = state as PartidaJugando;
      List<List<Pieza?>> tableroPiezas = estadoActual.tableroPiezas
          .map((fila) => List<Pieza?>.from(fila))
          .toList();
      List<FaIconData> piezasNegrasComidas = List.from(
        estadoActual.piezasNegrasComidas,
      );
      List<FaIconData> piezasBlancasComidas = List.from(
        estadoActual.piezasBlancasComidas,
      );

      // Captura En passant
      bool esCapturaAlPaso =
          piezaSeleccionada is Peon &&
          enPassantObjetivo != null &&
          event.coordenadas == enPassantObjetivo &&
          tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] == null;

      if (esCapturaAlPaso) {
        FaIconData peonComido =
            (tableroPiezas[enPassantPeon!.$1][enPassantPeon!.$2] as Pieza)
                .icono;
        if (estadoActual.turno == Tipo.blancas) {
          piezasNegrasComidas.add(peonComido);
        } else {
          piezasBlancasComidas.add(peonComido);
        }
        tableroPiezas[enPassantPeon!.$1][enPassantPeon!.$2] = null;
      }
      // ---

      // Captura normal
      if (tableroPiezas[event.coordenadas.$1][event.coordenadas.$2] is Pieza) {
        // Si se come una pieza, añade el icono de
        // piezas comidas dependiendo de si se esta jugando com oblancas o negras
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
        // Genera una nueva pieza en el lugar donde se movio
        piezaSeleccionada as Pieza,
        event.coordenadas.$1,
        event.coordenadas.$2,
      );

      // Y elimina el original
      tableroPiezas[coordenadasPiezaSeleccionada
              .$1][coordenadasPiezaSeleccionada.$2] =
          null;

      // Cambiar estado primer movimiento de rey y torres
      int origenY = coordenadasPiezaSeleccionada.$1;
      int origenX = coordenadasPiezaSeleccionada.$2;
      if (piezaSeleccionada is Rey) {
        if (estadoActual.turno == Tipo.blancas) {
          reyBlancoMovido = true;
        } else {
          reyNegroMovido = true;
        }
      } else if (piezaSeleccionada is Torre) {
        if ((origenY, origenX) == (7, 0)) torreBlancaIzqMovida = true;
        if ((origenY, origenX) == (7, 7)) torreBlancaDerMovida = true;
        if ((origenY, origenX) == (0, 0)) torreNegraIzqMovida = true;
        if ((origenY, origenX) == (0, 7)) torreNegraDerMovida = true;
      }
      //--

      // Enroque
      bool esEnroque =
          piezaSeleccionada is Rey &&
          (event.coordenadas.$2 - coordenadasPiezaSeleccionada.$2).abs() == 2;

      if (esEnroque) {
        int fila = event.coordenadas.$1;
        bool haciaLaDerecha =
            event.coordenadas.$2 > coordenadasPiezaSeleccionada.$2;

        int columnaTorreOrigen = haciaLaDerecha ? 7 : 0;
        int columnaTorreDestino = haciaLaDerecha
            ? event.coordenadas.$2 - 1
            : event.coordenadas.$2 + 1;

        Pieza torre = tableroPiezas[fila][columnaTorreOrigen] as Pieza;
        tableroPiezas[fila][columnaTorreDestino] = generarPieza(
          torre,
          fila,
          columnaTorreDestino,
        );
        tableroPiezas[fila][columnaTorreOrigen] = null;
      }
      //--

      // Abilitar en passant para el enemigo
      bool esDoblePaso =
          piezaSeleccionada is Peon &&
          (event.coordenadas.$1 - coordenadasPiezaSeleccionada.$1).abs() == 2;

      if (esDoblePaso) {
        int filaIntermedia =
            (coordenadasPiezaSeleccionada.$1 + event.coordenadas.$1) ~/ 2;
        enPassantObjetivo = (filaIntermedia, event.coordenadas.$2);
        enPassantPeon = event.coordenadas;
      } else {
        enPassantObjetivo = null;
        enPassantPeon = null;
      }
      // --

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

    on<PartidaTiempoAgotado>((event, emit) {
      //Ver si es empate por material insuficiente o gana el contrario
    });
  }

  Pieza? generarPieza(Pieza pieza, int y, int x) {
    // Genera una pieza del mismo tipo que se le pasa pero en posicion diferente
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

  bool casillaLibreYSegura(
    int y,
    int x,
    Tipo colorRey,
    List<List<Pieza?>> tableroPiezas,
  ) {
    if (tableroPiezas[y][x] != null) return false;
    return !reyEnJaque(y, x, colorRey);
  }

  bool reyEnJaque(int y, int x, Tipo colorRey) {
    int yAuxiliar = y;
    int xAuxiliar = x;
    List<List<Pieza?>> tableroPiezas = (state as PartidaJugando).tableroPiezas;

    //---------------------------------------------------

    //Vertical hacia arriba
    if (y < 7) {
      while (yAuxiliar + 1 <= 7) {
        int resultado = buscarPieza(
          piezaAtacandoReyVerticalHorizontal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyVerticalHorizontal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyVerticalHorizontal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyVerticalHorizontal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyDiagonal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyDiagonal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyDiagonal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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
        int resultado = buscarPieza(
          piezaAtacandoReyDiagonal,
          tableroPiezas,
          yAuxiliar,
          xAuxiliar,
          colorRey,
        );

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

    if (x < 7 &&
        buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x + 1, colorRey) ==
            1) {
      return true;
    }

    if (x > 0 &&
        buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x - 1, colorRey) ==
            1) {
      return true;
    }

    return false;
  }

  int buscarPieza(
    bool Function(Pieza) funcionReyAtacado,
    List<List<Pieza?>> tableroPiezas,
    int y,
    int x,
    Tipo colorRey,
  ) {
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

  bool buscarPeon(
    int y,
    int x,
    List<List<Pieza?>> tableroPiezas,
    Tipo colorRey,
  ) {
    if (x > 0 &&
        buscarPieza(
              piezaAtacandoReyEsPeon,
              tableroPiezas,
              y,
              x - 1,
              colorRey,
            ) ==
            1) {
      return true;
    }

    if (x < 7 &&
        buscarPieza(
              piezaAtacandoReyEsPeon,
              tableroPiezas,
              y,
              x + 1,
              colorRey,
            ) ==
            1) {
      return true;
    }

    return false;
  }

  bool buscarCaballoVertical(
    int y,
    int x,
    List<List<Pieza?>> tableroPiezas,
    Tipo colorRey,
  ) {
    if (x > 0 &&
        buscarPieza(
              piezaAtacandoReyEsCaballo,
              tableroPiezas,
              y,
              x - 1,
              colorRey,
            ) ==
            1) {
      return true;
    }

    if (x < 7 &&
        buscarPieza(
              piezaAtacandoReyEsCaballo,
              tableroPiezas,
              y,
              x + 1,
              colorRey,
            ) ==
            1) {
      return true;
    }

    return false;
  }

  bool buscarCaballoHorizontal(
    int y,
    int x,
    List<List<Pieza?>> tableroPiezas,
    Tipo colorRey,
  ) {
    if (y > 0 &&
        buscarPieza(
              piezaAtacandoReyEsCaballo,
              tableroPiezas,
              y - 1,
              x,
              colorRey,
            ) ==
            1) {
      return true;
    }

    if (y < 7 &&
        buscarPieza(
              piezaAtacandoReyEsCaballo,
              tableroPiezas,
              y + 1,
              x,
              colorRey,
            ) ==
            1) {
      return true;
    }

    return false;
  }

  bool buscarReyVertical(
    int y,
    int x,
    List<List<Pieza?>> tableroPiezas,
    Tipo colorRey,
  ) {
    if (x > 0 &&
        buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x - 1, colorRey) ==
            1) {
      return true;
    }

    if (buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x, colorRey) ==
        1) {
      return true;
    }

    if (x < 7 &&
        buscarPieza(piezaAtacandoReyEsRey, tableroPiezas, y, x + 1, colorRey) ==
            1) {
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
    return pieza.runtimeType == Rey;
  }
}
