import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class Contactanos extends StatefulWidget {
  const Contactanos({super.key});

  @override
  State<Contactanos> createState() => _ContactanosState();
}

class _ContactanosState extends State<Contactanos> {
  bool _isExpanded = false;

  void _launchWhatsApp() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+5491134272488',
      text: '¡Hola! Me gustaría más información.',
    );

    if (await canLaunchUrl(Uri.parse('$link'))) {
      await launchUrl(Uri.parse('$link'), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir WhatsApp. Verifica que está instalado.');
    }
  }

  void _launchEmail() async {
    final String email = 'reycamila04@gmail.com';
    final String subject = Uri.encodeComponent('Consulta');
    final String body = Uri.encodeComponent('Hola, quisiera más información.');

    final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir el cliente de correo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end, 
              children: [
                if (_isExpanded)
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 350),
                    tween: Tween<double>(begin: 12, end: 0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) => Transform.translate(
                      offset: Offset(0, value),
                      child: FloatingActionButton(
                        onPressed: _launchWhatsApp,
                        backgroundColor: Colors.green,
                        heroTag: 'whatsapp',
                        child: const Icon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if (_isExpanded)
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 350),
                    tween: Tween<double>(begin: 12, end: 0), 
                    curve: Curves.easeOut,
                    builder: (context, value, child) => Transform.translate(
                      offset: Offset(0, value),
                      child: FloatingActionButton(
                        onPressed: _launchEmail,
                        backgroundColor: Colors.red,
                        heroTag: 'email',
                        child: const Icon(
                          FontAwesomeIcons.envelope,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                IntrinsicWidth(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Ajusta al tamaño del contenido
                      children: [
                        Icon(
                          _isExpanded ? Icons.close : Icons.contact_page_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 5), 
                        const Text("Contáctanos"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
