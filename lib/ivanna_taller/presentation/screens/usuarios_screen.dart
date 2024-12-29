import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/usuarios_screen.dart';

class UsuariosScreenIvanna extends StatelessWidget {
  const UsuariosScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return UsuariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios(), 
      agregarCredito:(user) => ModificarCredito().agregarCreditoUsuario(user), 
      removerCredito: (user) => ModificarCredito().removerCreditoUsuario(user), 
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600), 
      alumnosEnClase:(alumno) => AlumnosEnClase().clasesAlumno(alumno),
      eliminarUsuarioTabla: (userId ) => EliminarUsuario().eliminarDeBaseDatos(userId), 
      eliminarUsuarioBD: (userUid ) => EliminarDeBD().deleteCurrentUser(userUid));
  }
}