import 'dart:math';
import 'package:ajedrez_flutter/constantes.dart' as constantes;
import 'package:ajedrez_flutter/menu/bloc/bloc_aplicacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final int cantidadCasillasAlto = 8;
  final int maximoCasillasHorizontal = 50;
  final GlobalKey<FormBuilderFieldState> inputKey = GlobalKey<FormBuilderFieldState>(); // GlobalKey para el campo de texto

  late int cantidadCasillasLargoEntero;
  late double largoCasillaLateral;
  late double medidaCasilla; // Calcula la medida de la casilla basada en la altura de la pantalla
  late Map<(int, int), Widget> piezasAleatorias;

  bool primeraVez = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        medidaCasilla = MediaQuery.of(context).size.height / cantidadCasillasAlto;

        double cantidadCasillasLargo = MediaQuery.of(context).size.width / medidaCasilla;

        cantidadCasillasLargoEntero = cantidadCasillasLargo.floor();

        if (cantidadCasillasLargoEntero > maximoCasillasHorizontal) {
          cantidadCasillasLargoEntero = maximoCasillasHorizontal;
        }

        primeraVez = false;
        largoCasillaLateral = medidaCasilla * ((cantidadCasillasLargo - cantidadCasillasLargoEntero) / 2);
        piezasAleatorias = generarPiezasAleatorias(cantidadCasillasLargoEntero, medidaCasilla);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (primeraVez) {
      return SizedBox.shrink();
    }

    return Stack(
      // Stack para superponer el tablero y el menu
      children: [
        Column(
          //  El primer column es el tablero, que aparece debajo del menu
          children: List.generate(8, (indexFila) {
            // Es una columna con 8 filas. Cada fila es un Row con las casillas.
            return Row(
              children: List.generate(cantidadCasillasLargoEntero + 2, (indexCasilla) {
                return Container(
                  // Este container es cada casilla del tablero.
                  height: medidaCasilla,
                  width: (indexCasilla == 0 || indexCasilla == cantidadCasillasLargoEntero + 1) ? largoCasillaLateral : medidaCasilla,
                  color: (indexFila.isEven && indexCasilla.isEven) || (indexFila.isOdd && indexCasilla.isOdd) ? constantes.TemaAjedrez.casillaClara : constantes.TemaAjedrez.casillaOscura,
                  child:
                      piezasAleatorias.containsKey((indexFila, indexCasilla)) // Esto muestra una pieza en la casilla
                      ? piezasAleatorias[(indexFila, indexCasilla)]
                      : SizedBox.shrink(),
                );
              }),
            );
          }),
        ),
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final anchoCartel = (constraints.maxWidth * 0.7).clamp(280.0, 450.0);
              final altoCartel = (constraints.maxHeight * 0.6).clamp(300.0, 500.0);

              return Container(
                width: anchoCartel,
                height: altoCartel,
                decoration: BoxDecoration(
                  color: constantes.TemaAjedrez.casillaClara,
                  border: Border.all(width: 5, color: constantes.TemaAjedrez.casillaOscura),
                  boxShadow: [BoxShadow(spreadRadius: 4, blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text("Ajedrez", style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: FormBuilderTextField(
                        key: inputKey,
                        initialValue: "10",
                        name: "duracion",
                        textAlign: TextAlign.center,
                        validator: FormBuilderValidators.positiveNumber(errorText: "Ingrese una duración válida"),
                        decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Duración", floatingLabelAlignment: FloatingLabelAlignment.center),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: IconButton(onPressed: () => iniciarPartida(context, inputKey), icon: Icon(Icons.play_arrow), iconSize: 100),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Map<(int, int), Widget> generarPiezasAleatorias(
    // Devuelve un mapa con coordenadas y piezas aleatorias para mostrar en el tablero
    int cantidadCasillasHorizontal,
    double medidaCasilla,
  ) {
    Map<(int, int), Widget> piezas = {};

    while (piezas.length < (cantidadCasillasHorizontal * cantidadCasillasAlto) / 3) {
      (int, int) coordenadaAleatoria = (Random().nextInt(cantidadCasillasAlto), Random().nextInt(cantidadCasillasHorizontal) + 1);

      if (!piezas.containsKey(coordenadaAleatoria)) {
        late FaIconData icono;

        switch (Random().nextInt(6)) {
          case 0:
            icono = FontAwesomeIcons.chessPawn;
            break;
          case 1:
            icono = FontAwesomeIcons.chessKnight;
            break;
          case 2:
            icono = FontAwesomeIcons.chessBishop;
            break;
          case 3:
            icono = FontAwesomeIcons.chessQueen;
            break;
          case 4:
            icono = FontAwesomeIcons.chessKing;
            break;
          case 5:
            icono = FontAwesomeIcons.chessRook;
            break;
        }

        piezas[coordenadaAleatoria] = SizedBox(
          height: medidaCasilla,
          width: medidaCasilla,
          child: Center(child: FaIcon(icono, color: Random().nextBool() ? constantes.TemaAjedrez.piezaBlancas : constantes.TemaAjedrez.piezaNegras, size: 48)),
        );
      }
    }

    return piezas;
  }

  void iniciarPartida(BuildContext context, GlobalKey<FormBuilderFieldState> inputKey) {
    inputKey.currentState!.save();

    if (inputKey.currentState!.validate()) {
      BlocProvider.of<BlocAplicacion>(context).add(AplicacionIniciarPartida(duracion: int.parse(inputKey.currentState!.value)));
    }
  }
}
