import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/home.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/home_screen.dart';
import 'package:taller_ceramica/screens_globales/mis_clases.dart';
import 'package:taller_ceramica/screens_globales/gestion_clases_screen.dart';
import 'package:taller_ceramica/screens_globales/gestion_horarios_screen.dart';
import 'package:taller_ceramica/screens_globales/prueba.dart';
import 'package:taller_ceramica/screens_globales/responsive_turnos_screen/responsive_clases_screen.dart';
import 'package:taller_ceramica/screens_globales/sign_up_screen.dart';
import 'package:taller_ceramica/screens_globales/usuarios_screen.dart';
import 'package:taller_ceramica/screens_globales/configuracion.dart';
import 'package:taller_ceramica/screens_globales/cambiar_password.dart';
import 'package:taller_ceramica/screens_globales/update_name_screen.dart';

/// Ejemplo: 
/// - "/home" (no requiere taller, pantalla principal)
/// - "/home/:taller" si quieres que home también use taller.
/// - "/turnos/:taller", "/misclases/:taller", etc.

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    // Ruta raíz (sin taller)
    GoRoute(
      path: "/",
      builder: (context, state) => const Home(),
    ),

    // Ejemplo: Pantalla principal con taller (opcional) => /home/:taller
    GoRoute(
      path: "/home/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return HomeScreen(
          // Ajusta HomeScreen para recibir "taller" si lo necesitas
          taller: tallerParam,
        );
      },
    ),

    // Reemplazando /turnosivanna con /turnos/:taller
    GoRoute(
      path: "/turnos/:taller",
      builder: (context, state) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        final tallerParam = state.pathParameters['taller'];
        return ResposiveClasesScreen(
          isTablet: isTablet,
          taller: tallerParam,
        );
      },
    ),

    // Reemplazando /misclasesivanna con /misclases/:taller
    GoRoute(
      path: "/misclases/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return MisClasesScreen(taller: tallerParam);
      },
    ),

    // Reemplazando /gestionhorariosivanna con /gestionhorarios/:taller
    GoRoute(
      path: "/gestionhorarios/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return GestionHorariosScreen(taller: tallerParam);
      },
    ),

    // Reemplazando /usuariosivanna con /usuarios/:taller
    GoRoute(
      path: "/usuarios/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return UsuariosScreen(taller: tallerParam);
      },
    ),

    // Reemplazando /configuracionivanna con /configuracion/:taller
    GoRoute(
      path: "/configuracion/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return Configuracion(taller: tallerParam);
      },
    ),

    // Reemplazando /crear-usuarioivanna con /crear-usuario/:taller
    GoRoute(
      path: "/crear-usuario/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return SignUpScreen(taller: tallerParam);
      },
    ),

    // Ejemplo adicional /prueba (sin taller param)
    GoRoute(
      path: "/prueba",
      builder: (context, state) => const Prueba(),
    ),

    // /gestionclasesivanna => /gestionclases/:taller
    GoRoute(
      path: "/gestionclases/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return GestionDeClasesScreen(taller: tallerParam);
      },
    ),

    // /cambiarpassword (no requiere taller)
    GoRoute(
      path: "/cambiarpassword",
      builder: (context, state) => const CambiarPassword(),
    ),

    // /cambiarfullnameivanna => /cambiarfullname/:taller
    GoRoute(
      path: "/cambiarfullname/:taller",
      builder: (context, state) {
        final tallerParam = state.pathParameters['taller'];
        return UpdateNameScreen(taller: tallerParam);
      },
    ),
  ],
);
