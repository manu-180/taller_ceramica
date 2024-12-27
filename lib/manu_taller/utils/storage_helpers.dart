import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class StorageHelper {
  static Future<SharedPreferences> getPreferences() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> clearCache() async {
    final prefs = await getPreferences();
    await prefs.clear();
  }

  // Guardar sesión
  static Future<void> saveSession(Session session) async {
    final prefs = await getPreferences();
    final sessionData = session.toJson();
    await prefs.setString('session', jsonEncode(sessionData));
  }

  // Obtener sesión
  static Future<Session?> getSession() async {
    final prefs = await getPreferences();
    final sessionString = prefs.getString('session');
    if (sessionString != null) {
      final sessionMap = jsonDecode(sessionString) as Map<String, dynamic>;
      return Session.fromJson(sessionMap);
    }
    return null;
  }

  // Eliminar sesión
  static Future<void> deleteSession() async {
    final prefs = await getPreferences();
    await prefs.remove('session');
  }
}
