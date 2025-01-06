import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response = await supabaseClient.from('subscriptions').insert({
        'user_id': userId,
        'product_id': productId,
        'purchase_token': purchaseToken,
        'start_date': startDate.toIso8601String(),
        'is_active': isActive,
      });

      if (response.error != null) {
        throw Exception(
            'Error al insertar la suscripción: ${response.error!.message}');
      } else {
        print('Suscripción insertada exitosamente: $response');
      }
    } catch (e) {
      print('Error al insertar la suscripción: $e');
    }
  }
}
