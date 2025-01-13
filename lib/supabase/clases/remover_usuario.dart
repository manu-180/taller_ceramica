import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/modificar_datos/modificar_alert_trigger.dart';
import 'package:taller_ceramica/supabase/modificar_datos/modificar_credito.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/modificar_datos/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_total_info.dart';
import 'package:taller_ceramica/utils/calcular_24hs.dart';
import 'package:taller_ceramica/utils/utils_barril.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(
      int idClase, String user, bool parametro) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    // Obtener la clase específica usando .single()
    final data =
        await supabaseClient.from(taller).select().eq('id', idClase).single();

    final clase = ClaseModels.fromMap(data);

    if (clase.mails.contains(user)) {
      clase.mails.remove(user);
      await supabaseClient
          .from(taller)
          .update({'mails': clase.mails}).eq('id', idClase);

      ModificarLugarDisponible().agregarLugarDisponible(idClase);

      // Manejo de la lista de espera
      if (clase.espera.isNotEmpty) {
        final copiaEspera = List<String>.from(clase.espera);

        for (final userEspera in copiaEspera) {
          if (await ObtenerClasesDisponibles().clasesDisponibles(userEspera) >
              0) {
            clase.mails.add(userEspera);
            clase.espera.remove(userEspera);

            await supabaseClient
                .from(taller)
                .update({'espera': clase.espera}).eq('id', idClase);
            await supabaseClient
                .from(taller)
                .update({'mails': clase.mails}).eq('id', idClase);

            ModificarCredito().removerCreditoUsuario(userEspera);

            EnviarWpp().enviarMensajesViejo(
              "$userEspera estaba en lista de espera y fue agregado/a exitosamente a la clase del día ${clase.dia} ${clase.fecha} a las ${clase.hora}",
              'whatsapp:+5491134272488',
            );

            return; // Salimos porque solo procesamos un usuario de la lista de espera
          }
        }
      }

      // Manejo de créditos o alertas
      if (!parametro) {
        if (Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)) {
          ModificarCredito().agregarCreditoUsuario(user);
        } else {
          ModificarAlertTrigger().agregarAlertTrigger(user);
        }

        EnviarWpp().enviarMensajesViejo(
          "$user ha cancelado exitosamente la clase del día ${clase.dia} ${clase.fecha} a las ${clase.hora}",
          'whatsapp:+5491132820164',
        );
        // EnviarWpp().sendWhatsAppMessage(
        //   "HXd9ba581e7d5b1a3c7740c90d870fe7b7",
        //   'whatsapp:+5491134272488',
        //     Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)
        //         ? [user, clase.dia, clase.fecha, clase.hora, "Se genero un credito para recuperar la clase"]
        //         : [user, clase.dia, clase.fecha, clase.hora, "Cancelo con menos de 24 horas de anticipacion, no podra recuperar la clase"],
        //     );
      } else {
        EnviarWpp().enviarMensajesViejo(
          "Has removido exitosamente a $user de la clase del día ${clase.dia} ${clase.fecha} a las ${clase.hora}",
          'whatsapp:+5491132820164',
        );
        //  EnviarWpp().sendWhatsAppMessage(
        //   "HXc0f22718dded5d710b659d89b4117bb1",
        //   'whatsapp:+5491134272488',
        //   [user, clase.dia, clase.fecha, clase.hora]
        //     );
      }
    }
  }

  Future<void> removerUsuarioDeMuchasClase(
    ClaseModels clase,
    String user,
    void Function(ClaseModels claseActualizada)? callback, // callback opcional
  ) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final data = await ObtenerTotalInfo(
      supabase: supabase,
      usuariosTable: 'usuarios',
      clasesTable: taller,
    ).obtenerClases();

    for (final item in data) {
      if (item.hora == clase.hora && item.dia == clase.dia) {
        if (item.mails.contains(user)) {
          item.mails.remove(user);

          await supabaseClient
              .from(taller)
              .update(item.toMap())
              .eq('id', item.id);

          ModificarLugarDisponible().agregarLugarDisponible(item.id);

          if (callback != null) {
            callback(item);
          }
        }
      }
    }

    // Enviamos el mensaje de WhatsApp al final (o antes, según lo necesites)
    // EnviarWpp().sendWhatsAppMessage(
    //   "HX2dcf10749ec095471f99620be45dbc11",
    //   'whatsapp:+5491134272488',
    //   [user],
    // );

    EnviarWpp().enviarMensajesViejo(
      "has removido existosamente a $user de las 4 clases",
      'whatsapp:+5491132820164',
    );
  }

  Future<void> removerUsuarioDeListaDeEspera(int idClase, String user) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    final data =
        await supabaseClient.from(taller).select().eq('id', idClase).single();

    final clase = ClaseModels.fromMap(data);

    if (clase.espera.contains(user)) {
      clase.espera.remove(user);

      await supabaseClient
          .from(taller)
          .update({"espera": clase.espera}).eq('id', idClase);

      EnviarWpp().enviarMensajesViejo(
        "$user canceló su clase de lista de espera el ${clase.dia} ${clase.fecha} a las ${clase.hora}",
        'whatsapp:+5491134272488',
      );
    }
  }
}
