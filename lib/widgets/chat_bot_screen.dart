import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  bool _showChatBot = false; // Controla si el chat está visible

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatBot Integration"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Center(
            child: Text(
              "Tu contenido principal aquí",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 80, // Ajustar para colocar encima del ícono de WhatsApp
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showChatBot = !_showChatBot;
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(
                      Icons.android, // Ícono del bot
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _showChatBot ? size.width * 0.8 : 0,
                  height: _showChatBot ? size.height * 0.5 : 0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                                  // Añade más interacciones aquí
                                ],
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Escribe tu mensaje...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onSubmitted: (text) {
                                // Maneja el envío del mensaje
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                // Acción del botón de WhatsApp
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
