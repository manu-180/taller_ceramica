import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/screens_globales/sign_up_screen.dart';

class SignUpScreenIvanna extends StatefulWidget {
  const SignUpScreenIvanna({super.key});

  @override
  State<SignUpScreenIvanna> createState() => _SignUpScreenIvannaState();
}

class _SignUpScreenIvannaState extends State<SignUpScreenIvanna> {
  String? taller;
  bool isLoading = true;    // Controla si se está cargando el taller
  bool showLoader = false;  // Controla si se muestra el loader tras 1 segundo
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Después de 1 segundo, si aún sigue isLoading, mostramos el loader
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
      if (usuarioActivo != null) {
        final tallerObtenido =
            await ObtenerTaller().retornarTaller(usuarioActivo.id);
        setState(() {
          taller = tallerObtenido;
          isLoading = false;
          showLoader = false; // Se terminó la carga antes o justo al cumplir 1s
        });
      } else {
        setState(() {
          errorMessage = 'No hay usuario activo';
          isLoading = false;
          showLoader = false;
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
    // 1) Si todavía no han pasado 1 segundo y seguimos cargando, mostramos un widget vacío
    if (isLoading && !showLoader) {
      return const Scaffold(
        body: Center(child: SizedBox()),
      );
    }

    // 2) Si sigue cargando y ya pasaron 1s => mostramos el loader
    if (isLoading && showLoader) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) Si hubo error
    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text('Error: $errorMessage')),
      );
    }

    // 4) Aquí ya tengo el taller
    return SignUpScreen(
      appBar: ResponsiveAppBar(
        isTablet: MediaQuery.of(context).size.width > 600,
      ),
      obtenerUsuarios: () => ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller ?? '',
      ).obtenerUsuarios(),
      generarIDd: () => GenerarId().generarIdUsuario(),
    );
  }
}
