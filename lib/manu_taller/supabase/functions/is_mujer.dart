
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class IsMujer {
  Future<bool> mujer(String usuario) async {
    final users = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final user in users) {
      if (user.fullname == usuario && user.sexo == "mujer") {
        return true;
      }
    }
    return false;
  }
}
