import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class Contactanos extends StatefulWidget {
  const Contactanos({super.key});

  @override
  State<Contactanos> createState() => _ContactanosState();
}

class _ContactanosState extends State<Contactanos> with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _showChatBot = false;

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
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                if (_isExpanded && !_showChatBot)
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
                if (_isExpanded && !_showChatBot)
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
                if (_isExpanded)
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 350),
                    tween: Tween<double>(begin: 12, end: 0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) => Transform.translate(
                      offset: Offset(0, value),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showChatBot = !_showChatBot;
                          });
                        },
                        child: Container(
                          width: size.width * 0.143,
                          height: size.height * 0.068,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.android,
                            color: Colors.white,
                            size: 33,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: _showChatBot ? size.width * 0.8 : 0,
                    height: _showChatBot ? size.height * 0.4 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _showChatBot
                        ? Column(
                            children: [
                              Text(
                                "ChatBot",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.black),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListView(
                                  children: const [
                                    Text(
                                      "Bot: ¿En qué puedo ayudarte hoy?",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Escribe tu mensaje...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onSubmitted: (text) {
                                  // Maneja el envío del mensaje
                                },
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
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
                      mainAxisSize: MainAxisSize.min,
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
