import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class SuscribirUsuario {
  final SupabaseClient supabaseClient;

  SuscribirUsuario({required this.supabaseClient});

  /// Función para insertar un nuevo registro en la tabla `subscriptions`
  Future<void> insertSubscription({
    required String userId,
    required String productId,
    required String purchaseToken,
    required DateTime startDate,
    required bool isActive,
  }) async {
    try {
    final taller = await ObtenerTaller().retornarTaller(userId);
      final subsriptores = await ObtenerTotalInfo(supabase: supabase, clasesTable: taller, usuariosTable: "usuarios").obtenerSubscriptos();

      for(final sub in subsriptores){
        if(sub.userId ==userId ){
          await supabase.from('subscriptions').update({
              'product_id': productId,
              'purchase_token': purchaseToken,
              'start_date': startDate.toIso8601String(),
              'is_active': isActive,
             }
             ).eq('id', sub.id);
             return;

        } else {
        await supabaseClient.from('subscriptions').insert({
        'user_id': userId,
        'product_id': productId,
        'purchase_token': purchaseToken,
        'start_date': startDate.toIso8601String(),
        'is_active': isActive,
      });
      return;
        }
      }
    } catch (e) {
      print('Error al insertar la suscripción: $e');
    }
  }
}
