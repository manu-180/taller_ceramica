import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerAlertTrigger {
  Future<int> alertTrigger(String user) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.alertTrigger;
      }
    }
    return 0;
  }
}
