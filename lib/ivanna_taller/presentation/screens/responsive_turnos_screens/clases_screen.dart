import 'package:flutter/widgets.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_alert_trigger.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_alert_trigger.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_screen.dart';

class ClasesScreenIvanna extends StatelessWidget {
  const ClasesScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return ClasesScreen(
      obtenerClases: () => ObtenerTotalInfo().obtenerInfo(), 
      obtenerAlertTrigger: (user) => ObtenerAlertTrigger().alertTrigger(user), 
      obtenerClasesDisponibles: (user) =>  ObtenerClasesDisponibles().clasesDisponibles(user), 
      resetearAlertTrigger: (user) =>ModificarAlertTrigger().resetearAlertTrigger(user), 
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600 )
    );
  }
}