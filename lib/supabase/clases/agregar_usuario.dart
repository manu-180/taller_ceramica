import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_mes.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/modificar_datos/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/modificar_datos/modificar_credito.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_total_info.dart';
import 'package:taller_ceramica/utils/enviar_wpp.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(
      int idClase, String user, bool parametro, ClaseModels claseModels) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final usuarios = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerUsuarios();

    final data =
        await supabaseClient.from(taller).select().eq('id', idClase).single();

    final clase = ClaseModels.fromMap(data);

    for (final usuario in usuarios) {
      if (usuario.fullname == user) {
        if (usuario.clasesDisponibles! > 0 || parametro) {
          if (!clase.mails.contains(user)) {
            clase.mails.add(user);
            await supabaseClient
                .from(taller)
                .update(clase.toMap())
                .eq('id', idClase);
            ModificarLugarDisponible().removerLugarDisponible(idClase);
            if (parametro) {
              // EnviarWpp().sendWhatsAppMessage(
              // "HX13d84cd6816c60f21f172fe42bb3b0bb",
              // 'whatsapp:+5491134272488',
              // [user, clase.dia, clase.fecha, clase.hora]
              //   );

              EnviarWpp().enviarMensajesViejo(
                "$user se ha sumado existosamente a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                'whatsapp:+5491132820164',
              );
            }
            if (!parametro) {
              ModificarCredito().removerCreditoUsuario(user);
              // EnviarWpp().sendWhatsAppMessage(
              // "HXefcf9346661c8871da3f019743967611",
              // 'whatsapp:+5491134272488',
              // [user, clase.dia, clase.fecha, clase.hora]
              //   );
              EnviarWpp().enviarMensajesViejo(
                "has insertado existosamente a $user de las la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                'whatsapp:+5491132820164',
              );
            }
          }
        }
      }
    }
  }

  Future<void> agregarUsuarioEnCuatroClases(ClaseModels clase, String user,
      void Function(ClaseModels claseActualizada) callback) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerClases();

    final Map<String, int> diaToNumero = {
      'lunes': 1,
      'martes': 2,
      'miercoles': 3,
      'jueves': 4,
      'viernes': 5,
      'sabado': 6,
      'domingo': 7,
    };

    DateTime parseFecha(String fecha) {
      final partes = fecha.split('/');
      final dd = int.tryParse(partes[0]) ?? 0;
      final mm = int.tryParse(partes[1]) ?? 0;
      final yyyy = int.tryParse(partes[2]) ?? 0;
      return DateTime(yyyy, mm, dd);
    }

    data.sort((a, b) {
      final diaCompare = diaToNumero[a.dia]!.compareTo(diaToNumero[b.dia]!);
      if (diaCompare != 0) {
        return diaCompare;
      }

      final dateA = parseFecha(a.fecha);
      final dateB = parseFecha(b.fecha);
      return dateA.compareTo(dateB);
    });

    int count = 0;

    for (final item in data) {
      final partes = item.fecha.split('/');
      if (partes.length == 3) {
        if (item.dia == clase.dia && item.hora == clase.hora) {
          if (!item.mails.contains(user) && count < 4) {
            item.mails.add(user);

            await supabaseClient
                .from(taller)
                .update(item.toMap())
                .eq('id', item.id);

            ModificarLugarDisponible().removerLugarDisponible(item.id);

            callback(item);

            count++;
          }
        }
      }
    }

    // 4. Al final, si llegamos a 4 inserciones, avisamos por WhatsApp
    if (count == 4) {
      // EnviarWpp().sendWhatsAppMessage(
      //         "HX6dad986ed219654d62aed35763d10ccb",
      //         'whatsapp:+5491134272488',
      //         [user, clase.dia]
      //           );
      EnviarWpp().enviarMensajesViejo(
        "has insertado existosamente a $user de las 4 clasea del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
        'whatsapp:+5491132820164',
      );
    }
  }

  Future<void> agregarUsuarioAListaDeEspera(int id, String user) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    final data =
        await supabaseClient.from(taller).select().eq('id', id).single();
    final clase = ClaseModels.fromMap(data);

    if (!clase.espera.contains(user)) {
      clase.espera.add(user);

      await supabaseClient
          .from(taller)
          .update({"espera": clase.espera}).eq('id', id);
    }
  }
}