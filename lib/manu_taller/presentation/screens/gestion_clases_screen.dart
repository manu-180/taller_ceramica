import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/eliminar_clase.dart';
import 'package:taller_ceramica/funciones_supabase/generar_id.dart';
import 'package:taller_ceramica/funciones_supabase/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/gestion_clases_screen.dart';

class GestionClasesScreenManu extends StatelessWidget {
  const GestionClasesScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionDeClasesScreen(
      obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerClases(), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600 ), 
      generarIdClase: () => GenerarId().generarIdClase(), 
      agregarLugardisponible: (id) => ModificarLugarDisponible().agregarLugarDisponible(id), 
      removerLugardisponible: (id) => ModificarLugarDisponible().removerLugarDisponible(id), 
      eliminarClase:(id) => EliminarClase().eliminarClase(id),);
  }
}