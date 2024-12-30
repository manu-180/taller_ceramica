import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/clases_tablet_screen.dart';

class ClasesTabletScreenIvanna extends StatefulWidget {
  const ClasesTabletScreenIvanna({super.key});

  @override
  State<ClasesTabletScreenIvanna> createState() =>
      _ClasesTabletScreenIvannaState();
}

class _ClasesTabletScreenIvannaState extends State<ClasesTabletScreenIvanna> {
  String? taller;
  bool isLoading = true;      // Controla si la data sigue cargando
  bool showLoader = false;    // Controla si ya queremos mostrar el loader
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Después de 1 segundo, si seguimos isLoading, mostramos el loader
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && isLoading) {
        setState(() {
          showLoader = true;
        });
      }
    });

    _cargarTaller();
  }

  Future<void> _cargarTaller() async {
    try {
      final usuarioActivo = Supabase.instance.client.auth.currentUser;
      if (usuarioActivo == null) {
        setState(() {
          errorMessage = 'No hay usuario activo';
          isLoading = false;
          showLoader = false;
        });
      } else {
        final tallerObtenido =
            await ObtenerTaller().retornarTaller(usuarioActivo.id);
        setState(() {
          taller = tallerObtenido;
          isLoading = false;  
          showLoader = false; // Deja de mostrar loader si terminó antes del 1s
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        showLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1) Estamos cargando pero aún no se cumplió 1 segundo:
    if (isLoading && !showLoader) {
      return const Scaffold(
        body: Center(child: SizedBox()),
      );
    }

    // 2) Estamos cargando y ya pasó 1 segundo => mostramos loader
    if (isLoading && showLoader) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) Si hay algún error
    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text('Error: $errorMessage')),
      );
    }

    // 4) Si todo está bien, mostramos la ClasesTabletScreen real,
    //    usando el taller obtenido:
    return ClasesTabletScreen(
      obtenerClases: () => ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller ?? '',
      ).obtenerClases(),
      obtenerAlertTrigger: (user) => ObtenerAlertTrigger().alertTrigger(user),
      obtenerClasesDisponibles: (user) =>
          ObtenerClasesDisponibles().clasesDisponibles(user),
      resetearAlertTrigger: (user) =>
          ModificarAlertTrigger().resetearAlertTrigger(user),
      appBar: ResponsiveAppBar(
        isTablet: MediaQuery.of(context).size.width > 600,
      ),
    );
  }
}
