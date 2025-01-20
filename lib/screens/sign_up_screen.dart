// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/utiles/generar_id.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/l10n/app_localizations.dart';
import '../utils/utils_barril.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, String? taller});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');


  String passwordError = '';
  String confirmPasswordError = '';
  String mailError = '';
  bool showSuccessMessage = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar:
          ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  size.width * 0.05, 20, size.width * 0.05, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primary.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  localizations.translate('signupScreenIntro'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: size.width * 0.04),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('createUserPrompt'),
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: color.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        TextField(
                          controller: fullnameController,
                          decoration: InputDecoration(
                            labelText: localizations.translate('fullNameLabel'),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 16),
                        TextField(
  controller: emailController,
  decoration: InputDecoration(
    labelText: localizations.translate('emailLabel'),
    border: const OutlineInputBorder(),
    errorText: mailError.isEmpty ? null : mailError,
  ),
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) {
    setState(() {
      mailError = !emailRegex.hasMatch(emailController.text.trim())
          ? localizations.translate('invalidEmail')
          : '';
    });
  },
),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: localizations.translate('passwordLabel'),
                            border: const OutlineInputBorder(),
                            errorText:
                                passwordError.isEmpty ? null : passwordError,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              passwordError = value.length < 6
                                  ? localizations.translate('passwordTooShort')
                                  : '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText:
                                localizations.translate('confirmPasswordLabel'),
                            border: const OutlineInputBorder(),
                            errorText: confirmPasswordError.isEmpty
                                ? null
                                : confirmPasswordError,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              confirmPasswordError = value !=
                                      passwordController.text
                                  ? localizations.translate('passwordMismatch')
                                  : '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            FocusScope.of(context).unfocus();
                            final fullname = fullnameController.text.trim();
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final confirmPassword =
                                confirmPasswordController.text.trim();

                            if (fullname.isEmpty ||
                                email.isEmpty ||
                                password.isEmpty ||
                                confirmPassword.isEmpty) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations
                                      .translate('allFieldsRequired')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (password.length < 6) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations
                                      .translate('passwordTooShort')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (password != confirmPassword) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations
                                      .translate('passwordMismatch')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              final usuarioActivo =
                                  Supabase.instance.client.auth.currentUser;
                              final taller = await ObtenerTaller()
                                  .retornarTaller(usuarioActivo!.id);
                              final listausuarios = await ObtenerTotalInfo(
                                supabase: supabase,
                                usuariosTable: 'usuarios',
                                clasesTable: taller,
                              ).obtenerUsuarios();

                              final emailExiste = listausuarios
                                  .any((usuario) => usuario.usuario == email);
                              final fullnameExiste = listausuarios.any(
                                  (usuario) =>
                                      usuario.fullname.toLowerCase() ==
                                      fullname.toLowerCase());

                              if (emailExiste) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(localizations
                                        .translate('emailAlreadyRegistered')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (fullnameExiste) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(localizations
                                        .translate('fullnameAlreadyExists')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final AuthResponse res =
                                  await supabase.auth.signUp(
                                email: email,
                                password: password,
                                data: {
                                  'fullname': Capitalize().capitalize(fullname)
                                },
                              );

                              await supabase.from('usuarios').insert({
                                'id': await GenerarId().generarIdUsuario(),
                                'usuario': email,
                                'fullname': Capitalize().capitalize(fullname),
                                'user_uid': res.user?.id,
                                'sexo': "mujer",
                                'clases_disponibles': 0,
                                'trigger_alert': 0,
                                'clases_canceladas': [],
                                'taller': await ObtenerTaller()
                                    .retornarTaller(user!.id),
                              });

                              setState(() {
                                isLoading = false;
                                showSuccessMessage = true;
                              });

                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations
                                      .translate('registroSuccess')),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Future.delayed(const Duration(seconds: 30), () {
                                setState(() {
                                  showSuccessMessage = false;
                                });
                              });
                            } on AuthException catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations.translate(
                                      'registrationError',
                                      params: {'error': e.message ?? ''})),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations.translate(
                                      'unexpectedError',
                                      params: {'error': e.toString()})),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(AppLocalizations.of(context)
                                      .translate('registerWorkshopButton')),
                        ),
                   
        
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
