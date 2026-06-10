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
      child: Column(
        children: [
          Lateral(duracion: duracion, color: Tipo.negras),
          Tablero(),
          Lateral(duracion: duracion, color: Tipo.blancas),
        ],
      ),
    );
  }
}
