class UsuarioModels {
  final int id;
  final String usuario;
  final String fullname;
  final String userUid;
  final String sexo;
  final int clasesDisponibles;
  final int theme;

  UsuarioModels({
    required this.id,
    required this.usuario,
    required this.fullname,
    required this.userUid,
    required this.sexo,
    required this.clasesDisponibles,
    required this.theme,
  });

  // Función para convertir el mapa a un objeto UsuarioModels
  factory UsuarioModels.fromMap(Map<String, dynamic> map) {
    return UsuarioModels(
      id: map['id'],
      usuario: map['usuario'],
      fullname: map['fullname'],
      userUid: map['user_uid'],
      sexo: map['sexo'],
      clasesDisponibles: map['clases_disponibles'],
      theme: map['theme'],
    );
  }
}
