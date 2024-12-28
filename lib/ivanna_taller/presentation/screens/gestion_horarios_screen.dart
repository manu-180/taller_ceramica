import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/gestion_horarios_screen.dart';

class GestionHorariosScreenIvanna extends StatelessWidget {
  const GestionHorariosScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionHorariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfo().obtenerInfoUsuarios(), 
      obtenerClases: () => ObtenerTotalInfo().obtenerInfo(), 
      agregarUsuarioAClase: ( idClase, user, parametro, claseModels) => AgregarUsuario(supabase).agregarUsuarioAClase(idClase, user, parametro, claseModels), 
      agregarUsuarioEnCuatroClases: (clase, user) => AgregarUsuario(supabase).agregarUsuarioEnCuatroClases(clase, user),
      removerUsuarioDeUnaClase: ( idClase,  user,  parametro) => RemoverUsuario(supabase).removerUsuarioDeClase(idClase, user, parametro),
      removerUsuarioDeMuchasClases: (ClaseModels, user) => RemoverUsuario(supabase).removerUsuarioDeMuchasClase(ClaseModels, user),
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
      );
  }
}