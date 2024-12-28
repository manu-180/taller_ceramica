import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/mis_clases.dart';

class MisClasesScreenManu extends StatelessWidget {
  const MisClasesScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return MisClasesScreen(
     
      agregarCredito:(user) =>ModificarCreditoManu().agregarCreditoUsuarioManu(user), 
      agregarAlertaTrigger:(user) =>ModificarAlertTriggerManu().agregarAlertTriggerManu(user),
      obtenerClases: () => ObtenerTotalInfoManu().obtenerClaseManu(), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600), 
      removerUsuarioDeClase: (idClase , user , parametro ) => RemoverUsuarioManu(supabase).removerUsuarioDeClaseManu(idClase , user , parametro ),
      );
  }
}