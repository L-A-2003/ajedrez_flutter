import 'package:ajedrez_flutter/menu/bloc/bloc_aplicacion.dart';
import 'package:ajedrez_flutter/menu/views/menu_principal.dart';
import 'package:ajedrez_flutter/partida/views/partida.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // BlocProvider crea el bloc de la aplicacion
      home: BlocProvider(
        create: (context) => BlocAplicacion(),
        // Todos los child de este BlocProvider van a poder acceder al bloc de la aplicacion, y escuchar sus cambios de estado
        child: Builder(
          // Se utiliza un builder para que el context este por debajo del BlocProvider, y asi poder acceder al bloc desde el context
          builder: (context) {
            return Scaffold(
              // Scaffold es base de la app
              body: Center(
                // Solo utilizamos body, y lo centramos
                child: BlocBuilder<BlocAplicacion, AplicacionState>(
                  builder: (context, state) {
                    // BlocBuilder escucha los cambios de estado del bloc de la aplicacion
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
