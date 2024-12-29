import 'package:flutter/widgets.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import '../../../../screens_globales/responsive_turnos_screen/clases_tablet_screen.dart';

class ClasesTabletScreenManu extends StatelessWidget {
  const ClasesTabletScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return ClasesTabletScreen(
      obtenerClases: () => ObtenerTotalInfoManu().obtenerClaseManu(), 
      obtenerAlertTrigger: (user) => ObtenerAlertTriggerManu().alertTriggerManu(user), 
      obtenerClasesDisponibles: (user) =>  ObtenerClasesDisponiblesManu().clasesDisponiblesManu(user), 
      resetearAlertTrigger: (user) =>ModificarAlertTriggerManu().resetearAlertTriggerManu(user), 
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600 ), 
      );
  }
}