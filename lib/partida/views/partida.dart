import 'package:ajedrez_flutter/enums.dart';
import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:ajedrez_flutter/partida/views/lateral.dart';
import 'package:ajedrez_flutter/partida/views/tablero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Partida extends StatelessWidget {
  final int duracion;

  const Partida({
    super.key,
    required this.duracion,
  }); // Se crea el constructor que recibe la duracion de la partida

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlocPartida()..add(PartidaIniciar()),
      child: BlocListener<BlocPartida, PartidaState>(
        listener: (context, state) {
          if (state is PartidaGanador) {
            final ganador = state.color == Tipo.blancas ? 'Blancas' : 'Negras';
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('¡Victoria!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ganador,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '¡Jaque mate! Has ganado la partida. Felicitaciones por la excelente jugada.',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          }
        },
        child: Row(
          children: [
            Lateral(duracion: duracion, color: Tipo.blancas),
            Tablero(),
            Lateral(duracion: duracion, color: Tipo.negras),
          ],
        ),
      ),
    );
  }
}
