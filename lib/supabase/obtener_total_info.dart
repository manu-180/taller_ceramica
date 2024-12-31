import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/models/usuario_models.dart';

class ObtenerTotalInfo {
  final SupabaseClient supabase;
  final String clasesTable;
  final String usuariosTable;

  ObtenerTotalInfo({
    required this.supabase,
    required this.clasesTable,
    required this.usuariosTable,
  });

  Future<List<ClaseModels>> obtenerClases() async {
    try {
      final response = await supabase.from(clasesTable).select();

      return (response as List<dynamic>)
          .map((item) => ClaseModels.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener clases: $e');
      throw Exception('No se pudieron obtener las clases: $e');
    }
  }

  Future<List<UsuarioModels>> obtenerUsuarios() async {
    try {
      final response = await supabase.from(usuariosTable).select();

      return (response as List<dynamic>)
          .map((item) => UsuarioModels.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener usuarios: $e');
      throw Exception('No se pudieron obtener los usuarios: $e');
    }
  }
}
