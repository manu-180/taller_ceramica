import 'package:flutter/widgets.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_screen.dart';

class ClasesScreenManu extends StatelessWidget {
  const ClasesScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return ClasesScreen(
      obtenerClases: () => ObtenerTotalInfoManu().obtenerClaseManu(), 
      obtenerAlertTrigger: (user) => ObtenerAlertTriggerManu().alertTriggerManu(user), 
      obtenerClasesDisponibles: (user) =>  ObtenerClasesDisponiblesManu().clasesDisponiblesManu(user), 
      resetearAlertTrigger: (user) =>ModificarAlertTriggerManu().resetearAlertTriggerManu(user), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600 ), 
      );
  }
}