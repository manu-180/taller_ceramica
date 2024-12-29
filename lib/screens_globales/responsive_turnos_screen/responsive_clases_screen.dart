import 'package:flutter/material.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_screen.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_tablet_screen.dart';

class ResposiveClasesScreen extends StatelessWidget

    implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final Future<List<dynamic>> Function() obtenerClases;
    final Future<int> Function(String) obtenerAlertTrigger;
    final Future<int> Function(String) obtenerClasesDisponibles;
    final Future<bool> Function(String) resetearAlertTrigger;
    final PreferredSizeWidget appBar;

  ResposiveClasesScreen({super.key, 
  required bool isTablet, 
  required this.obtenerClases, 
  required this.obtenerAlertTrigger, 
  required this.obtenerClasesDisponibles, 
  required this.resetearAlertTrigger, 
  required this.appBar})

      : preferredSize = Size.fromHeight(
          isTablet ? kToolbarHeight * 2.2 : kToolbarHeight * 1.25,
        );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Define un umbral de ancho para tablets
    const double tabletThreshold = 600;

    if (size.width > tabletThreshold) {
      // Renderiza el AppBar para tablets
      return ClasesTabletScreen(
        obtenerClases: obtenerClases, 
        obtenerAlertTrigger: obtenerAlertTrigger, 
        obtenerClasesDisponibles: obtenerClasesDisponibles, 
        resetearAlertTrigger: resetearAlertTrigger, 
        appBar: appBar,
      );
    } else {
      // Renderiza el AppBar para celulares
      return ClasesScreen(
        obtenerClases: obtenerClases, 
        obtenerAlertTrigger: obtenerAlertTrigger, 
        obtenerClasesDisponibles: obtenerClasesDisponibles, 
        resetearAlertTrigger: resetearAlertTrigger, 
        appBar: appBar,);
    }
  }
}
