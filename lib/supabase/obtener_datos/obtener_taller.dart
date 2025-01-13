import 'package:taller_ceramica/main.dart';

class ObtenerTaller {
  Future<String> retornarTaller(String userUid) async {
    final data = await supabase
        .from("usuarios")
        .select("taller")
        .eq("user_uid", userUid)
        .single();

    return data["taller"];
  }
}
