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

  // Obtiene las clases desde la tabla que se especificó (clasesTable)
  Future<List<ClaseModels>> obtenerClases() async {
    final response = await supabase.from(clasesTable).select();

    return response.map((item) => ClaseModels.fromMap(item)).toList();
  }

  // Obtiene los usuarios desde la tabla que se especificó (usuariosTable)
  Future<List<UsuarioModels>> obtenerUsuarios() async {
    final response = await supabase.from(usuariosTable).select();
    return response.map((item) => UsuarioModels.fromMap(item)).toList();
  }
}
