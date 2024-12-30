import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/gestion_horarios_screen.dart';

class GestionHorariosScreenManu extends StatefulWidget {
  const GestionHorariosScreenManu({super.key});

  @override
  State<GestionHorariosScreenManu> createState() =>
      _GestionHorariosScreenManuState();
}

class _GestionHorariosScreenManuState
    extends State<GestionHorariosScreenManu> {
  String? taller;
  bool isLoading = true;      // Controla si todavía estamos cargando el taller
  bool showLoader = false;    // Controla si ya han pasado 1s y debemos mostrar loader
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Pasado 1 segundo, si seguimos cargando, mostramos el CircularProgressIndicator
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
        return;
      }
      final tallerObtenido =
          await ObtenerTaller().retornarTaller(usuarioActivo.id);
      setState(() {
        taller = tallerObtenido;
        isLoading = false;
        showLoader = false;
      });
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
    // 1) Está cargando pero aún no se cumplió 1s => mostramos un widget vacío
    if (isLoading && !showLoader) {
      return const Scaffold(
        body: Center(child: SizedBox()),
      );
    }

    // 2) Sigue cargando y ya pasó 1s => mostramos loader
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

    // 4) Si todo está bien y ya tenemos el taller
    return GestionHorariosScreen(
      obtenerUsuarios: () => ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller!,
      ).obtenerUsuarios(),
      obtenerClases: () => ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller!,
      ).obtenerClases(),
      agregarUsuarioAClase: (idClase, user, parametro, claseModels) =>
          AgregarUsuario(supabase)
              .agregarUsuarioAClase(idClase, user, parametro, claseModels),
      agregarUsuarioEnCuatroClases: (clase, user) => AgregarUsuario(supabase)
          .agregarUsuarioEnCuatroClases(clase, user),
      removerUsuarioDeUnaClase: (idClase, user, parametro) =>
          RemoverUsuario(supabase)
              .removerUsuarioDeClase(idClase, user, parametro),
      removerUsuarioDeMuchasClases: (claseModels, user) =>
          RemoverUsuario(supabase)
              .removerUsuarioDeMuchasClase(claseModels, user),
      appBar: ResponsiveAppBar(
        isTablet: MediaQuery.of(context).size.width > 600,
      ),
    );
  }
}
