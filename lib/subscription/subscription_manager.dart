import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class SubscriptionManager {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  final List<PurchaseDetails> _purchases = [];

  SubscriptionManager() {
    _startPeriodicValidation();
  }

  void _startPeriodicValidation() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await verificarEstadoSuscripcion();
    });
  }

  Future<void> verificarEstadoSuscripcion() async {
  final usuarioActivo = Supabase.instance.client.auth.currentUser;
  if (usuarioActivo == null) return;

  await InAppPurchase.instance.restorePurchases();
  final List<PurchaseDetails> restoredPurchases = _purchases
      .where((purchase) => purchase.status == PurchaseStatus.restored)
      .toList();

  bool isSubscribed = restoredPurchases.any((purchase) {
    return (purchase.productID == 'monthlysubscription' || purchase.productID == 'annualsubscription') &&
           purchase.status == PurchaseStatus.purchased;
  });

  await Supabase.instance.client
      .from('subscriptions')
      .update({'is_active': isSubscribed})
      .eq('user_id', usuarioActivo.id);

  print('Estado de la suscripción actualizado: $isSubscribed');
}


  Future<void> checkAndUpdateSubscription() async {
    await _inAppPurchase.restorePurchases();
    final List<PurchaseDetails> restoredPurchases = _purchases
        .where((purchase) => purchase.status == PurchaseStatus.restored)
        .toList();

    bool isSubscribed = false;
    for (var purchase in restoredPurchases) {
      if (purchase.productID == 'monthlysubscription' ||
          purchase.productID == 'annualsubscription') {
        if (purchase.status == PurchaseStatus.purchased) {
          isSubscribed = true;
          break;
        }
      }
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      await supabase
          .from('subscriptions')
          .update({'is_active': isSubscribed}).eq('user_id', currentUser.id);
    }
  }

  /// Escucha las actualizaciones de compras
  void listenToPurchaseUpdates() {
    _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        print("Se recibió una actualización de compras: $purchaseDetailsList");

        for (var purchase in purchaseDetailsList) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            print("Compra válida: ${purchase.productID}");
            if (!_purchases.any((p) => p.productID == purchase.productID)) {
              _purchases.add(purchase);
            }
          } else if (purchase.status == PurchaseStatus.error) {
            print("Error en la compra: ${purchase.error?.message}");
          }
        }

        print("Compras actualizadas: $_purchases");
      },
      onError: (error) {
        print("Error al escuchar el flujo de compras: $error");
      },
    );
  }

  /// Verifica manualmente si el usuario está suscripto
  bool isUserSubscribed() {
    for (var purchase in _purchases) {
      if ((purchase.productID == "monthlysubscription" ||
              purchase.productID == "annualsubscription" ) &&
          purchase.status == PurchaseStatus.purchased) {
        print("Usuario suscripto al producto: ${purchase.productID}");
        return true;
      }
    }
    print("Usuario no está suscripto.");
    return false;
  }

  /// Consulta los detalles de productos configurados
  Future<void> fetchProductDetails() async {
    const Set<String> productIds = {
      "monthlysubscription",
      "annualsubscription"
    };

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        print("Error al consultar los productos: ${response.error}");
        return;
      }

      if (response.productDetails.isEmpty) {
        print("No se encontraron productos configurados.");
        return;
      }

      for (var product in response.productDetails) {
        print("Producto disponible: ${product.title} - ${product.id}");
      }
    } catch (e) {
      print("Error al obtener detalles de productos: $e");
    }
  }

  /// Restaura las compras
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      print("Se ha enviado la solicitud para restaurar las compras.");
    } catch (e) {
      print("Error al restaurar las compras: $e");
    }
  }
}
