import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerLugaresDeClases {
  Future<int?> lugaresDisponibles(int id) async {
    final data = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerClases();

    for (final item in data) {
      if (item.id == id) {
        return item.lugaresDisponibles;
      }
    }
    return 0;
  }
}
