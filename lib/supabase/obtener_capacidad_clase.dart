import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class ObtenerCapacidadClase {
  Future<int> capacidadClase(int claseId) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    if (usuarioActivo == null) {
      print("Usuario no autenticado");
      return 0;
    }

    final taller = await ObtenerTaller().retornarTaller(usuarioActivo.id);
    final clases = await ObtenerTotalInfo(
      supabase: supabase,
      clasesTable: taller,
      usuariosTable: "usuarios",
    ).obtenerClases();

    for (final clase in clases) {
      if (clase.id == claseId) {
        print("Capacidad de la clase (${clase.id}): ${clase.capacidad}");
        return clase.capacidad;
      }
    }
    print("Clase no encontrada para el ID: $claseId");
    return 0;
  }

  Future<List<Map<String, dynamic>>> cargarTodasLasCapacidades() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
  final response = await Supabase.instance.client
      .from(taller)
      .select('id, capacidad');
      
  return (response as List).map((e) => e as Map<String, dynamic>).toList();
}

}

