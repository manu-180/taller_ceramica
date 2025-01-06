import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

import 'package:taller_ceramica/api_suscripcion/api_suscripcion.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/subscription/subscription_manager.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/supabase/suscribir_usuario.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  Map<String, bool> _hovering = {};
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();

    SubscriptionManager().checkAndUpdateSubscription();

    _initializeStore();

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('Error en las compras: $error');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Función para limpiar el título
  String cleanTitle(String title) {
    return title.replaceAll(
        RegExp(r' *\(.*?\)'), ''); // Elimina texto entre paréntesis
  }

  Future<void> _initializeStore() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (isAvailable) {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(
        {"monthlysubscription", "annualsubscription"}.toSet(),
      );

      setState(() {
        _isAvailable = isAvailable;
        _products = response.productDetails;

        print(
            'Productos disponibles: ${_products.map((p) => p.title).toList()}');

        _products.sort((a, b) => a.price.compareTo(b.price));

        for (var product in _products) {
          _hovering[product.id] = false;
        }
      });
    }
  }

  void _subscribe(ProductDetails productDetails) {
    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      debugPrint('Intentando comprar: ${productDetails.id}');
      _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam, autoConsume: false);
    } catch (e) {
      debugPrint('Error al iniciar la compra: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la compra: $e')),
      );
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        debugPrint('Compra exitosa: ${purchase.productID}');

        final usuarioActivo = Supabase.instance.client.auth.currentUser;
        final purchaseToken = purchase.verificationData.serverVerificationData;
        final productId = purchase.productID;

        final DateTime startDate = DateTime.now();
        late DateTime endDate;

        final bool isActive = true;

        // Llama a la API para verificar la suscripción
        await ApiSuscripcion().verificarSuscripcion(purchaseToken, productId);

        // Inserta la suscripción en Supabase
        await SuscribirUsuario(supabaseClient: supabase).insertSubscription(
          userId: usuarioActivo!.id,
          productId: productId,
          purchaseToken: purchaseToken,
          startDate: startDate,
          isActive: isActive,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compra realizada: ${purchase.productID}')),
        );
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Error en la compra: ${purchase.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error en la compra: ${purchase.error?.message}')),
        );
      } else if (purchase.status == PurchaseStatus.restored) {
        debugPrint('Compra restaurada: ${purchase.productID}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compra restaurada: ${purchase.productID}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final double fontSizeTitle = size.width * 0.065; 
    final double fontSizeDescription = size.width * 0.04;
    final double fontSizePrice = size.width * 0.07; 

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suscripción",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
      ),
      body: _isAvailable
    ? _products.isEmpty
        ? const Center(child: Text("No hay productos disponibles."))
        : SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _products.map((product) {
                    return GestureDetector(
                      onTap: () => _subscribe(product),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical:250),
                        child: Container(
                          height: size.height * 0.28,
                          width: size.width * 0.8,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  cleanTitle(product.title),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeTitle,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: fontSizeDescription,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                product.price,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizePrice,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          )
    : const Center(
        child: Text("La tienda no está disponible."),
      ),

    );
  }
}
