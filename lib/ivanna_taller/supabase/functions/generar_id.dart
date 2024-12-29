import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class GenerarId {
  Future<int> generarIdUsuario() async {
    final listausuarios = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();
    listausuarios.sort((a, b) => a.id.compareTo(b.id));

    for (int i = 0; i < listausuarios.length - 1; i++) {
      if (listausuarios[i].id + 1 != listausuarios[i + 1].id) {
        return listausuarios[i].id + 1;
      }
    }
    return listausuarios.last.id + 1;
  }

  Future<int> generarIdClase() async {
    final listclase = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerClases();

    if (listclase.isEmpty) {
      return 1;
    }

    listclase.sort((a, b) => a.id.compareTo(b.id));

    for (int i = 0; i < listclase.length - 1; i++) {
      if (listclase[i].id + 1 != listclase[i + 1].id) {
        return listclase[i].id + 1;
      }
    }

    return listclase.last.id + 1;
  }
}
