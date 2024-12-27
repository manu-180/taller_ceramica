
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class ObtenerClasesDisponiblesManu {
  Future<int> clasesDisponiblesManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final item in data) {
      if (item.fullname == user) {
        return item.clasesDisponibles;
      }
    }
    return 0;
  }
}
