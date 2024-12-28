class GenerarFechas {
  List<String> generarFechas(DateTime fechaInicio, DateTime fechaFin) {
    // Días hábiles permitidos: lunes a viernes
    List<int> diasHabiles = [1, 2, 3, 4, 5]; // Lunes, Martes, Miércoles, Jueves, Viernes
    List<String> listaFechas = [];

    // Iterar desde la fecha inicial hasta la fecha final
    DateTime fechaActual = fechaInicio;
    while (fechaActual.isBefore(fechaFin) || fechaActual.isAtSameMomentAs(fechaFin)) {
      if (diasHabiles.contains(fechaActual.weekday)) {
        String dia = fechaActual.day.toString().padLeft(2, '0');
        String mes = fechaActual.month.toString().padLeft(2, '0');
        String anio = fechaActual.year.toString();

        listaFechas.add("$dia/$mes/$anio");

        // Repetir días martes, miércoles, jueves y viernes
        if (fechaActual.weekday >= 2 && fechaActual.weekday <= 5) {
          for (int i = 0; i < 2; i++) {
            listaFechas.add("$dia/$mes/$anio");
          }
        }
      }
      // Avanzar al siguiente día
      fechaActual = fechaActual.add(const Duration(days: 1));
    }

    return listaFechas;
  }
}
