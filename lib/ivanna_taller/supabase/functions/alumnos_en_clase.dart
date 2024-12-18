import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';

class AlumnosEnClase {
  Future<List<String>> clasesAlumno(String alumno) async {
    final clases = await ObtenerTotalInfo().obtenerInfo();
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
