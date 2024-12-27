import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/config/router/barril_screens.dart';
import 'package:taller_ceramica/home.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/configuracion.dart';
import 'package:taller_ceramica/screens_globales/cambiar_password.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/configuracion.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/gestion_clases_screen.dart';
import 'package:taller_ceramica/screens_globales/prueba.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/responsive_turnos_screens/resposive_clases_screen.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/update_name_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/gestion_clases_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/gestion_horarios_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/home_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/mis_clases_screens.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/responsive_turnos_screens/resposive_clases_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/sign_up_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/update_name_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/usuarios_screen.dart';

final appRouter = GoRouter(initialLocation: "/", routes: [
  GoRoute(path: "/", builder: (context, state) => const Home()),
  GoRoute(path: "/homeivanna", builder: (context, state) => const HomeScreen()),
  GoRoute(
    path: "/turnosivanna",
    builder: (context, state) {
      final isTablet = MediaQuery.of(context).size.width > 600;
      return ResposiveClasesScreen(isTablet: isTablet);
    },
  ),
  GoRoute(
      path: "/misclasesivanna",
      // name: "misclases",
      builder: (context, state) => const MisClasesScreen()),
  GoRoute(
      path: "/gestionhorariosivanna",
      // name: "gestionhorarios",
      builder: (context, state) => const GestionHorariosScreen()),
  GoRoute(
      path: "/usuariosivanna",
      // name: "usuarios",
      builder: (context, state) => const UsuariosScreen()),
  GoRoute(
      path: "/configuracionivanna",
      // name: "configuracion",
      builder: (context, state) => const ConfiguracionIvanna()),
  GoRoute(
      path: "/crear-usuarioivanna",
      // name: "crear usuario",
      builder: (context, state) => const SignUpScreen()),
  GoRoute(path: "/prueba", builder: (context, state) => const Prueba()),
  GoRoute(
      path: "/gestionclasesivanna",
      builder: (context, state) => const GestionDeClasesScreen()),
  GoRoute(
      path: "/cambiarpassword",
      builder: (context, state) => const CambiarPassword()),
  GoRoute(
      path: "/cambiarfullnameivanna",
      builder: (context, state) => const UpdateNameScreenIvanna()),
  GoRoute(
      path: "/homemanu", builder: (context, state) => const HomeScreenManu()),
  GoRoute(
    path: "/turnosmanu",
    builder: (context, state) {
      final isTablet = MediaQuery.of(context).size.width > 600;
      return ResposiveClasesScreenManu(isTablet: isTablet);
    },
  ),
  GoRoute(
      path: "/misclasesmanu",
      // name: "misclases",
      builder: (context, state) => const MisClasesScreenManu()),
  GoRoute(
      path: "/gestionhorariosmanu",
      // name: "gestionhorarios",
      builder: (context, state) => const GestionHorariosScreenManu()),
  GoRoute(
      path: "/usuariosmanu",
      // name: "usuarios",
      builder: (context, state) => const UsuariosScreenManu()),
  GoRoute(
      path: "/configuracionmanu",
      // name: "usuarios",
      builder: (context, state) => const ConfiguracionManu()),
  
  GoRoute(
      path: "/crear-usuariomanu",
      // name: "crear usuario",
      builder: (context, state) => const SignUpScreenManu()),
  GoRoute(path: "/prueba", builder: (context, state) => const Prueba()),
  GoRoute(
      path: "/gestionclasesmanu",
      builder: (context, state) => const GestionDeClasesScreenManu()),
  GoRoute(
      path: "/cambiarfullnamemanu",
      builder: (context, state) => const UpdateNameScreenManu()),
  
]);
