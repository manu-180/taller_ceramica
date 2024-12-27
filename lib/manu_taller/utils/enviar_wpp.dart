import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EnviarWpp {
  void sendWhatsAppMessage(String text, String num) async {
    await dotenv.load(fileName: ".env");

    var apiKeySid = dotenv.env['API_KEY_SID'] ?? '';
    var apiKeySecret = dotenv.env['API_KEY_SECRET'] ?? '';
    var accountSid = dotenv.env['ACCOUNT_SID'] ?? '';

    final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

    const fromWhatsappNumber = 'whatsapp:+14155238886';

    await http.post(
      uri,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$apiKeySid:$apiKeySecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': fromWhatsappNumber,
        'To': num,
        'Body': text,
      },
    );
  }
}
