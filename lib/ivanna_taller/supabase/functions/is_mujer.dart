import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';

class IsMujer {
  Future<bool> mujer(String usuario) async {
    final users = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();

    for (final user in users) {
      if (user.fullname == usuario && user.sexo == "mujer") {
        return true;
      }
    }
    return false;
  }
}
