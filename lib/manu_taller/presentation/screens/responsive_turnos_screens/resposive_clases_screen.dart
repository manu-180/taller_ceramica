import 'package:flutter/material.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/responsive_turnos_screens/clases_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/responsive_turnos_screens/clases_tablet_screen.dart';


class ResposiveClasesScreenManu extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

ResposiveClasesScreenManu({super.key, required bool isTablet})
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
      return const ClasesTabletScreenManu();
    } else {
      // Renderiza el AppBar para celulares
      return const ClasesScreenManu();
    }
  }
}
