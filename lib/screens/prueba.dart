import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/supabase/utiles/reset_clases.dart';
import 'package:taller_ceramica/utils/actualizar_fechas_database.dart';
import 'package:taller_ceramica/utils/encontrar_semana.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/l10n/app_localizations.dart'; // Importa tu clase de localización

class Prueba extends StatelessWidget {
  const Prueba({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _loadData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else {
          final data = snapshot.data as Map<String, dynamic>;
          final translatedText = data['translatedText'];
          final taller = data['taller'];

          return Scaffold(
            appBar: ResponsiveAppBar(isTablet: size.width > 600),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    translatedText, // Texto traducido dinámicamente
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // print(EncontrarSemana().obtenerSemana('08/01/2025'));
                ResetClases().reset();
                ActualizarFechasDatabase().actualizarClasesAlNuevoMes(taller, 2025);
              },
              child: const Icon(Icons.arrow_back),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _loadData(BuildContext context) async {
    final translatedText = AppLocalizations.of(context).translate('helloWorld');
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    return {'translatedText': translatedText, 'taller': taller};
  }
}
