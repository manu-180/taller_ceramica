import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/funciones_supabase/modificar_alert_trigger.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_alert_trigger.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_screen.dart';

class ClasesScreenIvanna extends StatelessWidget {
  const ClasesScreenIvanna({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final taller = snapshot.data as String;
          return ClasesScreen(
            obtenerClases: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller).obtenerClases(), 
            obtenerAlertTrigger: (user) => ObtenerAlertTrigger().alertTrigger(user), 
            obtenerClasesDisponibles: (user) =>  ObtenerClasesDisponibles().clasesDisponibles(user), 
            resetearAlertTrigger: (user) =>ModificarAlertTrigger().resetearAlertTrigger(user), 
            appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600 )
          );
        }
      },
    );
  }

  Future<String> _initializeData() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    return await ObtenerTaller().retornarTaller(usuarioActivo!.id);
  }
}