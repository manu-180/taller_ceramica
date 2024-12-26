import 'package:flutter/material.dart';

class PruebaAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  const PruebaAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.teal, // Cambia por tu color
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Margen interno horizontal
      height: preferredSize.height, // Asegura que respete la altura preferida
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Acción al presionar el título
              // print("Título presionado");
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taller de',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Cerámica',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: (){},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  // Define el tamaño del AppBar
  @override
  Size get preferredSize => const Size.fromHeight(80.0); // Ajusta la altura aquí
}
