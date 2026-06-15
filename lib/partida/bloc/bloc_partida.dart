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
      PartidaJugando estadoActual = state as PartidaJugando;

      if (event.pieza.color == estadoActual.turno) {
        // Solo se pueden ver los movimientos posibles de las piezas del turno actual
        List<List<CasillaMovible?>> tableroCasillasMovibles = [];

        // Determinar si el rey del turno actual está en jaque
        final reyCoords = obtenerCoordenadasRey(estadoActual.turno);
        final estaEnJaque = reyCoords != (-1, -1)
            ? reyEnJaque(reyCoords.$1, reyCoords.$2, estadoActual.turno)
            : false;

        if (estaEnJaque && !tieneMovimientosLegales(estadoActual.turno, estadoActual.tableroPiezas)) {
          final ganador = estadoActual.turno == Tipo.blancas ? Tipo.negras : Tipo.blancas;
          emit(PartidaGanador(color: ganador));
          return;
        }

        // Solo actualiza si la pieza que se clickeo es diferente a la anterior
        if (event.coordenadasPieza != coordenadasPiezaSeleccionada) {
          final srcY = event.coordenadasPieza.$1;
          final srcX = event.coordenadasPieza.$2;
          final movimientosLegales = obtenerMovimientosLegales(
            event.pieza,
            srcX,
            srcY,
            estadoActual.tableroPiezas,
          );

          // Si está en jaque, filtrar los movimientos que solucionen el jaque.
          List<(int, int)> movimientosFiltrados = [];

          if (estaEnJaque) {
            for (final mov in movimientosLegales) {
              List<List<Pieza?>> copiaTablero = List.generate(8, (i) => List<Pieza?>.from(estadoActual.tableroPiezas[i]));
              final dstX = mov.$1;
              final dstY = mov.$2;

              copiaTablero[dstY][dstX] = generarPieza(event.pieza, dstY, dstX);
              copiaTablero[srcY][srcX] = null;

              final reyPos = event.pieza.runtimeType == Rey
                  ? (dstY, dstX)
                  : obtenerCoordenadasRey(estadoActual.turno, tabla: copiaTablero);

              if (!reyEnJaque(reyPos.$1, reyPos.$2, estadoActual.turno, copiaTablero)) {
                movimientosFiltrados.add(mov);
              }
            }
          } else {
            movimientosFiltrados = movimientosLegales;
          }

          tableroCasillasMovibles = List.generate(8, (indexColumna) {
            return List.generate(8, (indexFila) {
              if (movimientosFiltrados.contains((
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

      if (piezaSeleccionada == null || coordenadasPiezaSeleccionada == (-1, -1)) {
        return;
      }

      final srcY = coordenadasPiezaSeleccionada.$1;
      final srcX = coordenadasPiezaSeleccionada.$2;
      final dstY = event.coordenadas.$1;
      final dstX = event.coordenadas.$2;

      final movimientosLegales = obtenerMovimientosLegales(
        piezaSeleccionada as Pieza,
        srcX,
        srcY,
        estadoActual.tableroPiezas,
      );

      if (!movimientosLegales.contains((dstX, dstY))) {
        emit(
          PartidaJugando(
            turno: estadoActual.turno,
            tableroPiezas: estadoActual.tableroPiezas,
            tableroCasillasMovibles: [],
            piezasNegrasComidas: estadoActual.piezasNegrasComidas,
            piezasBlancasComidas: estadoActual.piezasBlancasComidas,
          ),
        );
        return;
      }

      // Simular movimiento y validar que no deje el rey en jaque
      List<List<Pieza?>> copiaTablero = List.generate(8, (i) => List<Pieza?>.from(estadoActual.tableroPiezas[i]));
      copiaTablero[dstY][dstX] = generarPieza(piezaSeleccionada as Pieza, dstY, dstX);
      copiaTablero[srcY][srcX] = null;

      final movingColor = estadoActual.turno;
      final reyPos = piezaSeleccionada!.runtimeType == Rey
          ? (dstY, dstX)
          : obtenerCoordenadasRey(movingColor, tabla: copiaTablero);

      if (reyEnJaque(reyPos.$1, reyPos.$2, movingColor, copiaTablero)) {
        // Movimiento ilegal porque deja/permanece en jaque: cancelar selección
        emit(
          PartidaJugando(
            turno: estadoActual.turno,
            tableroPiezas: estadoActual.tableroPiezas,
            tableroCasillasMovibles: [],
            piezasNegrasComidas: estadoActual.piezasNegrasComidas,
            piezasBlancasComidas: estadoActual.piezasBlancasComidas,
          ),
        );
        return;
      }

      // Preparar listas de piezas comidas
      List<FaIconData> piezasNegrasComidas = List.from(estadoActual.piezasNegrasComidas);
      List<FaIconData> piezasBlancasComidas = List.from(estadoActual.piezasBlancasComidas);

      final Pieza? piezaCapturada = estadoActual.tableroPiezas[dstY][dstX];
      final bool capturoRey = piezaCapturada is Rey && piezaCapturada.color != estadoActual.turno;

      if (piezaCapturada is Pieza) {
        if (estadoActual.turno == Tipo.blancas) {
          piezasNegrasComidas.add(piezaCapturada.icono);
        } else {
          piezasBlancasComidas.add(piezaCapturada.icono);
        }
      }

      // Aplicar el movimiento en el tablero real
      List<List<Pieza?>> nuevoTablero = List.generate(8, (i) => List<Pieza?>.from(estadoActual.tableroPiezas[i]));
      nuevoTablero[dstY][dstX] = generarPieza(piezaSeleccionada as Pieza, dstY, dstX);
      nuevoTablero[srcY][srcX] = null;

      final nuevoTurno = estadoActual.turno == Tipo.blancas ? Tipo.negras : Tipo.blancas;
      final ganador = estadoActual.turno;

      emit(
        PartidaJugando(
          tableroPiezas: nuevoTablero,
          tableroCasillasMovibles: [],
          piezasBlancasComidas: piezasBlancasComidas,
          piezasNegrasComidas: piezasNegrasComidas,
          turno: nuevoTurno,
        ),
      );

      piezaSeleccionada = null;
      coordenadasPiezaSeleccionada = (-1, -1);

      if (capturoRey) {
        emit(PartidaGanador(color: ganador));
        return;
      }

      // Detectar jaque mate: si el rival está en jaque y no tiene movimientos legales
      final coordenadasReyRival = obtenerCoordenadasRey(nuevoTurno, tabla: nuevoTablero);
      if (coordenadasReyRival == (-1, -1)) {
        emit(PartidaGanador(color: ganador));
        return;
      }

      if (reyEnJaque(coordenadasReyRival.$1, coordenadasReyRival.$2, nuevoTurno, nuevoTablero)) {
        final rivalTieneMovimientos = tieneMovimientosLegales(nuevoTurno, nuevoTablero);
        if (!rivalTieneMovimientos) {
          emit(PartidaGanador(color: ganador));
        }
      }
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

  (int, int) obtenerCoordenadasRey(Tipo color, {List<List<Pieza?>>? tabla}) {
    final tablero = tabla ?? (state as PartidaJugando).tableroPiezas;

    for (int fila = 0; fila < 8; fila++) {
      for (int col = 0; col < 8; col++) {
        final p = tablero[fila][col];
        if (p != null && p.runtimeType == Rey && p.color == color) {
          return (fila, col);
        }
      }
    }

    return (-1, -1);
  }

  bool estaDentro(int x, int y) {
    return x >= 0 && x < 8 && y >= 0 && y < 8;
  }

  bool esPiezaAliada(int x, int y, Tipo color, List<List<Pieza?>> tablero) {
    return tablero[y][x] != null && tablero[y][x]!.color == color;
  }

  bool esPiezaEnemiga(int x, int y, Tipo color, List<List<Pieza?>> tablero) {
    return tablero[y][x] != null && tablero[y][x]!.color != color;
  }

  List<(int, int)> obtenerMovimientosLegales(
    Pieza pieza,
    int srcX,
    int srcY,
    List<List<Pieza?>> tablero,
  ) {
    final color = pieza.color;
    final List<(int, int)> movimientos = [];

    if (pieza is Peon) {
      final int direccion = color == Tipo.blancas ? -1 : 1;
      final int pasoUnoY = srcY + direccion;
      final int pasoDosY = srcY + direccion * 2;

      if (estaDentro(srcX, pasoUnoY) && tablero[pasoUnoY][srcX] == null) {
        movimientos.add((srcX, pasoUnoY));
        if (pieza.primerMovimiento && estaDentro(srcX, pasoDosY) && tablero[pasoDosY][srcX] == null) {
          movimientos.add((srcX, pasoDosY));
        }
      }

      for (final dstX in [srcX - 1, srcX + 1]) {
        if (estaDentro(dstX, pasoUnoY) && esPiezaEnemiga(dstX, pasoUnoY, color, tablero)) {
          movimientos.add((dstX, pasoUnoY));
        }
      }

      return movimientos;
    }

    if (pieza is Caballo) {
      final posibles = [
        (srcX + 2, srcY + 1),
        (srcX + 2, srcY - 1),
        (srcX - 2, srcY + 1),
        (srcX - 2, srcY - 1),
        (srcX + 1, srcY + 2),
        (srcX + 1, srcY - 2),
        (srcX - 1, srcY + 2),
        (srcX - 1, srcY - 2),
      ];

      for (final mov in posibles) {
        if (!estaDentro(mov.$1, mov.$2)) continue;
        if (!esPiezaAliada(mov.$1, mov.$2, color, tablero)) {
          movimientos.add(mov);
        }
      }

      return movimientos;
    }

    if (pieza is Rey) {
      final posibles = [
        (srcX + 1, srcY),
        (srcX - 1, srcY),
        (srcX, srcY + 1),
        (srcX, srcY - 1),
        (srcX + 1, srcY + 1),
        (srcX + 1, srcY - 1),
        (srcX - 1, srcY + 1),
        (srcX - 1, srcY - 1),
      ];

      for (final mov in posibles) {
        if (!estaDentro(mov.$1, mov.$2)) continue;
        if (!esPiezaAliada(mov.$1, mov.$2, color, tablero)) {
          movimientos.add(mov);
        }
      }

      return movimientos;
    }

    List<(int, int)> direcciones = [];
    if (pieza is Torre || pieza is Reina) {
      direcciones.addAll([
        (1, 0),
        (-1, 0),
        (0, 1),
        (0, -1),
      ]);
    }
    if (pieza is Alfil || pieza is Reina) {
      direcciones.addAll([
        (1, 1),
        (1, -1),
        (-1, 1),
        (-1, -1),
      ]);
    }

    for (final dir in direcciones) {
      int siguienteX = srcX + dir.$1;
      int siguienteY = srcY + dir.$2;

      while (estaDentro(siguienteX, siguienteY)) {
        if (esPiezaAliada(siguienteX, siguienteY, color, tablero)) {
          break;
        }

        movimientos.add((siguienteX, siguienteY));

        if (esPiezaEnemiga(siguienteX, siguienteY, color, tablero)) {
          break;
        }

        siguienteX += dir.$1;
        siguienteY += dir.$2;
      }
    }

    return movimientos;
  }

  bool tieneMovimientosLegales(Tipo color, List<List<Pieza?>> tablero) {
    for (int fila = 0; fila < 8; fila++) {
      for (int col = 0; col < 8; col++) {
        final p = tablero[fila][col];
        if (p != null && p.color == color) {
          final movimientos = obtenerMovimientosLegales(p, col, fila, tablero);
          for (final mov in movimientos) {
            final copia = List.generate(8, (i) => List<Pieza?>.from(tablero[i]));
            final dstX = mov.$1;
            final dstY = mov.$2;
            copia[dstY][dstX] = generarPieza(p, dstY, dstX);
            copia[fila][col] = null;

            final reyPos = p.runtimeType == Rey
                ? (dstY, dstX)
                : obtenerCoordenadasRey(color, tabla: copia);

            if (!reyEnJaque(reyPos.$1, reyPos.$2, color, copia)) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  bool reyEnJaque(int y, int x, Tipo colorRey, [List<List<Pieza?>>? tableroPiezas]) {
    int yAuxiliar = y;
    int xAuxiliar = x;
    List<List<Pieza?>> tablero = tableroPiezas ?? (state as PartidaJugando).tableroPiezas;

    //---------------------------------------------------

    //Vertical hacia arriba
    if (y < 7) {
      while (yAuxiliar + 1 <= 7) {
        int resultado = buscarPieza(
          piezaAtacandoReyVerticalHorizontal,
          tablero,
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
          tablero,
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
          tablero,
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
          tablero,
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
          tablero,
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
          tablero,
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
          tablero,
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
          tablero,
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
      if (y < 7 && buscarPeon(y + 1, x, tablero, colorRey)) {
        return true;
      }
    } else {
      if (y > 0 && buscarPeon(y - 1, x, tablero, colorRey)) {
        return true;
      }
    }

    //---------------------------------------------------

    //Caballos
    if (y < 6 && buscarCaballoVertical(y + 2, x, tablero, colorRey)) {
      return true;
    }

    if (y > 1 && buscarCaballoVertical(y - 2, x, tablero, colorRey)) {
      return true;
    }

    if (x < 6 && buscarCaballoHorizontal(y, x + 2, tablero, colorRey)) {
      return true;
    }

    if (x > 1 && buscarCaballoHorizontal(y, x - 2, tablero, colorRey)) {
      return true;
    }

    //---------------------------------------------------

    //Rey
    if (y < 7 && buscarReyVertical(y + 1, x, tablero, colorRey)) {
      return true;
    }

    if (y > 0 && buscarReyVertical(y - 1, x, tablero, colorRey)) {
      return true;
    }

    if (x < 7 &&
        buscarPieza(piezaAtacandoReyEsRey, tablero, y, x + 1, colorRey) ==
            1) {
      return true;
    }

    if (x > 0 &&
        buscarPieza(piezaAtacandoReyEsRey, tablero, y, x - 1, colorRey) ==
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
