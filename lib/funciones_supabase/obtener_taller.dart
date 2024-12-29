import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerTaller {

  Future<String> retornarTaller(String userUid) async {
    final users = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();

    for (final item in users) {
      if (item.userUid == userUid) {
        return item.taller;
      }
    }
    return "";
  }

}