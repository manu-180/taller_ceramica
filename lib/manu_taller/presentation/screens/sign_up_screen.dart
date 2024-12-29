import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/generar_id.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/sign_up_screen.dart';

class SignUpScreenManu extends StatelessWidget {
  const SignUpScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return SignUpScreen(
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600),
      obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerUsuarios(), 
      generarIDd: () => GenerarId().generarIdUsuario(), 
      );
  }
}