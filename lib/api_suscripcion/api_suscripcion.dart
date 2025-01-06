import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiSuscripcion {
  Future<void> verificarSuscripcion(String purchaseToken, String subscriptionId) async {
    try {
      // Obtén el directorio actual donde se ejecuta el código
      final currentDir = Directory.current.path;

      // Construye la ruta al archivo JSON dinámicamente
      final serviceAccountKeyFile = dotenv.env['SERVICE_ACCOUNT_KEY']!;


      // Verifica que el archivo existe antes de intentar leerlo
      final file = File(serviceAccountKeyFile);
      if (!file.existsSync()) {
        throw Exception("El archivo de clave no existe en: $serviceAccountKeyFile");
      }

      // Lee la clave JSON
      final serviceAccountKey = await file.readAsString();
      final jsonKey = ServiceAccountCredentials.fromJson(serviceAccountKey);

      // Define los alcances necesarios para la API
      const scopes = ['https://www.googleapis.com/auth/androidpublisher'];

      // Autenticación
      final client = await clientViaServiceAccount(jsonKey, scopes);

      // Parámetros para la solicitud
      const packageName = 'com.manuelnavarro.tallerdeceramica'; // Reemplaza con tu package name real

      // Construye la URL de la API
      final url =
          'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$packageName/purchases/subscriptions/$subscriptionId/tokens/$purchaseToken';

      // Realiza la solicitud HTTP
      final response = await client.get(Uri.parse(url));

      // Maneja la respuesta
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Respuesta de la API: $data');
      } else {
        print('Error al verificar la suscripción: ${response.statusCode} - ${response.body}');
      }

      // Cierra el cliente
      client.close();
    } catch (e) {
      print('ERROR al cargar el archivo o realizar la solicitud: $e');
    }
  }
}
