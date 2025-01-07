import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartelSuscripcion extends StatelessWidget {
  final String? taller;

  const CartelSuscripcion({super.key, this.taller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Periodo de prueba finalizado",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
          "El periodo de prueba gratuito ha concluido, para continuar debes suscribirte."),
      actions: [
        ElevatedButton(
          onPressed: () {
            context.go("/home/${taller ?? ''}");
          },
          child: const Text("Entiendo"),
        ),
        FilledButton(
          onPressed: () {
            context.go("/subscription");
          },
          child: const Text("Suscribirse"),
        ),
      ],
    );
  }
}

void showCartelSuscripcionIfNeeded(BuildContext context, String userId,
    {String? taller, required bool isSubscribed}) {
  if (!isSubscribed && userId != "939d2e1a-13b3-4af0-be54-1a0205581f3b") {
    showDialog(
      context: context,
      builder: (_) => CartelSuscripcion(taller: taller),
    );
  }
}
