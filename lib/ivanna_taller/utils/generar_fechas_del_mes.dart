import 'package:intl/intl.dart';

class GenerarFechasDelMes {
  List<String> generarFechasLunesAViernes() {
    final DateFormat formato = DateFormat('dd/MM/yyyy');
    final List<String> fechas = [];
    final DateTime inicio = DateTime(2025, 2, 3);
    final DateTime fin = DateTime(2025, 2, 28);

    for (DateTime fecha = inicio;
        fecha.isBefore(fin) || fecha.isAtSameMomentAs(fin);
        fecha = fecha.add(const Duration(days: 1))) {
      if (fecha.weekday >= DateTime.monday &&
          fecha.weekday <= DateTime.friday) {
        fechas.add(formato.format(fecha));
      }
    }

    return fechas;
  }
}
