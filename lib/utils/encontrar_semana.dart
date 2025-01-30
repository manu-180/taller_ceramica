class EncontrarSemana {
  String obtenerSemana(String fecha) {
    // Convertir la fecha de String a DateTime
    List<String> partes = fecha.split('/');
    DateTime fechaConvertida = DateTime(
      int.parse(partes[2]), // Año
      int.parse(partes[1]), // Mes
      int.parse(partes[0]), // Día
    );

    // Obtener el primer día del mes
    DateTime primerDiaDelMes = DateTime(fechaConvertida.year, fechaConvertida.month, 1);

    // Si la fecha está dentro de la primera semana (del 1 al domingo)
    DateTime finPrimeraSemana = primerDiaDelMes.add(Duration(days: 7 - primerDiaDelMes.weekday));
    if (fechaConvertida.isBefore(finPrimeraSemana)) {
      return "semana1";
    }

    // Calcular las semanas restantes
    int diasDesdeInicio = fechaConvertida.difference(primerDiaDelMes).inDays;
    int numeroSemana = ((diasDesdeInicio + primerDiaDelMes.weekday - 1) / 7).floor() + 1;

    return "semana$numeroSemana";
  }
}
