import 'package:flutter/widgets.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_tablet_screen.dart';

class ClasesTabletScreenIvanna extends StatelessWidget {
  const ClasesTabletScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return ClasesTabletScreen(
      obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerClases(), 
      obtenerAlertTrigger: (user) => ObtenerAlertTrigger().alertTrigger(user), 
      obtenerClasesDisponibles: (user) =>  ObtenerClasesDisponibles().clasesDisponibles(user), 
      resetearAlertTrigger: (user) =>ModificarAlertTrigger().resetearAlertTrigger(user),
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600 )
      );
  }
}