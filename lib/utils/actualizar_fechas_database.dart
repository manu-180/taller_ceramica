import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';

class ActualizarFechasDatabase {
  Future<void> actualizarClasesAlNuevoMes(String taller, int mes, int year) async {
    try {
      // Obtener todas las clases actuales del taller
      final clasesResponse = await supabase.from(taller).select();
      final clases = (clasesResponse as List<dynamic>)
          .map((clase) => ClaseModels.fromMap(clase))
          .toList();

      // Crear un mapa para organizar las clases por combinación (día, hora)
      final Map<String, List<ClaseModels>> clasesPorDiaYHora = {};

      for (var clase in clases) {
        final key = '${clase.dia}-${clase.hora}';
        clasesPorDiaYHora.putIfAbsent(key, () => []).add(clase);
      }

      final List<ClaseModels> clasesNuevas = [];

      for (var entry in clasesPorDiaYHora.entries) {
        final clasesDiaHora = entry.value;

        // Ordenar por fecha para garantizar que las clases se procesen en orden semanal
        clasesDiaHora.sort((a, b) => DateFormat('dd/MM/yyyy')
            .parse(a.fecha)
            .compareTo(DateFormat('dd/MM/yyyy').parse(b.fecha)));

        // Calcular nuevas fechas
        for (var i = 0; i < clasesDiaHora.length; i++) {
          final clase = clasesDiaHora[i];
          final nuevaFecha = calcularNuevaFechaPorSemana(clase.fecha, mes, year, i);

          // Convertir la nueva fecha a String
          final nuevaFechaStr = DateFormat('dd/MM/yyyy').format(nuevaFecha);

          // Si ya existe una clase con la misma fecha y hora, combinar alumnos
          final ClaseModels claseExistente = clasesNuevas.firstWhere(
            (c) => c.fecha == nuevaFechaStr && c.hora == clase.hora && c.dia == clase.dia,
            orElse: () => ClaseModels(
              id: -1,
              semana: '',
              dia: '',
              fecha: '',
              hora: '',
              mails: [],
              lugaresDisponibles: 0,
            ),
          );

          if (claseExistente.id == -1) {
            // Crear nueva clase
            clasesNuevas.add(clase.copyWith(fecha: nuevaFechaStr));
          } else {
            // Combinar alumnos
            claseExistente.mails.addAll(clase.mails);
          }
        }
      }

      // Limpiar la tabla del taller y reinsertar las clases actualizadas
      await supabase.from(taller).delete().neq('id', 0); // Eliminar todas las clases
      final batchInsert = clasesNuevas.map((clase) => clase.toMap()).toList();
      await supabase.from(taller).insert(batchInsert);

      debugPrint('Clases actualizadas correctamente para el nuevo mes.');
    } catch (e) {
      debugPrint('Error al actualizar las clases: $e');
      throw Exception('No se pudieron actualizar las clases: $e');
    }
  }

  // Función para calcular la nueva fecha para cada semana del mes siguiente
  DateTime calcularNuevaFechaPorSemana(String fechaActualStr, int mes, int year, int semanaIndex) {
    final fechaActual = DateFormat('dd/MM/yyyy').parse(fechaActualStr);

    // Calcular el primer día del mes siguiente
    final nuevoMes = mes + 1;
    final firstDayOfNextMonth = DateTime(year, nuevoMes, 1);

    // Encontrar el día objetivo (mismo día de la semana que la clase actual)
    final weekday = fechaActual.weekday;
    final difference = (weekday - firstDayOfNextMonth.weekday + 7) % 7;

    // Calcular la fecha específica para la semana actual
    final nuevaFechaBase = firstDayOfNextMonth.add(Duration(days: difference));
    final nuevaFechaSemana = nuevaFechaBase.add(Duration(days: 7 * semanaIndex));
    return nuevaFechaSemana;
  }
}
