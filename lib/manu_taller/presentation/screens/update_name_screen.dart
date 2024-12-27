import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/screens_globales/update_name_screen.dart';

class UpdateNameScreenManu extends StatelessWidget {
  const UpdateNameScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    return UpdateNameScreen(
      appBar: ResponsiveAppBarManu(isTablet: MediaQuery.of(context).size.width > 600),
      obtenerUsuarios: () => ObtenerTotalInfoManu().obtenerUsuariosManu(),
      updateUser: (oldName, newName) =>
          UpdateUserManu(supabase).updateUserManu(oldName, newName),
      updateTableUser: (id, newName) =>
          UpdateUserManu(supabase).updateTableUserManu(id, newName),
    );
  }
}
