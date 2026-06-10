import 'dart:async';

import 'package:ajedrez_flutter/enums.dart';
import 'package:ajedrez_flutter/partida/bloc/bloc_partida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Lateral extends StatefulWidget {
  final Tipo color;
  final int duracion;
  const Lateral({super.key, required this.color, required this.duracion});

  @override
  State<Lateral> createState() => _LateralState();
}

class _LateralState extends State<Lateral> {
  late Timer temporizador;
  late int minutos = widget.duracion;

  int segundos = 0;

  @override
  void initState() {
    temporizador = Timer.periodic(const Duration(seconds: 1), (timer) {
      PartidaState estadoPartida = BlocProvider.of<BlocPartida>(context).state;

      if (estadoPartida is PartidaJugando) {
        if (estadoPartida.turno == widget.color) {
          setState(() {
            if (segundos == 0) {
              minutos--;

              if (minutos == -1) {
                minutos = 0;

                BlocProvider.of<BlocPartida>(context).add(PartidaTiempoAgotado(color: widget.color));
                timer.cancel();
              } else {
                segundos = 59;
              }
            } else {
              segundos--;
            }
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double anchoLateral = (MediaQuery.of(context).size.height - MediaQuery.of(context).size.width) / 2;

    String minutosFormateados = minutos < 10 ? "0$minutos" : minutos.toString();
    String segundosFormateados = segundos < 10 ? "0$segundos" : segundos.toString();

    return Container(
      height: anchoLateral,
      color: Colors.black87,
      child: Align(
        child: Container(
          height: anchoLateral * 0.9,
          decoration: BoxDecoration(boxShadow: [BoxShadow(spreadRadius: 4, blurRadius: 10)], color: const Color.fromARGB(255, 59, 59, 59)),
          child: Column(
            verticalDirection: widget.color == Tipo.blancas ? VerticalDirection.up : VerticalDirection.down,
            spacing: 5,
            children: [
              Text("$minutosFormateados : $segundosFormateados", style: GoogleFonts.rubik(color: Colors.white70, fontSize: 48)),
              BlocSelector<BlocPartida, PartidaState, List<FaIconData>>(
                selector: (state) {
                  return state is PartidaJugando ? (widget.color == Tipo.blancas ? state.piezasNegrasComidas : state.piezasBlancasComidas) : [];
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: AlignmentGeometry.topLeft,
                      child: SizedBox(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 5,
                          runSpacing: 5,
                          direction: Axis.horizontal,
                          children: List.generate(state.length, (index) => FaIcon(state[index], color: Colors.white70, size: 32)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
