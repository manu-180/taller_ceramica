import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/gestion_horarios_screen.dart';

class GestionHorariosScreenManu extends StatelessWidget {
  const GestionHorariosScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionHorariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfoManu().obtenerUsuariosManu(), 
      obtenerClases: () => ObtenerTotalInfoManu().obtenerClaseManu(), 
      agregarUsuarioAClase: ( idClase, user, parametro, claseModels) => AgregarUsuarioManu(supabase).agregarUsuarioAClaseManu(idClase, user, parametro, claseModels), 
      agregarUsuarioEnCuatroClases: (clase, user) => AgregarUsuarioManu(supabase).agregarUsuarioEnCuatroClasesManu(clase, user),
      removerUsuarioDeUnaClase: ( idClase,  user,  parametro) => RemoverUsuarioManu(supabase).removerUsuarioDeClaseManu(idClase, user, parametro),
      removerUsuarioDeMuchasClases: (claseModels, user) => RemoverUsuarioManu(supabase).removerUsuarioDeMuchasClaseManu(claseModels, user),
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600),
      );
  }
}