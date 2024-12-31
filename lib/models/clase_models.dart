class ClaseModels {
  final int id;
  final String semana; 
  final String dia; 
  final String fecha; 
  final String hora; 
  final List<String> mails; 
  int lugaresDisponibles;

  ClaseModels({
    required this.id,
    required this.semana,
    required this.dia,
    required this.fecha,
    required this.hora,
    required this.mails,
    required this.lugaresDisponibles,
  });

  @override
  String toString() {
    return 'ClaseModels(id: $id, semana: $semana, lugaresDisponibles: $lugaresDisponibles, dia: $dia, fecha: $fecha, hora: $hora, mails: $mails)';
  }

  // Método para actualizar el estado de la clase
  void actualizarLugaresDisponibles(int nuevosLugares) {
    lugaresDisponibles = nuevosLugares;
  }

  // Método para crear una instancia desde un Map (útil para bases de datos)
  factory ClaseModels.fromMap(Map<String, dynamic> map) {
    return ClaseModels(
      id: map['id'],
      semana: map['semana'],
      dia: map['dia'],
      fecha: map['fecha'],
      hora: map['hora'],
      mails: List<String>.from(map['mails'] ?? []),
      lugaresDisponibles: map['lugar_disponible'],
    );
  }

  // Método para convertir una instancia a Map (útil para bases de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semana': semana,
      'dia': dia,
      'fecha': fecha,
      'hora': hora,
      'mails': mails,
      'lugar_disponible': lugaresDisponibles,
    };
  }

  // Método copyWith para copiar y modificar instancias
  ClaseModels copyWith({
    int? id,
    String? semana,
    String? dia,
    String? fecha,
    String? hora,
    List<String>? mails,
    int? lugaresDisponibles,
  }) {
    return ClaseModels(
      id: id ?? this.id,
      semana: semana ?? this.semana,
      dia: dia ?? this.dia,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      mails: mails ?? List.from(this.mails),
      lugaresDisponibles: lugaresDisponibles ?? this.lugaresDisponibles,
    );
  }
}
