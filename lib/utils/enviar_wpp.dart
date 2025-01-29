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

    const fromWhatsappNumber = 'whatsapp:+5491125303794';

      await http.post(
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
  "1": parameters.isNotEmpty ? parameters[0] : "",
  "2": parameters.length > 1 ? parameters[1] : "",
  "3": parameters.length > 2 ? parameters[2] : "",
  "4": parameters.length > 3 ? parameters[3] : "",
  "5": parameters.length > 4 ? parameters[4] : "",
}),
        },
      );

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
}
