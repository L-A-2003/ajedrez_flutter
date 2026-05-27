import 'package:ajedrez_flutter/menu/bloc/bloc_aplicacion.dart';
import 'package:ajedrez_flutter/menu/views/menu_principal.dart';
import 'package:ajedrez_flutter/partida/views/partida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => AplicacionBloc(),
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: BlocBuilder<AplicacionBloc, AplicacionState>(
                  builder: (context, state) {
                    switch (state) {
                      case AplicacionEsperando():
                        return MenuPrincipal();
                      case AplicacionJugando():
                        return Partida(duracion: state.duracion);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
