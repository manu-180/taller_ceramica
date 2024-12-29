import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/update_user.dart';
import 'package:taller_ceramica/main.dart';

import '../../../screens_globales/update_name_screen.dart';

class UpdateNameScreenIvanna extends StatelessWidget {
  const UpdateNameScreenIvanna({super.key});

  @override
  Widget build(BuildContext context) {
    return UpdateNameScreen(
      appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
      obtenerUsuarios: () => ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerClases(),
      updateUser: (oldName, newName) =>
          UpdateUser(supabase).updateUser(oldName, newName),
      updateTableUser: (id, newName) =>
          UpdateUser(supabase).updateTableUser(id, newName),
    );
  }
}
