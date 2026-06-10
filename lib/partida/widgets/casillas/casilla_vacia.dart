import 'package:flutter/material.dart';

class CasillaVacia extends StatelessWidget {
  const CasillaVacia({super.key});

  @override
  Widget build(BuildContext context) {
    double medidaCasilla = MediaQuery.of(context).size.width / 8;

    return SizedBox(height: medidaCasilla, width: medidaCasilla);
  }
}
