import 'package:flutter/material.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/funciones_supabase/update_user.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/screens_globales/update_name_screen.dart';

class UpdateNameScreenManu extends StatelessWidget {
  const UpdateNameScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return UpdateNameScreen(
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600),
            obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'clasesmanu').obtenerUsuarios(),
      updateUser: (oldName, newName) =>
          UpdateUser(supabase).updateUser(oldName, newName),
      updateTableUser: (id, newName) =>
          UpdateUser(supabase).updateTableUser(id, newName),
    );
  }
}
