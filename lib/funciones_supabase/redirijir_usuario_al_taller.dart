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

      final taller = await ObtenerTaller().retornarTaller(user.id);

      // Si tu ruta es "/home/:taller", simplemente hacemos:
      if (taller.isEmpty) {
        throw Exception("Taller desconocido (está vacío)");
      }

      if (context.mounted) {
        context.go('/home/$taller');
        // O .push() si necesitas empujar la ruta en lugar de reemplazarla
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
