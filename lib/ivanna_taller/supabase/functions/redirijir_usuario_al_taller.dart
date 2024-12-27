import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';

import '../../../manu_taller/supabase/supabase_barril.dart';

class RedirijirUsuarioAlTaller {
  Future<void> redirigirUsuario(BuildContext context) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("No hay usuario activo");
      }

      final usuariosIvanna = await ObtenerTotalInfo().obtenerInfoUsuarios();

      for (var usuario in usuariosIvanna) {
        if (usuario.userUid == user.id) {
          if (context.mounted) {
            context.go('/homeivanna');
          }
          return;
        }
      }

      final usuariosManu = await ObtenerTotalInfoManu().obtenerUsuariosManu();

      for (var usuario in usuariosManu) {
        if (usuario.userUid == user.id) {
          if (context.mounted) {
            context.go('/homemanu');
          }
          return;
        }
      }

      // Si no se encontró en ninguna lista, maneja el caso aquí
      throw Exception("Usuario no encontrado en ninguna lista");
    } catch (e) {
      // Manejo de errores
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al redirigir: $e")),
      );
    }
  }
}
