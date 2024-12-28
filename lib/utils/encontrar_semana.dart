import 'package:intl/intl.dart';

class EncontrarSemana {
  String obtenerSemana(String fechaStr) {
    // Parsear la fecha desde el string en formato "dd/MM/yyyy"
    DateFormat formatoFecha = DateFormat("dd/MM/yyyy");
    DateTime fecha = formatoFecha.parse(fechaStr);

    // Obtener el primer día del mes
    DateTime primerDiaMes = DateTime(fecha.year, fecha.month, 1);

    // Calcular el número de días que han pasado desde el primer día del mes
    int diasDesdeInicioMes = fecha.difference(primerDiaMes).inDays;

    // Calcular el número de semana. Se usa +1 para que la semana 1 comience en el primer día del mes.
    int semana = (diasDesdeInicioMes / 7).floor() + 1;

    // Si la fecha cae en la última semana (por ejemplo, el 29 de diciembre al 4 de enero),
    // ajustar la semana para que sea la última semana del mes
    if (fecha.month != primerDiaMes.month) {
      semana =
          5; // Esta es la "semana 5" que abarca el final del mes y el inicio del siguiente mes.
    }

    return 'semana$semana';
  }
}
