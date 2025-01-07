import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/utils/internet.dart'; // Importa la clase para verificar conexión

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
    // Verifica la conexión a Internet antes de proceder
    if (!await Internet().hayConexionInternet()) {
      print("No hay conexión a Internet. No se puede verificar el estado de la suscripción.");
      return;
    }

    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    if (usuarioActivo == null) return;

    await _inAppPurchase.restorePurchases();
    final List<PurchaseDetails> restoredPurchases = _purchases
        .where((purchase) => purchase.status == PurchaseStatus.restored)
        .toList();

    bool isSubscribed = restoredPurchases.any((purchase) {
      return (purchase.productID == 'monthlysubscription' ||
              purchase.productID == 'annualsubscription' ||
              purchase.productID == 'cero' ||
              purchase.productID == 'prueba') &&
          purchase.status == PurchaseStatus.purchased;
    });

    await Supabase.instance.client
        .from('subscriptions')
        .update({'is_active': isSubscribed}).eq('user_id', usuarioActivo.id);

    print('Estado de la suscripción actualizado: $isSubscribed');
  }

  Future<void> checkAndUpdateSubscription() async {
    // Verifica la conexión a Internet antes de proceder
    if (!await Internet().hayConexionInternet()) {
      print("No hay conexión a Internet. No se puede verificar y actualizar la suscripción.");
      return;
    }

    await _inAppPurchase.restorePurchases();
    final List<PurchaseDetails> restoredPurchases = _purchases
        .where((purchase) => purchase.status == PurchaseStatus.restored)
        .toList();

    bool isSubscribed = false;
    for (var purchase in restoredPurchases) {
      if (purchase.productID == 'monthlysubscription' ||
          purchase.productID == 'annualsubscription' ||
          purchase.productID == 'cero' ||
          purchase.productID == 'prueba') {
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

      print('Estado de la suscripción actualizado: $isSubscribed');
    }
  }

  /// Escucha las actualizaciones de compras
  void listenToPurchaseUpdates() {
    _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (var purchase in purchaseDetailsList) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            if (!_purchases.any((p) => p.productID == purchase.productID)) {
              _purchases.add(purchase);
            }
          } else if (purchase.status == PurchaseStatus.error) {
            print("Error en la compra: ${purchase.error?.message}");
          }
        }
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
              purchase.productID == "annualsubscription") &&
          purchase.status == PurchaseStatus.purchased) {
        return true;
      }
    }
    return false;
  }

  /// Consulta los detalles de productos configurados
  Future<void> fetchProductDetails() async {
    const Set<String> productIds = {
      "monthlysubscription",
      "annualsubscription"
    };

    // Verifica la conexión a Internet antes de proceder
    if (!await Internet().hayConexionInternet()) {
      print("No hay conexión a Internet. No se pueden obtener los detalles de productos.");
      return;
    }

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
    // Verifica la conexión a Internet antes de proceder
    if (!await Internet().hayConexionInternet()) {
      print("No hay conexión a Internet. No se pueden restaurar las compras.");
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      print("Se ha enviado la solicitud para restaurar las compras.");
    } catch (e) {
      print("Error al restaurar las compras: $e");
    }
  }
}
