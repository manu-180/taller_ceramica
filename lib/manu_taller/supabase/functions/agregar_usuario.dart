import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/funciones_globales/utils/utils_barril.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/models/clase_models.dart';

class AgregarUsuarioManu {
  final SupabaseClient supabaseClient;

  AgregarUsuarioManu(this.supabaseClient);

  Future<void> agregarUsuarioAClaseManu(
      int idClase, String user, bool parametro, ClaseModels claseModels) async {
    final usuarios = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    final data =
        await supabaseClient.from('clasesmanu').select().eq('id', idClase).single();

    final clase = ClaseModels.fromMap(data);

    for (final usuario in usuarios) {
      if (usuario.fullname == user) {
        if (usuario.clasesDisponibles > 0 || parametro) {
          if (!clase.mails.contains(user)) {
            clase.mails.add(user);
            await supabaseClient
                .from('clasesmanu')
                .update(clase.toMap())
                .eq('id', idClase);
            ModificarLugarDisponibleManu().removerLugarDisponibleManu(idClase);
            if (parametro) {
              EnviarWpp().sendWhatsAppMessage(
                  "Has insertado a $user a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                  'whatsapp:+5491134272488');
              EnviarWpp().sendWhatsAppMessage(
                  "Has insertado a $user a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                  'whatsapp:+5491132820164');
            }
            if (!parametro) {
              ModificarCreditoManu().removerCreditoUsuarioManu(user);
              EnviarWpp().sendWhatsAppMessage(
                  "$user se ha inscripto a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                  'whatsapp:+5491134272488');
              EnviarWpp().sendWhatsAppMessage(
                  "$user se ha inscripto a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                  'whatsapp:+5491132820164');
            }
          }
        }
      }
    }
  }

  Future<void> agregarUsuarioEnCuatroClasesManu(
      ClaseModels clase, String user) async {
    final data = await ObtenerTotalInfoManu().obtenerClaseManu();
    final Map<String, int> diaToNumero = {
      'lunes': 1,
      'martes': 2,
      'miercoles': 3,
      'jueves': 4,
      'viernes': 5,
      'sabado': 6,
      'domingo': 7,
    };

    data.sort((a, b) => diaToNumero[a.dia]!.compareTo(diaToNumero[b.dia]!));

    int count = 0;

    for (final item in data) {
      if (item.dia == clase.dia && item.hora == clase.hora) {
        if (!item.mails.contains(user) && count < 4) {
          item.mails.add(user);
          await supabaseClient
              .from('clasesmanu')
              .update(item.toMap())
              .eq('id', item.id);
          ModificarLugarDisponibleManu().removerLugarDisponibleManu(item.id);
          count++;
        }
      }
    }

    // Enviar el mensaje al usuario solo después de que se haya agregado a las 4 clases
    if (count == 4) {
      EnviarWpp().sendWhatsAppMessage(
          "Has insertado a $user a 4 clases el día ${clase.dia} a las ${clase.hora}",
          'whatsapp:+5491134272488');
    }
  }
}
