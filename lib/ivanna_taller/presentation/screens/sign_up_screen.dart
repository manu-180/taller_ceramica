import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/sign_up_screen.dart';

class SignUpScreenIvanna extends StatelessWidget {
  const SignUpScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return SignUpScreen(
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
      obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios(), 
      generarIDd: () => GenerarId().generarIdUsuario(), 
      );
  }
}