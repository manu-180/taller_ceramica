import 'package:taller_ceramica/main.dart';

class EliminarClaseManu {
  Future<void> eliminarClaseManu(int id) async {
    await supabase.from('clasesmanu').delete().eq('id', id);
  }
}
