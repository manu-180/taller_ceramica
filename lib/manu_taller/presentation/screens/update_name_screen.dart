import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/funciones_supabase/update_user.dart';
import 'package:taller_ceramica/main.dart';

import '../../../screens_globales/update_name_screen.dart';

class UpdateNameScreenManu extends StatefulWidget {
  const UpdateNameScreenManu({super.key});

  @override
  State<UpdateNameScreenManu> createState() => _UpdateNameScreenManuState();
}

class _UpdateNameScreenManuState extends State<UpdateNameScreenManu> {
  String? taller;
  bool isLoading = true;   
  bool showLoader = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

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

      if (tallerObtenido == null) {
        setState(() {
          errorMessage = 'Error: Taller is null';
          isLoading = false;
          showLoader = false;
        });
      } else {
        setState(() {
          taller = tallerObtenido;
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
    if (isLoading && !showLoader) {
      return const Scaffold(
        body: Center(child: SizedBox()),
      );
    }

    if (isLoading && showLoader) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    return UpdateNameScreen(
      appBar: ResponsiveAppBar(
        isTablet: MediaQuery.of(context).size.width > 600,
      ),
      obtenerUsuarios: () => ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller!,
      ).obtenerUsuarios(),
      updateUser: (oldName, newName) =>
          UpdateUser(supabase).updateUser(oldName, newName),
      updateTableUser: (id, newName) =>
          UpdateUser(supabase).updateTableUser(id, newName),
    );
  }
}
