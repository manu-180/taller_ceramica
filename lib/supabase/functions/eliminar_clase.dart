import 'package:taller_ceramica/main.dart';

class EliminarClase {
  Future<void> eliminarClase(int id) async {
    await supabase.from('respaldo').delete().eq('id', id);
  }
}