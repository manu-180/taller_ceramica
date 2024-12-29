import 'package:flutter/widgets.dart';
import 'package:taller_ceramica/funciones_supabase/modificar_alert_trigger.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_alert_trigger.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import '../../../../screens_globales/responsive_turnos_screen/clases_tablet_screen.dart';

class ClasesTabletScreenManu extends StatelessWidget {
  const ClasesTabletScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return ClasesTabletScreen(
      obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerClases(), 
      obtenerAlertTrigger: (user) => ObtenerAlertTrigger().alertTrigger(user), 
      obtenerClasesDisponibles: (user) =>  ObtenerClasesDisponibles().clasesDisponibles(user), 
      resetearAlertTrigger: (user) =>ModificarAlertTrigger().resetearAlertTrigger(user),
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600 ), 
      );
  }
}