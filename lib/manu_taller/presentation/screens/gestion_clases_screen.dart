// import 'package:flutter/material.dart';
// import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
// import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
// import 'package:taller_ceramica/widgets/responsive_appbar.dart';
// import 'package:taller_ceramica/main.dart';
// import 'package:taller_ceramica/screens_globales/gestion_clases_screen.dart';

// class GestionClasesScreenManu extends StatefulWidget {
//   const GestionClasesScreenManu({super.key});

//   @override
//   State<GestionClasesScreenManu> createState() =>
//       _GestionClasesScreenManuState();
// }

// class _GestionClasesScreenManuState extends State<GestionClasesScreenManu> {
//   String? taller;
//   bool isLoading = true;      // Controla si todavía estamos cargando el taller
//   bool showLoader = false;    // Controla si ya han pasado 1s y debemos mostrar loader
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();

//     // Pasado 1 segundo, si seguimos cargando, mostramos el CircularProgressIndicator
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted && isLoading) {
//         setState(() {
//           showLoader = true;
//         });
//       }
//     });

//     _cargarTaller();
//   }

//   Future<void> _cargarTaller() async {
//     try {
//       final usuarioActivo = Supabase.instance.client.auth.currentUser;
//       if (usuarioActivo == null) {
//         setState(() {
//           errorMessage = 'No hay usuario activo';
//           isLoading = false;
//           showLoader = false;
//         });
//       } else {
//         final tallerObtenido =
//             await ObtenerTaller().retornarTaller(usuarioActivo.id);
//         setState(() {
//           taller = tallerObtenido;
//           isLoading = false;
//           showLoader = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//         showLoader = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 1) Está cargando pero aún no se cumplió 1s (no mostramos nada).
//     if (isLoading && !showLoader) {
//       return const Scaffold(
//         body: Center(child: SizedBox()),
//       );
//     }

//     // 2) Sigue cargando y ya pasó 1s (mostramos el loader).
//     if (isLoading && showLoader) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // 3) Si hubo un error
//     if (errorMessage != null) {
//       return Scaffold(
//         body: Center(child: Text('Error: $errorMessage')),
//       );
//     }

//     // 4) Si ya obtuvimos el taller, construimos la pantalla de gestión.
//     return GestionDeClasesScreen(
//       obtenerClases: () => ObtenerTotalInfo(
//         supabase: supabase,
//         usuariosTable: 'usuarios',
//         clasesTable: taller ?? '',
//       ).obtenerClases(),
//       appBar: ResponsiveAppBar(
//         isTablet: MediaQuery.of(context).size.width > 600,
//       ),
//       generarIdClase: () => GenerarId().generarIdClase(),
//       agregarLugardisponible: (id) =>
//           ModificarLugarDisponible().agregarLugarDisponible(id),
//       removerLugardisponible: (id) =>
//           ModificarLugarDisponible().removerLugarDisponible(id),
//       eliminarClase: (id) => EliminarClase().eliminarClase(id),
//     );
//   }
// }
