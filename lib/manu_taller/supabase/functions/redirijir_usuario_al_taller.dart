import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class RedirijirUsuarioAlTaller {
  Future<void> redirigirUsuario(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception("No hay usuario activo");
    }

    final usuariosIvanna = await ObtenerTotalInfo().obtenerInfoUsuarios();

    // Busca si el usuario está en la lista de Ivanna
    for (var usuario in usuariosIvanna) {
      if (usuario.userUid == user.id) {
        if (context.mounted) {
          context.go('/homeivanna');
        }
        return;
      }
    }

    // Si no se encontró, busca en la lista de Manu
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
  }
}
