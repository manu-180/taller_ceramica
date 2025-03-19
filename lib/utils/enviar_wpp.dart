import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class EnviarWpp {
  void sendWhatsAppMessage(String contentSid, String num, List<String> parameters) async {
    try {
      if (File('.env').existsSync()) {
        await dotenv.load(fileName: ".env");
      }

      var apiKeySid = Platform.environment.containsKey('CI')
          ? String.fromEnvironment("API_KEY_SID")
          : dotenv.env['API_KEY_SID'] ?? '';

      var apiKeySecret = Platform.environment.containsKey('CI')
          ? String.fromEnvironment("API_KEY_SECRET")
          : dotenv.env['API_KEY_SECRET'] ?? '';

      var accountSid = Platform.environment.containsKey('CI')
          ? String.fromEnvironment("ACCOUNT_SID")
          : dotenv.env['ACCOUNT_SID'] ?? '';

      print("API_KEY_SID: $apiKeySid");
      print("API_KEY_SECRET: $apiKeySecret");
      print("ACCOUNT_SID: $accountSid");

      final uri = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
      print("URI creada: $uri");

      const fromWhatsappNumber = 'whatsapp:+5491125303794';
      print("Número de WhatsApp origen: $fromWhatsappNumber");

      var body = {
        'From': fromWhatsappNumber,
        'To': num,
        'ContentSid': contentSid,
        'ContentVariables': jsonEncode({
          "1": parameters.isNotEmpty ? parameters[0] : "",
          "2": parameters.length > 1 ? parameters[1] : "",
          "3": parameters.length > 2 ? parameters[2] : "",
          "4": parameters.length > 3 ? parameters[3] : "",
          "5": parameters.length > 4 ? parameters[4] : "",
        }),
      };

      print("Cuerpo de la solicitud: $body");

      var response = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKeySid:$apiKeySecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print("Estado de la respuesta: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Mensaje enviado correctamente.");
      } else {
        print("Error al enviar el mensaje. Código de error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}


  // void enviarMensajesViejo(String text, String num) async {
  //   await dotenv.load(fileName: ".env");

  //   var apiKeySid = dotenv.env['API_KEY_SID'] ?? '';
  //   var accountSid = dotenv.env['ACCOUNT_SID'] ?? '';
  //   var apiKeySecret = dotenv.env['API_KEY_SECRET'] ?? '';

  //   final uri = Uri.parse(
  //       'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

  //   const fromWhatsappNumber = 'whatsapp:+14155238886';
  //   await http.post(
  //     uri,
  //     headers: {
  //       'Authorization':
  //           'Basic ${base64Encode(utf8.encode('$apiKeySid:$apiKeySecret'))}',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'From': fromWhatsappNumber,
  //       'To': num,
  //       'Body': text,
  //     },
  //   );
  // }

