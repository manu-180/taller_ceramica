import 'package:flutter/material.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/sign_up_screen.dart';

class SignUpScreenManu extends StatelessWidget {
  const SignUpScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return SignUpScreen(
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600),
      obtenerUsuarios: () => ObtenerTotalInfoManu().obtenerUsuariosManu(), 
      generarIDd: () => GenerarIdManu().generarIdUsuarioManu(), 
      );
  }
}