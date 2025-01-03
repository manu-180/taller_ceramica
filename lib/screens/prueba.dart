import 'package:flutter/material.dart';
import 'package:taller_ceramica/utils/actualizar_fechas_database.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';


class Prueba extends StatelessWidget {
  const Prueba({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          ActualizarFechasDatabase().actualizarClasesAlNuevoMes("Lana's Taller", 2025);
        },
        child: const Icon(Icons.print),
      ),
    );
  }
}
