
import 'package:taller_ceramica/manu_taller/supabase/functions/obtener_total_info.dart';

class ObtenerAlertTriggerManu {
  Future<int> alertTriggerManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final item in data) {
      if (item.fullname == user) {
        return item.alertTrigger;
      }
    }
    return 0;
  }
}
