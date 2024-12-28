import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/mis_clases.dart';

import '../../widgets/responsive_appbar.dart';

class MisClasesScreenIvanna extends StatelessWidget {
  const MisClasesScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return MisClasesScreen(
     
      agregarCredito:(user) =>ModificarCredito().agregarCreditoUsuario(user), 
      agregarAlertaTrigger:(user) =>ModificarAlertTrigger().agregarAlertTrigger(user),
      obtenerClases: () => ObtenerTotalInfo().obtenerInfo(), 
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600), 
      removerUsuarioDeClase: (idClase , user , parametro ) => RemoverUsuario(supabase).removerUsuarioDeClase(idClase , user , parametro ),
      );
  }
}