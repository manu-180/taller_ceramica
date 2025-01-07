import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class ObtenerCapacidadClase {
  Future<int> capacidadClase(int claseId) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    if (usuarioActivo == null) {
      return 0;
    }
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo.id);
    final clases = await ObtenerTotalInfo(
            supabase: supabase, clasesTable: taller, usuariosTable: "usuarios")
        .obtenerClases();

    for (final clase in clases) {
      if (clase.id == claseId) {
        return clase.capacidad;
      }
    }
    return 0;
  }
}
