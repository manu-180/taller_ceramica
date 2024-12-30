// import 'package:flutter/material.dart';
// import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
// import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
// import 'package:taller_ceramica/widgets/responsive_appbar.dart';
// import 'package:taller_ceramica/main.dart';
// import 'package:taller_ceramica/screens_globales/mis_clases.dart';


// class MisClasesScreenManu extends StatefulWidget {
//   const MisClasesScreenManu({super.key});

//   @override
//   State<MisClasesScreenManu> createState() => _MisClasesScreenManuState();
// }

// class _MisClasesScreenManuState extends State<MisClasesScreenManu> {
//   String? taller;
//   bool isLoading = true;      // Controla si la data sigue cargando
//   bool showLoader = false;    // Controla si ya queremos mostrar el loader
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();

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
//       if (usuarioActivo != null) {
//         final tallerObtenido =
//             await ObtenerTaller().retornarTaller(usuarioActivo.id);
//         setState(() {
//           taller = tallerObtenido;
//           isLoading = false; 
//           showLoader = false; 
//         });
//       } else {
//         setState(() {
//           errorMessage = 'No hay usuario activo';
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
//     if (isLoading && !showLoader) {
//       return const Scaffold(
//         body: SizedBox(),
//       );
//     }

//     if (isLoading && showLoader) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (errorMessage != null) {
//       return Scaffold(
//         body: Center(child: Text('Error: $errorMessage')),
//       );
//     }

//     return MisClasesScreen(
//       agregarCredito: (user) => ModificarCredito().agregarCreditoUsuario(user),
//       agregarAlertaTrigger: (user) =>
//           ModificarAlertTrigger().agregarAlertTrigger(user),
//       obtenerClases: () => ObtenerTotalInfo(
//         supabase: supabase,
//         usuariosTable: 'usuarios',
//         clasesTable: taller ?? '',
//       ).obtenerClases(),
//       appBar: ResponsiveAppBar(
//         isTablet: MediaQuery.of(context).size.width > 600,
//       ),
//       removerUsuarioDeClase: (idClase, user, parametro) =>
//           RemoverUsuario(supabase).removerUsuarioDeClase(
//         idClase,
//         user,
//         parametro,
//       ),
//     );
//   }
// }
