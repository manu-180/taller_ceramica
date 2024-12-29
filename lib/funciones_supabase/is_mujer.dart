import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';

class IsMujer {
  Future<bool> mujer(String usuario) async {
    
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    if (usuarioActivo == null) {
      return false; 
    }
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo.id);
    final users = await ObtenerTotalInfo(supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller).obtenerUsuarios();
    

    for (final user in users) {
      if (user.fullname == usuario && user.sexo == "mujer") {
        return true;
      }
    }
    return false;
  }
}
