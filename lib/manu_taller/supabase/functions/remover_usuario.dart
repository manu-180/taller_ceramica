import 'package:taller_ceramica/utils/utils_barril.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/models/clase_models.dart';

import '../../../ivanna_taller/supabase/supabase_barril.dart';

class RemoverUsuarioManu {
  final SupabaseClient supabaseClient;

  RemoverUsuarioManu(this.supabaseClient);

  Future<void> removerUsuarioDeClaseManu(
      int idClase, String user, bool parametro) async {
    final data = await ObtenerTotalInfoManu().obtenerClaseManu();

    for (final item in data) {
      if (item.id == idClase) {
        final listUsers = item.mails;
        if (listUsers.contains(user)) {
          listUsers.remove(user);
          await supabaseClient
              .from('clasesmanu')
              .update({'mails': listUsers}).eq('id', idClase);
          ModificarLugarDisponibleManu().agregarLugarDisponibleManu(idClase);
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

  Future<void> removerUsuarioDeMuchasClaseManu(
      ClaseModels clase, String user) async {
    final data = await ObtenerTotalInfoManu().obtenerClaseManu();

    for (final item in data) {
      if (clase.hora == item.hora && clase.dia == item.dia) {
        if (item.mails.contains(user)) {
          item.mails.remove(user);
          await supabaseClient
              .from('clasesmanu')
              .update(item.toMap())
              .eq('id', item.id);
          ModificarLugarDisponibleManu().agregarLugarDisponibleManu(item.id);
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
