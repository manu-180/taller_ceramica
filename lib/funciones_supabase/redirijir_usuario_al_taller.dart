import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';
import 'package:taller_ceramica/funciones_supabase/supabase_barril.dart';

class RedirigirUsuarioAlTaller {
  Future<void> redirigirUsuario(BuildContext context) async {

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("No hay usuario activo");
      }

      final taller  = await ObtenerTaller().retornarTaller(user.id);

      if (taller == "total") {
        if (context.mounted) context.go('/homeivanna');
      } else if (taller == "clasesmanu") {
        if (context.mounted) context.go('/homemanu');
      } else {
        throw Exception("Taller desconocido: $taller");
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al redirigir: $e")),
        );
      }
    }
  }
}
