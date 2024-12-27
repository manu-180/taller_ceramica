import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ModificarAlertTrigger {
  Future<bool> agregarAlertTrigger(String user) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final usuario in data) {
      if (usuario.fullname == user) {
        await supabase
            .from('usuarios')
            .update({'trigger_alert': 1}).eq('id', usuario.id);
      }
    }
    return true;
  }

  Future<bool> resetearAlertTrigger(String user) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        await supabase
            .from('usuarios')
            .update({'trigger_alert': 0}).eq('id', item.id);
      }
    }
    return true;
  }
}
