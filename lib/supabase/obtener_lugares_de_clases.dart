import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerLugaresDeClases {
  Future<int?> lugaresDisponibles(int id) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerClases();

    for (final item in data) {
      if (item.id == id) {
        return item.lugaresDisponibles;
      }
    }
    return 0;
  }
}
