
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class GenerarIdManu {
  Future<int> generarIdUsuarioManu() async {
    final listausuarios = await ObtenerTotalInfoManu().obtenerUsuariosManu();
    listausuarios.sort((a, b) => a.id.compareTo(b.id));

    for (int i = 0; i < listausuarios.length - 1; i++) {
      if (listausuarios[i].id + 1 != listausuarios[i + 1].id) {
        return listausuarios[i].id + 1;
      }
    }
    return listausuarios.last.id + 1;
  }

  Future<int> generarIdClaseManu() async {
    final listclase = await ObtenerTotalInfoManu().obtenerClaseManu();

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
