import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EliminarDeBD {
  Future<void> deleteCurrentUser(userUid) async {
    await dotenv.load(fileName: ".env");

    final supabase = SupabaseClient(
      dotenv.env['SUPABASE_URL'] ?? '',
      dotenv.env['SERVICE_ROLE_KEY'] ?? '',
    );

    // Obtén el usuario autenticado actual

    if (userUid == null) {
      throw Exception('No hay ningún usuario autenticado.');
    }

    // Elimina el usuario usando la API de administración
    await supabase.auth.admin.deleteUser(userUid);
  }
}
