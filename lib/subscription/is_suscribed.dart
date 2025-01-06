import 'package:in_app_purchase/in_app_purchase.dart';

class IsSuscribed {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  List<PurchaseDetails> _purchases = [];

  /// Escucha las actualizaciones de compras
  void listenToPurchaseUpdates() {
  _inAppPurchase.purchaseStream.listen(
    (List<PurchaseDetails> purchaseDetailsList) {
      print("Se recibió una actualización de compras: $purchaseDetailsList");

      for (var purchase in purchaseDetailsList) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          print("Compra válida: ${purchase.productID}");
          if (!_purchases.contains(purchase)) {
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
            purchase.productID == "annualsubscription" ||
            purchase.productID == "cero") &&
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
  const Set<String> productIds = {"monthlysubscription", "annualsubscription", "cero"};
  
  final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

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
}


Future<void> restorePurchases() async {
  try {
    await _inAppPurchase.restorePurchases();
    print("Se ha enviado la solicitud para restaurar las compras.");
  } catch (e) {
    print("Error al restaurar las compras: $e");
  }
}




}
