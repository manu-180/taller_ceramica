import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/alumnos_en_clase.dart';
import 'package:taller_ceramica/funciones_supabase/eliminar_usuario.dart';
import 'package:taller_ceramica/funciones_supabase/modificar_credito.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/usuarios_screen.dart';

import '../../../utils/utils_barril.dart';

class UsuariosScreenManu extends StatelessWidget {
  const UsuariosScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return UsuariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerUsuarios(), 
      agregarCredito:(user) => ModificarCredito().agregarCreditoUsuario(user), 
      removerCredito: (user) => ModificarCredito().removerCreditoUsuario(user), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600), 
      alumnosEnClase:(alumno) => AlumnosEnClase().clasesAlumno(alumno),
      eliminarUsuarioTabla: (userId ) => EliminarUsuario().eliminarDeBaseDatos(userId), 
      eliminarUsuarioBD: (userUid ) => EliminarDeBD().deleteCurrentUser(userUid));
  }
}