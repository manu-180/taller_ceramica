import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class EliminarUsuario {
  Future<void> eliminarDeBaseDatos(int userId) async {
    final dataClases = await ObtenerTotalInfoManu().obtenerClaseManu();
    final dataUsuarios = await ObtenerTotalInfoManu().obtenerUsuariosManu();

    var user = "";

    await supabase.from('usuariosmanu').delete().eq('id', userId);

    for (var usuario in dataUsuarios) {
      if (usuario.id == userId) {
        user = usuario.fullname;
      }
    }
    for (var clase in dataClases) {
      if (clase.mails.contains(user)) {
        var alumnos = clase.mails;
        alumnos.remove(user);
        await supabase
            .from('clasesmanu')
            .update({'mails': alumnos}).eq('id', clase.id);
      }
    }
  }
}
