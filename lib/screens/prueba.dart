import 'package:flutter/material.dart';
import 'package:taller_ceramica/utils/actualizar_fechas_database.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';

import '../utils/utils_barril.dart';

class Prueba extends StatelessWidget {
  const Prueba({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final DateTime fechaInicio =
        DateTime(2024, 12, 30); // 2 de diciembre de 2024
    final DateTime fechaFin = DateTime(2025, 01, 31);
    final List<String> resultado =
        GenerarFechas().generarFechas(fechaInicio, fechaFin);

    return Scaffold(
      appBar: ResponsiveAppBar(isTablet: size.width > 600),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Prueba interna actualizada'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ActualizarFechasDatabase().actualizarClasesAlNuevoMes("Lana's Taller", 1, 2025);
        },
        child: const Icon(Icons.print),
      ),
    );
  }
}
