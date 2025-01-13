import 'package:flutter/material.dart';
import 'package:taller_ceramica/widgets/box_text.dart';
import 'package:taller_ceramica/supabase/obtener_datos/is_mujer.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/widgets/shimmer_loader.dart';

class HomeScreen extends StatelessWidget {
  final String? taller;

  const HomeScreen({super.key, this.taller});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final themeColor = Theme.of(context).primaryColor;
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['fullname'] ?? '';
    final firstName = fullName.split(' ').first;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: ResponsiveAppBar(isTablet: size.width > 600),
      body: FutureBuilder<bool>(
        future: IsMujer().mujer(fullName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(child: Padding(
              padding: EdgeInsets.fromLTRB(size.width * 0.04, size.height * 0.04, size.width * 0.04, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.86,
                        height: size.height * 0.042,
                        brillo: Color(0xFFF5F5F5)),
                        SizedBox(height: size.height *0.015,),
                        ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.67 ,
                        height: size.height * 0.042,
                        brillo: Color(0xFFF5F5F5)),
                        SizedBox(height: size.height *0.015,),
                        ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.3 ,
                        height: size.height * 0.042,
                        brillo: Color(0xFFF5F5F5)),
                    SizedBox(height: size.height *0.034,),
                    ShimmerLoading(
                        color: color.primary.withAlpha(40),
                        width: size.width ,
                        height: size.height * 0.15,
                        brillo: Color(0xFFF5F5F5)),
                    SizedBox(height: size.height *0.023,),
                    ShimmerLoading(
                        color: Color(0xFFE0E0E0),
                        width: size.width ,
                        height: size.height * 0.351,
                        brillo: Color(0xFFF5F5F5)),
                    SizedBox(height: size.height *0.03,),
                    ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.6,
                        height: size.height * 0.04,
                        brillo: Color(0xFFF5F5F5)),
                    SizedBox(height: size.height *0.019,),
                    ShimmerLoading(
                        color: color.primary.withAlpha(40),
                        width: size.width ,
                        height: size.height * 0.1,
                        brillo: Color(0xFFF5F5F5)),
                    
                    
                    
                  ],
                ),
              ),
            ));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          } else {
            final isMujer = snapshot.data ?? false;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        isMujer
                            ? '¡Bienvenida al taller de $taller!'
                            : '¡Bienvenido al taller de $taller!',
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
                          imagePath: 'assets/images/ceramicamujer.gif',
                          height: 300,
                          width: size.width * 0.9),
                      const SizedBox(height: 20),
                      Text(
                        '¿Qué hacemos?',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
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
                          imagePath: 'assets/images/ceramicagif.gif',
                          height: 300,
                          width: size.width * 0.9),
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
    required double width,
  }) {
    return FutureBuilder(
      future: _loadAssetImage(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: Center(
              child: ShimmerLoading(
                  color: Color(0xFFE0E0E0),
                  width: double.infinity,
                  height: height,
                  brillo: Color(0xFFF5F5F5)),
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
