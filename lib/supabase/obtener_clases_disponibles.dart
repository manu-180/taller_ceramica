import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_total_info.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerClasesDisponibles {
  Future<int> clasesDisponibles(String user) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.clasesDisponibles;
      }
    }
    return 0;
  }
}
