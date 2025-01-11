import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/models/subscription_models.dart';
import 'package:taller_ceramica/models/usuario_models.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/utils/internet.dart'; // Importa la clase Internet con hayConexionInternet

class ObtenerTotalInfo {
  final SupabaseClient supabase;
  final String clasesTable;

  ObtenerTotalInfo({
    required this.supabase,
  });

  Future<List<ClaseModels>> obtenerClases() async {
    

    try {
      if (!await Internet().hayConexionInternet()) {
      throw Exception('No hay conexión a Internet.');
    } 
      final usuarioActivo = Supabase.instance.client.auth.currentUser;
      final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
      final response = await supabase.from(taller).select();

      return (response as List<dynamic>)
          .map((item) => ClaseModels.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('No se pudieron obtener las clases: $e');
    }
  }

  Future<List<UsuarioModels>> obtenerUsuarios() async {
    

    try {
      if (!await Internet().hayConexionInternet()) {
      throw Exception('No hay conexión a Internet.');
    }
      final response = await supabase.from("usuarios").select();

      return (response as List<dynamic>)
          .map((item) => UsuarioModels.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('No se pudieron obtener los usuarios: $e');
    }
  }

  Future<List<SubscriptionModel>> obtenerSubscriptos() async {
    if (!await Internet().hayConexionInternet()) {
      throw Exception('No hay conexión a Internet.');
    }

    try {
      final response = await supabase.from("subscriptions").select();

      return (response as List<dynamic>)
          .map((item) => SubscriptionModel.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('No se pudieron obtener los usuarios: $e');
    }
  }
}
