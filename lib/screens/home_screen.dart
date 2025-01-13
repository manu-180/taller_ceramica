import 'package:flutter/material.dart';
import 'package:taller_ceramica/l10n/app_localizations.dart';
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

    // Accede a las traducciones
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: ResponsiveAppBar(isTablet: size.width > 600),
      body: FutureBuilder<bool>(
        future: IsMujer().mujer(fullName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(size.width * 0.04, size.height * 0.04, size.width * 0.04, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.86,
                        height: size.height * 0.042,
                        brillo: Color(0xFFF5F5F5),
                      ),
                      SizedBox(height: size.height * 0.015),
                      ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.67,
                        height: size.height * 0.042,
                        brillo: Color(0xFFF5F5F5),
                      ),
                      SizedBox(height: size.height * 0.015),
                      ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.3,
                        height: size.height * 0.042,
                        brillo: Color(0xFFF5F5F5),
                      ),
                      SizedBox(height: size.height * 0.034),
                      ShimmerLoading(
                        color: color.primary.withAlpha(40),
                        width: size.width,
                        height: size.height * 0.15,
                        brillo: Color(0xFFF5F5F5),
                      ),
                      SizedBox(height: size.height * 0.023),
                      ShimmerLoading(
                        color: Color(0xFFE0E0E0),
                        width: size.width,
                        height: size.height * 0.351,
                        brillo: Color(0xFFF5F5F5),
                      ),
                      SizedBox(height: size.height * 0.03),
                      ShimmerLoading(
                        color: color.primary.withAlpha(180),
                        width: size.width * 0.6,
                        height: size.height * 0.04,
                        brillo: Color(0xFFF5F5F5),
                      ),
                      SizedBox(height: size.height * 0.019),
                      ShimmerLoading(
                        color: color.primary.withAlpha(40),
                        width: size.width,
                        height: size.height * 0.1,
                        brillo: Color(0xFFF5F5F5),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(localizations.translate('errorLoadingData')),
            );
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
                            ? localizations.translate('welcomeFemale').replaceAll('\$taller', taller ?? '')
                            : localizations.translate('welcomeMale').replaceAll('\$taller', taller ?? ''),
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      BoxText(
                        text: user == null
                            ? localizations.translate('helloAnonymous')
                            : isMujer
                                ? localizations.translate('helloFemale').replaceAll('\$firstName', firstName)
                                : localizations.translate('helloMale').replaceAll('\$firstName', firstName),
                      ),
                      const SizedBox(height: 20),
                      _buildLoadingImage(
                        imagePath: 'assets/images/ceramicamujer.gif',
                        height: 300,
                        width: size.width * 0.9,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localizations.translate('whatWeDo'),
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
                          localizations.translate('workshopDescription'),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLoadingImage(
                        imagePath: 'assets/images/ceramicagif.gif',
                        height: 300,
                        width: size.width * 0.9,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          localizations.translate('workshopClasses'),
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
                brillo: Color(0xFFF5F5F5),
              ),
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
