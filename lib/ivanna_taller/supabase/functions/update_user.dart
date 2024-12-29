import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class UpdateUser {
  final SupabaseClient supabaseClient;

  UpdateUser(this.supabaseClient);

  Future<void> updateUser(String user, String updateUser) async {
    final clases = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerClases();

    for (final clase in clases) {
      if (clase.mails.contains(user)) {
        final listUsers = clase.mails;
        listUsers.remove(user);
        listUsers.add(updateUser);
        await supabaseClient
            .from('total')
            .update({'mails': listUsers}).eq('id', clase.id);
      }
    }
  }

  Future<void> updateTableUser(String userUid, String updateUser) async {
    final users = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: 'total').obtenerUsuarios();

    for (final user in users) {
      if (user.userUid == userUid) {
        final newName = updateUser;
        await supabaseClient
            .from('usuarios')
            .update({'fullname': newName}).eq('id', user.id);
      }
    }
  }
}
