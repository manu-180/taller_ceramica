import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ObtenerAlertTrigger {
  Future<int> alertTrigger(String user) async {
    final data = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.alertTrigger;
      }
    }
    return 0;
  }
}
