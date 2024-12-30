import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';

class AlumnosEnClase {
  Future<List<String>> clasesAlumno(String alumno) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    final clases = await ObtenerTotalInfo(
            supabase: supabase, usuariosTable: 'usuarios', clasesTable: taller)
        .obtenerClases();
    final List<String> listAlumnos = [];

    for (final clase in clases) {
      if (clase.mails.contains(alumno)) {
        final partesFecha = clase.fecha.split('/');
        listAlumnos.add("${clase.dia} ${partesFecha[0]} a las ${clase.hora}");
      }
    }
    return listAlumnos;
  }
}
