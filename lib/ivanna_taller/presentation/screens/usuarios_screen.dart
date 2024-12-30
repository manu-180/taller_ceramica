// import 'package:flutter/material.dart';
// import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
// import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
// import 'package:taller_ceramica/widgets/responsive_appbar.dart';
// import 'package:taller_ceramica/main.dart';
// import 'package:taller_ceramica/screens_globales/usuarios_screen.dart';

// class UsuariosScreenIvanna extends StatefulWidget {
//   const UsuariosScreenIvanna({super.key});

//   @override
//   State<UsuariosScreenIvanna> createState() => _UsuariosScreenIvannaState();
// }

// class _UsuariosScreenIvannaState extends State<UsuariosScreenIvanna> {
//   String? taller;
//   bool isLoading = true;   
//   bool showLoader = false; 
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
//       if (usuarioActivo == null) {
//         setState(() {
//           errorMessage = 'No hay usuario activo';
//           isLoading = false;
//           showLoader = false;
//         });
//         return;
//       }

//       final tallerObtenido =
//           await ObtenerTaller().retornarTaller(usuarioActivo.id);

//       setState(() {
//         taller = tallerObtenido;
//         isLoading = false;
//         showLoader = false;
//       });
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
//         body: Center(child: SizedBox()),
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

//     return UsuariosScreen(
//       obtenerUsuarios: () => ObtenerTotalInfo(
//         supabase: supabase,
//         usuariosTable: 'usuarios',
//         clasesTable: taller ?? '',
//       ).obtenerUsuarios(),
//       agregarCredito: (user) => ModificarCredito().agregarCreditoUsuario(user),
//       removerCredito: (user) => ModificarCredito().removerCreditoUsuario(user),
//       appBar: ResponsiveAppBar(
//         isTablet: MediaQuery.of(context).size.width > 600,
//       ),
//       alumnosEnClase: (alumno) => AlumnosEnClase().clasesAlumno(alumno),
//       eliminarUsuarioTabla: (userId) =>
//           EliminarUsuario().eliminarDeBaseDatos(userId),
//       eliminarUsuarioBD: (userUid) =>
//           EliminarDeBD().deleteCurrentUser(userUid),
//     );
//   }
// }
