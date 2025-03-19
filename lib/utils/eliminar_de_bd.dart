import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class EliminarDeBD {
  Future<void> deleteCurrentUser(String userUid) async {
    if (File('.env').existsSync()) {
      await dotenv.load(fileName: ".env");
    }

    final supabase = SupabaseClient(
      Platform.environment.containsKey('CI')
          ? String.fromEnvironment("SUPABASE_URL")
          : dotenv.env['SUPABASE_URL'] ?? '',
      Platform.environment.containsKey('CI')
          ? String.fromEnvironment("SERVICE_ROLE_KEY")
          : dotenv.env['SERVICE_ROLE_KEY'] ?? '',
    );

    await supabase.auth.admin.deleteUser(userUid);
  }
}
