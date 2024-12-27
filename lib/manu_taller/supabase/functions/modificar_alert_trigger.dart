import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class ModificarAlertTriggerManu {
  Future<bool> agregarAlertTriggerManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final usuario in data) {
      // ignore: unrelated_type_equality_checks
      if (usuario.fullname == user) {
        await supabase
            .from('usuariosmanu')
            .update({'trigger_alert': 1}).eq('id', usuario.id);
      }
    }
    return true;
  }

  Future<bool> resetearAlertTriggerManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final item in data) {
      if (item.fullname == user) {
        await supabase
            .from('usuariosmanu')
            .update({'trigger_alert': 0}).eq('id', item.id);
      }
    }
    return true;
  }
}
