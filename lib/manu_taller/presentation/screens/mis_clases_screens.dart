import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/modificar_alert_trigger.dart';
import 'package:taller_ceramica/funciones_supabase/modificar_credito.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/funciones_supabase/remover_usuario.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/mis_clases.dart';

class MisClasesScreenManu extends StatelessWidget {
  const MisClasesScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return MisClasesScreen(
     
      agregarCredito:(user) =>ModificarCredito().agregarCreditoUsuario(user), 
      agregarAlertaTrigger:(user) =>ModificarAlertTrigger().agregarAlertTrigger(user),
      obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerClases(), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600), 
      removerUsuarioDeClase: (idClase , user , parametro ) => RemoverUsuario(supabase).removerUsuarioDeClase(idClase , user , parametro ),
      );
  }
}