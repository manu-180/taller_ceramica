import 'package:flutter/material.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/gestion_clases_screen.dart';

class GestionClasesScreenManu extends StatelessWidget {
  const GestionClasesScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionDeClasesScreen(
      obtenerClases: () => ObtenerTotalInfoManu().obtenerClaseManu(), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600 ), 
      generarIdClase: () => GenerarIdManu().generarIdClaseManu(), 
      agregarLugardisponible: (id) => ModificarLugarDisponibleManu().agregarLugarDisponibleManu(id), 
      removerLugardisponible: (id) => ModificarLugarDisponibleManu().removerLugarDisponibleManu(id),);
  }
}