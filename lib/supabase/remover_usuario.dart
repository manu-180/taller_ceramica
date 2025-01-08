import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/utils/calcular_24hs.dart';
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
            EnviarWpp().sendWhatsAppMessage(
              "HXd9ba581e7d5b1a3c7740c90d870fe7b7",
              'whatsapp:+5491134272488',
                Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)
                    ? [user, clase.dia, clase.fecha, clase.hora, "Se genero un credito para recuperar la clase"]
                    : [user, clase.dia, clase.fecha, clase.hora, "Cancelo con menos de 24 horas de anticipacion, no podra recuperar la clase"],
                );
          }
          if (parametro) {
             EnviarWpp().sendWhatsAppMessage(
              "HXc0f22718dded5d710b659d89b4117bb1",
              'whatsapp:+5491134272488',
              [user, clase.dia, clase.fecha, clase.hora]
                );
          }
        }
      }
    }
  }

  Future<void> removerUsuarioDeMuchasClase(
      ClaseModels clase, String user) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerClases();

    for (final clase in data) {
      if (clase.hora == clase.hora && clase.dia == clase.dia) {
        if (clase.mails.contains(user)) {
          clase.mails.remove(user);
          await supabaseClient
              .from(taller)
              .update(clase.toMap())
              .eq('id', clase.id);
          ModificarLugarDisponible().agregarLugarDisponible(clase.id);
        }
      }
    }
    EnviarWpp().sendWhatsAppMessage(
              "HX2dcf10749ec095471f99620be45dbc11",
              'whatsapp:+5491134272488',
              [user]
                );
  }
}
