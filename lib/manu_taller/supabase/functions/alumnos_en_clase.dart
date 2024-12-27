import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class AlumnosEnClaseManu {
  Future<List<String>> clasesAlumnoManu(String alumno) async {
    final clases = await ObtenerTotalInfoManu().obtenerClaseManu();
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
