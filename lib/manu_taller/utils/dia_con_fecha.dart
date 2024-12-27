import 'package:intl/intl.dart';

class DiaConFecha {
  String obtenerDiaDeLaSemana(String? fecha) {
    // Verificar si la fecha es nula o no tiene el formato esperado
    if (fecha == null || fecha.isEmpty || fecha == "Seleccione una fecha") {
      return "Seleccione una fecha";
    }

    try {
      // Parsear la fecha desde el formato "dd/MM/yyyy"
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(fecha);

      // Lista de días de la semana en español
      const diasDeLaSemana = [
        'lunes',
        'martes',
        'miércoles',
        'jueves',
        'viernes',
        'sábado',
        'domingo',
      ];

      // Retornar el día correspondiente (DateTime.weekday devuelve 1 para lunes, 7 para domingo)
      return diasDeLaSemana[parsedDate.weekday - 1];
    } catch (e) {
      return "-";
    }
  }
}
