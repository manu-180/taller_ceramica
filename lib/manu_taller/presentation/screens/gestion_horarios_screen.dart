import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/agregar_usuario.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/funciones_supabase/remover_usuario.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/gestion_horarios_screen.dart';

class GestionHorariosScreenManu extends StatelessWidget {
  const GestionHorariosScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionHorariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerUsuarios(), 
      obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerClases(), 
      agregarUsuarioAClase: ( idClase, user, parametro, claseModels) => AgregarUsuario(supabase).agregarUsuarioAClase(idClase, user, parametro, claseModels), 
      agregarUsuarioEnCuatroClases: (clase, user) => AgregarUsuario(supabase).agregarUsuarioEnCuatroClases(clase, user),
      removerUsuarioDeUnaClase: ( idClase,  user,  parametro) => RemoverUsuario(supabase).removerUsuarioDeClase(idClase, user, parametro),
      removerUsuarioDeMuchasClases: (claseModels, user) => RemoverUsuario(supabase).removerUsuarioDeMuchasClase(claseModels, user),
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600),
      );
  }
}