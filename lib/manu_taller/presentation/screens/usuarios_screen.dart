import 'package:flutter/material.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/usuarios_screen.dart';

import '../../../utils/utils_barril.dart';

class UsuariosScreenManu extends StatelessWidget {
  const UsuariosScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return UsuariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfoManu().obtenerUsuariosManu(), 
      agregarCredito:(user) => ModificarCreditoManu().agregarCreditoUsuarioManu(user), 
      removerCredito: (user) => ModificarCreditoManu().removerCreditoUsuarioManu(user), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600), 
      alumnosEnClase:(alumno) => AlumnosEnClaseManu().clasesAlumnoManu(alumno), 
      eliminarUsuarioTabla: (userId ) => EliminarUsuarioManu().eliminarDeBaseDatosManu(userId), 
      eliminarUsuarioBD: (userUid ) => EliminarDeBD().deleteCurrentUser(userUid),);
  }
}