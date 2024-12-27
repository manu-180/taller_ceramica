
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class ObtenerLugaresDeClasesManu {
  Future<int?> lugaresDisponiblesManu(int id) async {
    final data = await ObtenerTotalInfoManu().obtenerClaseManu();

    for (final item in data) {
      if (item.id == id) {
        return item.lugaresDisponibles;
      }
    }
    return 0;
  }
}
