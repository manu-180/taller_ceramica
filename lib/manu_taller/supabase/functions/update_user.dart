import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class UpdateUserManu {
  final SupabaseClient supabaseClient;

  UpdateUserManu(this.supabaseClient);

  Future<void> updateUserManu(String user, String updateUser) async {
    final clases = await ObtenerTotalInfoManu().obtenerClaseManu();

    for (final clase in clases) {
      if (clase.mails.contains(user)) {
        final listUsers = clase.mails;
        listUsers.remove(user);
        listUsers.add(updateUser);
        await supabaseClient
            .from('clasesmanu')
            .update({'mails': listUsers}).eq('id', clase.id);
      }
    }
  }

  Future<void> updateTableUserManu(String userUid, String updateUser) async {
    final users = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    for (final user in users) {
      if (user.userUid == userUid) {
        final newName = updateUser;
        await supabaseClient
            .from('usuariosmanu')
            .update({'fullname': newName}).eq('id', user.id);
      }
    }
  }
}
