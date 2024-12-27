
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class ObtenerIdManu {
  Future<int> obtenerIDManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final item in data) {
      if (item.fullname == user) {
        return item.id;
      }
    }
    return 0;
  }
}
