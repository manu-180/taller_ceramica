import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/is_admin.dart';
import 'package:taller_ceramica/supabase/is_subscripto.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';

class SubscriptionVerifier {
  static Future<void> verificarAdminYSuscripcion(BuildContext context) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    if (usuarioActivo == null) {
      return;
    }

    if (usuarioActivo.id == '939d2e1a-13b3-4af0-be54-1a0205581f3b') {
      return;
    }

    final taller = await ObtenerTaller().retornarTaller(usuarioActivo.id);
    final isAdmin = await IsAdmin().admin();
    final isSubscribed = await IsSubscripto().subscripto();
    print("¿El usuario activo está suscripto? : $isSubscribed");

    if (isAdmin && !isSubscribed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false, // Evitar que se cierre al retroceder
              child: AlertDialog(
                title: const Text('El periodo de prueba ha concluido'),
                content: const Text(
                  'Si quieres seguir usando las funcionalidades del programa debes suscribirte.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      context.push("/home/$taller");
                    },
                    child: const Text('Entiendo'),
                  ),
                  FilledButton(
                    onPressed: () {
                      context.push("/subscription");
                    },
                    child: const Text('Suscribirse'),
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }
}
