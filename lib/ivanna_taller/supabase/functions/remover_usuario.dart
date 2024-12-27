import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/calcular_24hs.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/funciones_globales/utils_barril.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(
      int idClase, String user, bool parametro) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final item in data) {
      if (item.id == idClase) {
        final listUsers = item.mails;
        if (listUsers.contains(user)) {
          listUsers.remove(user);
          await supabaseClient
              .from('total')
              .update({'mails': listUsers}).eq('id', idClase);
          ModificarLugarDisponible().agregarLugarDisponible(idClase);
          if (!parametro) {
            EnviarWpp().sendWhatsAppMessage(
                Calcular24hs().esMayorA24Horas(item.fecha, item.hora)
                    ? "$user ha cancelado la clase del dia ${item.dia} ${item.fecha} a las ${item.hora}. Se genero un credito para recuperar la clase"
                    : "$user ha cancelado la clase del dia ${item.dia} ${item.fecha} a las ${item.hora}. No podra recuperar la clase",
                'whatsapp:+5491134272488');
            EnviarWpp().sendWhatsAppMessage(
                Calcular24hs().esMayorA24Horas(item.fecha, item.hora)
                    ? "$user ha cancelado la clase del dia ${item.dia} ${item.fecha} a las ${item.hora}. ¡Se genero un credito para recuperar la clase!"
                    : "$user ha cancelado la clase del dia ${item.dia} ${item.fecha} a las ${item.hora}. No podra recuperar la clase",
                'whatsapp:+5491132820164');
          }
          if (parametro) {
            EnviarWpp().sendWhatsAppMessage(
                "Has removido a $user a la clase del dia ${item.dia} ${item.fecha} a las ${item.hora}",
                'whatsapp:+5491134272488');
            EnviarWpp().sendWhatsAppMessage(
                "Has removido a $user a la clase del dia ${item.dia} ${item.fecha} a las ${item.hora}",
                'whatsapp:+5491132820164');
          }
        }
      }
    }
  }

  Future<void> removerUsuarioDeMuchasClase(
      ClaseModels clase, String user) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final item in data) {
      if (clase.hora == item.hora && clase.dia == item.dia) {
        if (item.mails.contains(user)) {
          item.mails.remove(user);
          await supabaseClient
              .from('total')
              .update(item.toMap())
              .eq('id', item.id);
          ModificarLugarDisponible().agregarLugarDisponible(item.id);
        }
      }
    }
    EnviarWpp().sendWhatsAppMessage(
        "Has removido a $user a 4 clases el dia ${clase.dia} a las ${clase.hora}",
        'whatsapp:+5491134272488');
    EnviarWpp().sendWhatsAppMessage(
        "Has removido a $user a 4 clases el dia ${clase.dia} a las ${clase.hora}",
        'whatsapp:+5491132820164');
  }
}
