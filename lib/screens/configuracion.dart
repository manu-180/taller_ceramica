// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mailto/mailto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/widgets/box_text.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/providers/auth_notifier.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class Configuracion extends ConsumerStatefulWidget {
  const Configuracion({super.key, this.taller});

  final String? taller;

  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}

class _ConfiguracionState extends ConsumerState<Configuracion> {
  User? user;
  String? taller;
  bool _isExpanded = false;


  @override
  void initState() {
    super.initState();
    // Establece el usuario actual y el taller al inicializar
    user = ref.read(authProvider);
    _obtenerTallerUsuario();
    SubscriptionVerifier.verificarAdminYSuscripcion(context);
  }

  Future<void> _obtenerTallerUsuario() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final tallerObtenido =
        await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    setState(() {
      taller = tallerObtenido;
    });
  }



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
  final Email email = Email(
    body: 'Hola, quisiera más información.',
    subject: 'Consulta',
    recipients: ['manunv97@gmail.com'],
    isHTML: false,
  );

  try {
    await FlutterEmailSender.send(email);
  } catch (error) {
    debugPrint('Error al enviar el correo: $error');
  }
}




  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isDark = ref.watch(themeNotifyProvider).isDarkMode;
    final List<Color> colors = ref.watch(listTheColors);
    final int selectedColor = ref.watch(themeNotifyProvider).selectedColor;
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final List<Map<String, String>> options = [
      {
        'title': AppLocalizations.of(context).translate('changePassword'),
        'route': '/cambiarpassword',
      },
      if (taller != null)
        {
          'title': AppLocalizations.of(context).translate('changeUsername'),
          'route': '/cambiarfullname/$taller', // Ruta dinámica
        },
    ];

    return Scaffold(
      appBar: ResponsiveAppBar(isTablet: size.width > 600),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: user == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).translate('loginRequired'),
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: BoxText(
                          text: AppLocalizations.of(context)
                              .translate('settingsIntro')),
                    ),
                    const SizedBox(height: 20),
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.of(context).translate('chooseColor'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final color = colors[index];
                            return RadioListTile(
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.palette_outlined,
                                    color: color,
                                    size: 35,
                                  ),
                                  const SizedBox(width: 15),
                                  Icon(
                                    Icons.palette_outlined,
                                    color: color,
                                    size: 35,
                                  ),
                                  const SizedBox(width: 15),
                                  Icon(
                                    Icons.palette_outlined,
                                    color: color,
                                    size: 35,
                                  ),
                                  const SizedBox(width: 15),
                                ],
                              ),
                              activeColor: color,
                              value: index,
                              groupValue: selectedColor,
                              onChanged: (value) {
                                ref
                                    .read(themeNotifyProvider.notifier)
                                    .changeColor(index);
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            isDark
                                ? AppLocalizations.of(context)
                                    .translate('lightMode')
                                : AppLocalizations.of(context)
                                    .translate('darkMode'),
                          ),
                          onTap: () {
                            ref
                                .read(themeNotifyProvider.notifier)
                                .toggleDarkMode();
                          },
                          leading: isDark
                              ? const Icon(Icons.light_mode_outlined)
                              : const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.of(context).translate('updateData'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options[index];
                            return ListTile(
                              title: Text(option['title']!),
                              onTap: () => context.push(option['route']!),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          // Botones flotantes
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isExpanded)
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(begin: 50, end: 0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, value),
                        child: FloatingActionButton(
                          onPressed: _launchWhatsApp,
                          backgroundColor: Colors.green,
                          heroTag: 'whatsapp',
                          child: const Icon(FontAwesomeIcons.whatsapp),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (_isExpanded)
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(begin: 50, end: 0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, value),
                        child: FloatingActionButton(
                          onPressed: _launchEmail,
                          backgroundColor: Colors.red,
                          heroTag: 'email',
                          child: const Icon(FontAwesomeIcons.envelope),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    heroTag: 'main',
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.contact_page_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}