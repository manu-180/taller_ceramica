import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EnviarWpp {
  void sendWhatsAppMessage(String contentSid, String num, List<String> parameters) async {
    await dotenv.load(fileName: ".env");

    var apiKeySid = dotenv.env['API_KEY_SID'] ?? '';
    var apiKeySecret = dotenv.env['API_KEY_SECRET'] ?? '';
    var accountSid = dotenv.env['ACCOUNT_SID'] ?? '';

    final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

    const fromWhatsappNumber = 'whatsapp:+5491124914703'; 


    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKeySid:$apiKeySecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': fromWhatsappNumber,
          'To': num,
          'ContentSid': contentSid, // Identificador de la plantilla
          'ContentVariables': jsonEncode({
            "1": parameters[0], // Nombre del usuario
            "2": parameters[1], // Día de la clase
            "3": parameters[2], // Fecha de la clase
            "4": parameters[3], // Hora de la clase
            "5": parameters[4], // Mensaje adicional
          }),
        },
      );

      print("HTTP Status Code: ${response.statusCode}");
      print("HTTP Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("¡Mensaje enviado con éxito!");
      } else {
        print("Error al enviar el mensaje: ${response.body}");
      }
    } catch (e) {
      print("Error al enviar la solicitud HTTP: $e");
    }
  }
}
