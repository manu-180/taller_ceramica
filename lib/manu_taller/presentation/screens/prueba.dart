import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';



class PruebaManu extends StatelessWidget {
  const PruebaManu({super.key});




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final DateTime fechaInicio =
    //     DateTime(2024, 12, 2); // 2 de diciembre de 2024
    // final DateTime fechaFin = DateTime(2025, 1, 3);
    // final List<String> resultado = GenerarFechas().generarFechas(fechaInicio, fechaFin);
    

    return Scaffold(
      appBar: ResponsiveAppBarManu( isTablet: size.width > 600),
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
          context.push("/homemanu");
        },
        child: const Icon(Icons.print),
      ),
    );
  }
}
