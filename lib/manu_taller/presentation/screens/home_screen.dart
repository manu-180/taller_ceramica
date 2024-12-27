import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/manu_taller/presentation/functions_screens/box_text.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';

class HomeScreenManu extends StatelessWidget {
  const HomeScreenManu({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final themeColor = Theme.of(context).primaryColor;
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['fullname'] ?? '';
    final firstName = fullName.split(' ').first;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: ResponsiveAppBarManu( isTablet: size.width > 600),
      body: FutureBuilder<bool>(
        future: IsMujer().mujer(fullName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          } else {
            final isMujer = snapshot.data ?? false;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth:  600 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        isMujer
                            ? '¡Bienvenida Manu!'
                            : '¡Bienvenido Manu!',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      BoxText(
                        text: user == null
                            ? "¡Hola y bienvenido/a a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!"
                            : isMujer
                                ? "¡Hola $firstName y bienvenida a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!"
                                : "¡Hola $firstName y bienvenido a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!",
                      ),
                      const SizedBox(height: 20),
                      _buildLoadingImage(
                        imagePath: 'assets/images/creando.png',
                        height: 500,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¿Qué hacemos?',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Aquí, en nuestro taller, creamos desde pequeñas piezas decorativas hasta grandes obras de arte, todas con un toque especial y un diseño único.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLoadingImage(
                        imagePath: 'assets/images/bici.webp',
                        height: 300,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Ofrecemos clases para todos los niveles, desde principiantes hasta expertos, donde podrás aprender las técnicas de modelado, esmaltado y cocción, explorando tus propias ideas y estilo.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingImage({
    required String imagePath,
    required double height,
  }) {
    return FutureBuilder(
      future: _loadAssetImage(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: height,
            child: const Center(
              child: Text("Error al cargar la imagen"),
            ),
          );
        } else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
      },
    );
  }

  Future<void> _loadAssetImage(String assetPath) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
