import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/gestion_clases_screen.dart';

class GestionClasesScreenIvanna extends StatelessWidget {
  const GestionClasesScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionDeClasesScreen(
      obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerClases(), 
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600 ), 
      generarIdClase: () => GenerarId().generarIdClase(), 
      agregarLugardisponible: (id) => ModificarLugarDisponible().agregarLugarDisponible(id), 
      removerLugardisponible: (id) => ModificarLugarDisponible().removerLugarDisponible(id),);
  }
}