import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class ModificarLugarDisponibleManu {
  Future<bool> agregarLugarDisponibleManu(int id) async {
    final data = await ObtenerTotalInfoManu().obtenerClaseManu();

    for (final clase in data) {
      if (clase.id == id) {
        var lugarDisponibleActualmente = clase.lugaresDisponibles;
        lugarDisponibleActualmente += 1;
        await supabase
            .from('clasesmanu')
            .update({'lugar_disponible': lugarDisponibleActualmente}).eq(
                'id', clase.id);
      }
    }

    return true;
  }

  Future<bool> removerLugarDisponibleManu(int id) async {
    final data = await ObtenerTotalInfoManu().obtenerClaseManu();

    for (final clase in data) {
      if (clase.id == id) {
        var lugarDisponibleActualmente = clase.lugaresDisponibles;
        lugarDisponibleActualmente -= 1;
        await supabase
            .from('clasesmanu')
            .update({'lugar_disponible': lugarDisponibleActualmente}).eq(
                'id', clase.id);
      }
    }

    return true;
  }
}
