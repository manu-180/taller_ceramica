import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class ObtenerMes {
  Future<int> obtenerMes() async {
    // Obtener usuario activo
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    if (usuarioActivo == null) {
      throw Exception("Usuario no autenticado");
    }

    final taller = await ObtenerTaller().retornarTaller(usuarioActivo.id);

    final data = await supabase
    .from(taller)
    .select("mes")
    .limit(1)
    .single();

    return data["mes"];
  }
}
