import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerClasesDisponibles {
  Future<int> clasesDisponibles(String user) async {
    final data = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.clasesDisponibles;
      }
    }
    return 0;
  }
}
