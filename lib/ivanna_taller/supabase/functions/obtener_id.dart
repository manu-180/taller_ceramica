import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerId {
  Future<int> obtenerID(String user) async {
    final data = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.id;
      }
    }
    return 0;
  }
}
