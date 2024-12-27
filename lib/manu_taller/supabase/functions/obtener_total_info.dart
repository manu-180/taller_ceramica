import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/models/usuario_models.dart';

class ObtenerTotalInfoManu {
  Future<List<ClaseModels>> obtenerClaseManu() async {
    final data = await supabase.from('clasesmanu').select();
    return List<ClaseModels>.from(data.map((map) => ClaseModels.fromMap(map)));
  }

  Future<List<UsuarioModels>> obtenerUsuariosManu() async {
    final data = await supabase.from('usuariosmanu').select();
    return List<UsuarioModels>.from(
        data.map((map) => UsuarioModels.fromMap(map)));
  }
}
