import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/obtener_total_info.dart';
import 'package:taller_ceramica/utils/utils_barril.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(
      int idClase, String user, bool parametro) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerClases();

    for (final clase in data) {
      if (clase.id == idClase) {
        final listUsers = clase.mails;
        if (listUsers.contains(user)) {
          listUsers.remove(user);
          await supabaseClient
              .from(taller)
              .update({'mails': listUsers}).eq('id', idClase);
          ModificarLugarDisponible().agregarLugarDisponible(idClase);
          if (!parametro) {
            // EnviarWpp().sendWhatsAppMessage(
            //   "HXd9ba581e7d5b1a3c7740c90d870fe7b7",
            //   'whatsapp:+5491134272488',
            //     Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)
            //         ? [user, clase.dia, clase.fecha, clase.hora, "Se genero un credito para recuperar la clase"]
            //         : [user, clase.dia, clase.fecha, clase.hora, "Cancelo con menos de 24 horas de anticipacion, no podra recuperar la clase"],
            //     );

            EnviarWpp().enviarMensajesViejo(
              "$user ha canelado existosamente la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
              'whatsapp:+5491134272488',
            );
          }
          if (parametro) {
            //  EnviarWpp().sendWhatsAppMessage(
            //   "HXc0f22718dded5d710b659d89b4117bb1",
            //   'whatsapp:+5491134272488',
            //   [user, clase.dia, clase.fecha, clase.hora]
            //     );
            EnviarWpp().enviarMensajesViejo(
              "has removido existosamente a $user de las la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
              'whatsapp:+54911',
            );
          }
        }
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

    // Renombramos la variable del for a 'item' para no chocar con la variable 'clase'
    for (final item in data) {
      // Comparamos con la "clase base" a remover
      if (item.hora == clase.hora && item.dia == clase.dia) {
        if (item.mails.contains(user)) {
          // Remover usuario de mails
          item.mails.remove(user);

          // Actualizamos en Supabase
          await supabaseClient
              .from(taller)
              .update(item.toMap())
              .eq('id', item.id);

          ModificarLugarDisponible().agregarLugarDisponible(item.id);

          // Llamamos al callback si no es null
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
      'whatsapp:+5491134272488',
    );
  }
}
