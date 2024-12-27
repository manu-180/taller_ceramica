import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/ivanna_taller/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/models/usuario_models.dart'; // Asegúrate de tener esta ruta correcta.

class ObtenerTotalInfo {
  Future<List<ClaseModels>> obtenerInfo() async {
    final data = await supabase.from('total').select();
    return List<ClaseModels>.from(data.map((map) => ClaseModels.fromMap(map)));
  }

  Future<List<UsuarioModels>> obtenerInfoUsuarios() async {
    final data = await supabase.from('usuarios').select();
    return List<UsuarioModels>.from(
        data.map((map) => UsuarioModels.fromMap(map)));
  }
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
