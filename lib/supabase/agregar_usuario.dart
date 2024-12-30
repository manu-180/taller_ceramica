import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/modificar_credito.dart';
import 'package:taller_ceramica/supabase/obtener_total_info.dart';
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
        if (usuario.clasesDisponibles > 0 || parametro) {
          if (!clase.mails.contains(user)) {
            clase.mails.add(user);
            await supabaseClient
                .from(taller)
                .update(clase.toMap())
                .eq('id', idClase);
            ModificarLugarDisponible().removerLugarDisponible(idClase);
            if (parametro) {
              EnviarWpp().sendWhatsAppMessage(
                  "Has insertado a $user a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                  'whatsapp:+5491134272488');
              EnviarWpp().sendWhatsAppMessage(
                  "Has insertado a $user a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}",
                  'whatsapp:+5491132820164');
            }
            if (!parametro) {
              ModificarCredito().removerCreditoUsuario(user);
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

  Future<void> agregarUsuarioEnCuatroClases(
      ClaseModels clase, String user) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    final data = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerClases();

    // Mapa para ordenar días de la semana en orden correcto
    final Map<String, int> diaToNumero = {
      'lunes': 1,
      'martes': 2,
      'miercoles': 3,
      'jueves': 4,
      'viernes': 5,
      'sabado': 6,
      'domingo': 7,
    };

    // Función para convertir "dd/mm/yyyy" a DateTime
    DateTime parseFecha(String fecha) {
      // Ej: "01/01/2025"
      final partes = fecha.split('/');
      final dd = int.tryParse(partes[0]) ?? 0;
      final mm = int.tryParse(partes[1]) ?? 0;
      final yyyy = int.tryParse(partes[2]) ?? 0;
      return DateTime(yyyy, mm, dd);
    }

    // 1. Ordenamos la lista primero por día de la semana, luego por fecha
    data.sort((a, b) {
      // Orden por el valor numérico del día de la semana
      final diaCompare = diaToNumero[a.dia]!.compareTo(diaToNumero[b.dia]!);
      if (diaCompare != 0) {
        return diaCompare;
      }

      // Si los dos items son del mismo día (ej. ambos "miercoles"), ordena por fecha
      final dateA = parseFecha(a.fecha);
      final dateB = parseFecha(b.fecha);
      return dateA.compareTo(dateB);
    });

    // 2. Variables para identificar el mes y año actual
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // 3. Insertar al usuario en hasta 4 clases
    int count = 0;

    for (final item in data) {
      // Parseamos la fecha de la clase para ver si es de este mes/año
      final partes = item.fecha.split('/');
      if (partes.length == 3) {
        final dd = int.tryParse(partes[0]) ?? 0;
        final mm = int.tryParse(partes[1]) ?? 0;
        final yyyy = int.tryParse(partes[2]) ?? 0;

        // Filtramos SOLO las clases del mes y año actuales
        if (mm == 1 && yyyy == 2025) {
          // Verificamos que sea la misma combinación de (dia + hora)
          if (item.dia == clase.dia && item.hora == clase.hora) {
            // Inserta solo si el usuario no está, y si no excedimos 4
            if (!item.mails.contains(user) && count < 4) {
              item.mails.add(user);

              // Actualizar en Supabase
              await supabaseClient
                  .from(taller)
                  .update(item.toMap())
                  .eq('id', item.id);

              // Disminuir cupos
              ModificarLugarDisponible().removerLugarDisponible(item.id);

              count++;
            }
          }
        }
      }
    }

    // 4. Al final, si llegamos a 4 inserciones, avisamos por WhatsApp
    if (count == 4) {
      EnviarWpp().sendWhatsAppMessage(
        "Has insertado a $user a 4 clases el día ${clase.dia} a las ${clase.hora}",
        'whatsapp:+5491134272488',
      );
    }
  }
}
