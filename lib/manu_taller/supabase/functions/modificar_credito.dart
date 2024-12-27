import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_alert_trigger.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class ModificarCreditoManu {
  Future<bool> agregarCreditoUsuarioManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final usuario in data) {
      if (usuario.fullname == user) {
        var creditosActualmente = usuario.clasesDisponibles;
        creditosActualmente += 1;
        await supabase.from('usuariosmanu').update(
            {'clases_disponibles': creditosActualmente}).eq('id', usuario.id);
        ModificarAlertTriggerManu().resetearAlertTriggerManu(usuario.fullname);
      }
    }

    return true;
  }

  Future<bool> removerCreditoUsuarioManu(String user) async {
    final data = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final usuario in data) {
      if (usuario.fullname == user) {
        var creditosActualmente = usuario.clasesDisponibles;
        creditosActualmente -= 1;
        if (usuario.clasesDisponibles > 0) {
          await supabase.from('usuariosmanu').update(
              {'clases_disponibles': creditosActualmente}).eq('id', usuario.id);
          ModificarAlertTrigger().resetearAlertTrigger(usuario.fullname);
        }
      }
    }

    return true;
  }
}
